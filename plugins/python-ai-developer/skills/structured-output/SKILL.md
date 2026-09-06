---
description: Getting reliable typed data out of a model — native schema-constrained output per provider, Pydantic model design that models actually satisfy, the validate-and-repair loop, handling refusals and truncation, extraction with provenance and confidence, versioning schemas, and testing extraction against a labelled set.
---

# Structured output

Goal of this skill: turn model output into a validated Python object, with a defined path for every way that can fail — and without a fragile regex over prose.

Use this skill for extraction, classification, routing, form filling, and any place a model's output feeds code rather than a human.

---

## 1. Prefer native schema enforcement

Ranked by reliability:

| Approach | Reliability | Notes |
|----------|-------------|-------|
| **Native schema-constrained output** | Highest | The provider constrains decoding to your JSON Schema |
| **Strict tool/function calling** | High | The model must produce arguments matching the schema |
| **"Reply in JSON" prompt + validation** | Medium | Needs a repair loop; the only option on providers without native support |
| **Regex or string parsing of prose** | Low | Do not build on this |

### Anthropic

```python
from pydantic import BaseModel

class Invoice(BaseModel):
    invoice_number: str
    total_cents: int
    currency: str
    due_date: str | None = None

resp = await client.messages.parse(
    model="claude-opus-5",
    max_tokens=4096,
    messages=[{"role": "user", "content": text}],
    output_format=Invoice,
)
invoice = resp.parsed_output          # a validated Invoice
```

Raw-schema form, when you are not using Pydantic:

```python
resp = await client.messages.create(
    model="claude-opus-5", max_tokens=4096,
    messages=[{"role": "user", "content": text}],
    output_config={"format": {"type": "json_schema", "schema": {
        "type": "object",
        "properties": {"invoice_number": {"type": "string"}, "total_cents": {"type": "integer"}},
        "required": ["invoice_number", "total_cents"],
        "additionalProperties": False,
    }}},
)
```

### OpenAI

```python
resp = await client.responses.parse(
    model=settings.model_default,
    input=[{"role": "user", "content": text}],
    text_format=Invoice,
)
invoice = resp.output_parsed
```

### Gemini

```python
resp = await client.aio.models.generate_content(
    model=settings.model_default,
    contents=text,
    config=types.GenerateContentConfig(
        response_mime_type="application/json",
        response_schema=Invoice,
    ),
)
invoice = Invoice.model_validate_json(resp.text)
```

### Mistral and Grok

Mistral supports JSON mode and schema-constrained output through its chat API; xAI's OpenAI-compatible endpoint supports the OpenAI-style response-format field to varying degrees by model. **Verify per model** rather than assuming, and keep the prompt-plus-repair path available as the declared fallback (`provider-abstraction` capability negotiation).

Across all providers, `additionalProperties: false` and a complete `required` list are what make schema enforcement meaningful — a permissive schema constrains nothing.

---

## 2. Design schemas models can actually satisfy

The schema is part of the prompt. Most extraction failures are schema design failures.

| Rule | Why |
|------|-----|
| Describe every field | The `description` is instruction, not documentation — this is the highest-leverage change you can make |
| Prefer flat over deeply nested | Nesting increases both error rate and token count |
| Use enums for closed sets | `Literal["paid","unpaid","partial"]` beats a free string every time |
| Make genuinely optional fields `\| None`, and say what null means | Otherwise the model invents a value to satisfy the schema |
| Add an explicit "not found" representation | Without it, hallucination is the only way to satisfy a required field |
| Avoid `Union` of similar shapes | Ambiguous discrimination; add an explicit `type` discriminator if you must |
| Money as integer minor units plus a currency | Floats and formatted strings both go wrong |
| Dates as ISO 8601 strings, validated after parsing | Do not accept "next Tuesday" |
| Keep field names semantic (`invoice_number`, not `field_3`) | The name carries meaning to the model |

```python
from typing import Literal
from pydantic import BaseModel, Field

class LineItem(BaseModel):
    description: str = Field(description="Product or service description, verbatim from the document")
    quantity: int = Field(ge=0)
    unit_price_cents: int = Field(ge=0, description="Unit price in minor units, e.g. 1050 for EUR 10.50")

class Invoice(BaseModel):
    invoice_number: str | None = Field(default=None, description="Null if no invoice number is printed")
    status: Literal["paid", "unpaid", "partial", "unknown"] = "unknown"
    currency: str = Field(pattern=r"^[A-Z]{3}$", description="ISO 4217 code")
    total_cents: int = Field(ge=0)
    line_items: list[LineItem] = Field(default_factory=list, max_length=200)
```

