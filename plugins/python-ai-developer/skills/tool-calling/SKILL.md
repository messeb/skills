---
description: Function and tool calling across providers — designing a tool surface, schema and description quality, the agent loop and its termination conditions, parallel calls, error results that let the model recover, provider differences in the loop shape, security against prompt injection and confused-deputy attacks, and observability of tool traces.
---

# Tool calling and agent loops

Goal of this skill: let a model act through your code safely — with a small, well-described tool surface, a loop that terminates, and a security model that assumes the model may be manipulated by the data it reads.

Use this skill when the model needs live data, must trigger actions, or must chain steps. Pair with `structured-output` (for constrained results) and `async-and-background-work` (for long-running tool work).

---

## 1. Design the tool surface first

The most common cause of poor tool use is too many, too vague tools.

| Rule | Why |
|------|-----|
| Under ~10 tools per request | Accuracy degrades as the surface grows; split by agent or by task |
| One clear purpose per tool | Overloaded tools with a `mode` parameter confuse selection |
| Description states **when to use it and when not to** | This is the actual selection signal, not the name |
| Parameters typed narrowly — enums, bounds, formats | Cuts the invalid-argument rate sharply |
| Return compact, structured results | A 50k-token dump destroys the context and the budget |
| Read-only by default; writes are explicit and few | Limits blast radius |
| Name tools in domain terms (`search_invoices`) | `execute_query` invites arbitrary use |

```python
{
    "name": "search_invoices",
    "description": (
        "Search invoices by customer and date range. "
        "Use when the user asks about specific invoices or amounts owed. "
        "Do NOT use for aggregate reporting — use `invoice_summary` instead. "
        "Returns at most 20 invoices, newest first."
    ),
    "input_schema": {
        "type": "object",
        "properties": {
            "customer_id": {"type": "string", "description": "Internal customer id, e.g. CUS-1042"},
            "status": {"type": "string", "enum": ["paid", "unpaid", "overdue"]},
            "since": {"type": "string", "format": "date"},
            "limit": {"type": "integer", "minimum": 1, "maximum": 20, "default": 10},
        },
        "required": ["customer_id"],
        "additionalProperties": False,
    },
    "strict": True,
}
```

---

## 2. The loop

```python
async def run_agent(client, messages, tools, *, max_turns: int = 8,
                    deadline_s: float = 120.0, budget_usd: float = 0.50) -> str:
    spent = 0.0
    with anyio.fail_after(deadline_s):
        for turn in range(max_turns):
            resp = await client.messages.create(
                model=settings.model_default, max_tokens=4096,
                tools=tools, messages=messages,
            )
            spent += cost_of(resp)
            if spent > budget_usd:
                raise BudgetExceeded(f"agent spent ${spent:.2f}")

            messages.append({"role": "assistant", "content": resp.content})

            if resp.stop_reason != "tool_use":
                return "".join(b.text for b in resp.content if b.type == "text")

            results = await asyncio.gather(*[
                execute_tool(b) for b in resp.content if b.type == "tool_use"
            ])
            # All results go back in ONE user message
            messages.append({"role": "user", "content": results})

    raise AgentLoopExhausted(f"no final answer in {max_turns} turns")
```

Four termination conditions, all mandatory: **max turns**, **wall-clock deadline**, **cost budget**, and **no-progress detection** (the same tool called with the same arguments twice in a row means the model is stuck — break rather than loop).

Return **all** tool results in a single message. Splitting parallel results across multiple messages trains the model to stop making parallel calls and slows every subsequent turn.

Anthropic's SDK provides a tool runner that owns this loop for you — `@beta_tool` on typed functions plus `client.beta.messages.tool_runner(...)` — which is worth using when you do not need custom control flow. Write the loop yourself when you need approval gates, budgets, or provider fallback inside it.

---

## 3. Tool errors

A failed tool must return a **result**, not raise into the loop. The model can recover from a described failure; it cannot recover from an exception that terminates the request.

```python
async def execute_tool(block) -> dict:
    try:
        args = block.input                       # already parsed JSON — never string-match it
        result = await REGISTRY[block.name](**args)
        return {"type": "tool_result", "tool_use_id": block.id,
                "content": json.dumps(result)[:8000]}     # cap the payload
    except ValidationError as e:
        return {"type": "tool_result", "tool_use_id": block.id, "is_error": True,
                "content": f"Invalid arguments: {e}. Correct them and try again."}
    except NotFoundError:
        return {"type": "tool_result", "tool_use_id": block.id, "is_error": True,
                "content": "No such customer. Ask the user to confirm the customer id."}
    except Exception:
        log.exception("tool failed", extra={"tool": block.name})
        return {"type": "tool_result", "tool_use_id": block.id, "is_error": True,
                "content": "Tool temporarily unavailable. Do not retry; tell the user."}
```

Rules: **every** `tool_use` gets a matching `tool_result` (a missing one is a protocol error); error messages tell the model what to do next; internal exception text and stack traces never reach the model; and truncate large results with an explicit marker rather than silently.

---

## 4. Provider differences

The loop shape is the same everywhere; the vocabulary is not.

| Concept | OpenAI / Grok / Mistral | Anthropic | Gemini |
|---|---|---|---|
| Declare | `tools=[{"type":"function","function":{...}}]` | `tools=[{name, description, input_schema}]` | `tools=[Tool(function_declarations=[...])]` |
| Model wants a call | `finish_reason == "tool_calls"` | `stop_reason == "tool_use"` | a `function_call` part |
| Result role | `role: "tool"`, `tool_call_id` | user message with `tool_result` blocks | a `function_response` part |
| Strictness | `strict: true` on the function | `strict: true` on the tool | schema-typed declarations |
| Parallel calls | multiple `tool_calls` | multiple `tool_use` blocks | multiple parts |

Normalise all of this in the adapter (`provider-abstraction`) and keep one loop.

---

## 5. Security

A tool-using model is a **confused deputy**: it acts with your service's authority on instructions that may come from untrusted content it read.

| Threat | Control |
|--------|---------|
| **Prompt injection** in fetched pages, PDFs, emails, or tool output | Treat all tool output as untrusted data, never as instructions. Never let retrieved text change what tools are permitted |
| Model requesting data across tenants | Authorise **server-side** on the caller's identity; never accept a `tenant_id` or `user_id` argument from the model |
| Destructive actions | Human approval gate for writes, deletes, payments, and sends |
| Data exfiltration through a tool argument | Allowlist outbound domains; validate URLs; block private address ranges |
| SQL or command injection via arguments | Parameterised queries; no shell interpolation; no arbitrary-query tool |
| Cost exhaustion | Per-request turn, token, and dollar budgets |
| Secrets in tool results | Redact before returning; the model may echo anything it sees |

The load-bearing rule: **the model chooses which tool to call; your code decides whether that call is allowed**. Authorisation lives in `execute_tool`, derived from the authenticated request context — never from the model's arguments.

```python
async def execute_tool(block, ctx: RequestContext):
    spec = REGISTRY[block.name]
    if spec.scope not in ctx.granted_scopes:
        return error_result(block, "Not permitted.")
    if spec.mutating and not ctx.approved:
        return error_result(block, "This action requires user confirmation.")
    return await spec.fn(**block.input, tenant_id=ctx.tenant_id)   # from context, not the model
```

---

## 6. Observability

Log per turn: turn index, model, tool names requested, argument sizes, execution latency and outcome per tool, tokens in/out, cumulative cost, and the termination reason. Store the full trace against the request id so a bad answer can be replayed.

Watch these signals: average turns per request (rising means tool descriptions are unclear), invalid-argument rate per tool (a schema problem), tool error rate, loop-exhaustion rate, and cost per completed task.

---

## 7. Anti-patterns

| Anti-pattern | Consequence |
|--------------|-------------|
| 30 tools in one request | Wrong tool selected; accuracy collapses |
| Vague descriptions ("query the database") | Misuse and hallucinated arguments |
| Loop with no turn, time, or cost limit | Runaway spend; hung requests |
| Tool exception propagating out of the loop | Request dies where the model could have recovered |
| Missing `tool_result` for a `tool_use` | Protocol error on the next call |
| Parallel results split across messages | Model stops issuing parallel calls |
| Raw stack traces returned to the model | Internal detail leaked into output |
| Unbounded tool result payloads | Context and budget exhausted in one turn |
| Trusting `tenant_id` supplied by the model | Cross-tenant data access |
| Treating fetched content as instructions | Prompt injection executes your tools |
| Writes without an approval gate | Irreversible actions from a hallucination |
| String-matching serialized tool input | Breaks on escaping differences; always parse the JSON |
| No trace retained | Bad answers cannot be diagnosed |

---

## 8. Checklist

- [ ] Fewer than ~10 tools per request, each with one purpose
- [ ] Descriptions state when to use and when not to use the tool
- [ ] Schemas strict, with enums, bounds, formats, and `additionalProperties: false`
- [ ] Loop bounded by max turns, deadline, cost budget, and no-progress detection
- [ ] All parallel tool results returned in a single message
- [ ] Every `tool_use` answered with a `tool_result`, errors included
- [ ] Tool errors returned as actionable text; internals never exposed
- [ ] Result payloads capped with an explicit truncation marker
- [ ] Tool inputs parsed as JSON, never string-matched
- [ ] Authorisation performed server-side from request context, not model arguments
- [ ] Tool output treated as untrusted data; injection cannot change permissions
- [ ] Mutating actions gated by explicit approval
- [ ] Outbound URLs validated against an allowlist; private ranges blocked
- [ ] Per-turn trace logged with cost and termination reason