Bound every list (`max_length`). An unbounded list is an unbounded bill.

---

## 3. The failure paths

Schema enforcement guarantees the *shape*, never the *truth*. Handle these explicitly:

| Failure | Detection | Response |
|---------|-----------|----------|
| Truncation | `finish_reason == "length"` | Raise; do not parse a partial object. Increase `max_output_tokens` or chunk the input |
| Refusal / safety block | Provider stop reason or safety field | Surface as `ProviderRefused`; do not retry blindly |
| Schema-valid but wrong | Business validation (totals, cross-field consistency) | Reject or flag for review |
| Hallucinated value | Provenance check against the source text | Require quoted evidence (below) |
| Validation failure (no native enforcement) | `pydantic.ValidationError` | One repair round-trip, then fail |

```python
async def extract(client, text: str, schema: type[T], max_repairs: int = 1) -> T:
    raw = await client.complete_json(text, schema)
    for attempt in range(max_repairs + 1):
        try:
            return schema.model_validate_json(raw)
        except ValidationError as e:
            if attempt == max_repairs:
                raise
            raw = await client.complete_json(
                f"Your previous output failed validation:\n{e}\n"
                f"Return corrected JSON only.\nPrevious output:\n{raw}",
                schema,
            )
```

One repair attempt is worth it; three is a sign the schema or the prompt is wrong, and each attempt is billed.

---

## 4. Provenance and confidence

For extraction from documents, a bare value is not auditable. Ask for evidence:

```python
class ExtractedField(BaseModel):
    value: str | None
    evidence: str | None = Field(description="Exact quote from the source that supports the value; null if absent")
    page: int | None = None

class Contract(BaseModel):
    party_a: ExtractedField
    termination_notice_days: ExtractedField
```

Then verify mechanically: if `evidence` is not a substring of the source text, the value is unsupported — flag it rather than trusting it. This turns a plausible-sounding hallucination into a detectable defect, and it is the single most effective quality control in document extraction.

Treat model-reported confidence scores with suspicion: they are poorly calibrated. Prefer structural signals — evidence present and verifiable, cross-field consistency, agreement between two runs or two models.

---

## 5. Versioning and evolution

- Version the schema alongside the prompt (`prompts/invoice_extract/v3.md`, `schemas/invoice_v3.py`); an extraction result records which version produced it.
- Adding an optional field is compatible. Removing a field, tightening an enum, or changing a type is breaking — treat it like an API change (`api-contracts` in the product-discovery plugin, if you use it).
- Re-run the labelled evaluation set on every schema or prompt change; a "harmless" wording change can move accuracy several points (`llm-testing-and-evals`).
- Store the raw model output alongside the parsed object for as long as your retention policy allows, so a schema bug can be re-parsed without re-paying for inference.

---

## 6. Anti-patterns

| Anti-pattern | Consequence |
|--------------|-------------|
| Regex or `json.loads` on prose | Brittle; breaks on the first markdown fence |
| Prompting for JSON when native enforcement exists | Avoidable parse failures and repair costs |
| Schema without field descriptions | Much higher error rate for zero token savings |
| Required fields with no "unknown" option | The model must hallucinate to satisfy the schema |
| Unbounded lists | Unbounded cost and latency |
| Floats for money | Rounding errors in financial data |
| Parsing output when `finish_reason == "length"` | Silently truncated data treated as complete |
| Unlimited repair loops | Cost multiplied for a schema problem |
| Trusting model confidence scores | Poorly calibrated; false assurance |
| No provenance for document extraction | Hallucinations are undetectable |
| Schema changed without re-running the eval set | Silent accuracy regression |
| `additionalProperties` left unset | Enforcement is weaker than you think |

---

## 7. Checklist

- [ ] Native schema-constrained output used where the provider supports it
- [ ] `additionalProperties: false` and a complete `required` list
- [ ] Every field carries a description written as an instruction
- [ ] Closed sets modelled as enums; optional fields nullable with defined null semantics
- [ ] Explicit "unknown"/"not found" representation so hallucination is not forced
- [ ] Lists bounded; money in integer minor units with a currency
- [ ] `finish_reason` checked before parsing
- [ ] Refusals surfaced distinctly from validation failures
- [ ] Repair loop capped at one attempt, with the failure recorded
- [ ] Provenance quotes required and verified against the source for document extraction
- [ ] Business-rule validation applied beyond schema validation
- [ ] Schema and prompt versioned together; results record the version
- [ ] Raw output retained for re-parsing within the retention policy
- [ ] Labelled evaluation set re-run on every schema or prompt change
