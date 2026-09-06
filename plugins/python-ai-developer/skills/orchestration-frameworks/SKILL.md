---
description: Choosing and using LLM orchestration frameworks — when raw SDKs beat a framework, LangChain and LCEL, LangGraph for stateful durable agents with checkpointing and human-in-the-loop, and the adjacent options (PydanticAI, Instructor, LlamaIndex, Haystack). Covers adoption without losing the provider boundary, dependency and version risk, observability, testing framework-based code, and exit cost.
---

# Orchestration frameworks: LangChain, LangGraph, and the alternatives

Goal of this skill: decide **whether** a framework earns its place, and if so, adopt it in a way that leaves your domain logic and provider boundary intact.

Use this skill before adding a framework dependency, when an existing LangChain codebase has become hard to debug, or when an agent needs durable state, checkpointing, or human approval steps.

---

## 1. The decision

Frameworks trade control for velocity. The trade is worth it when you use enough of what they provide.

| Signal | Choice |
|--------|--------|
| One or two provider calls, structured output, a little retry logic | **Raw SDKs** + `provider-abstraction` — a framework adds more concepts than it removes |
| Straight-line chains, quick prototypes, wide integration needs (many loaders, stores, tools) | **LangChain** |
| Cyclic, stateful, multi-step agents; needs pause/resume, human approval, time travel, or durability across restarts | **LangGraph** |
| The hard part is prompt quality and you have a labelled metric | **DSPy** (see the `dspy` skill) |
| Typed agents with Pydantic-first ergonomics and dependency injection | **PydanticAI** |
| Only structured extraction from many providers | **Instructor** (thin; low lock-in) |
| Document-centric RAG with heavy ingestion and indexing | **LlamaIndex** |
| Production search/RAG pipelines with explicit components | **Haystack** |

Two honest observations that should shape the decision:

- **A framework is not a substitute for the boundary.** Whatever you adopt, keep it behind your own interface (`provider-abstraction`). Frameworks change APIs faster than your business logic should.
- **Most services need orchestration, not an agent.** A deterministic Python function calling three model calls in sequence is easier to test, cheaper, and more reliable than a graph that decides its own control flow. Reach for an agent framework when control flow genuinely must be model-driven.

---

## 2. LangChain

LangChain's value today is its **integration surface** — hundreds of model providers, vector stores, document loaders, and tools behind common interfaces — plus LCEL for composing steps.

```python
from langchain_anthropic import ChatAnthropic
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import PydanticOutputParser

llm = ChatAnthropic(model="claude-opus-5", max_tokens=4096, timeout=60)
prompt = ChatPromptTemplate.from_messages([
    ("system", "You extract structured invoice data."),
    ("human", "{document}"),
])
chain = prompt | llm.with_structured_output(Invoice)

invoice = await chain.ainvoke({"document": text})
```

Practical guidance:

- Install **only the partner packages you use** (`langchain-anthropic`, `langchain-openai`, …), not the metapackage. The dependency surface is the main operational cost.
- Pin versions tightly and read release notes before upgrading; the package split and API have moved repeatedly.
- Use `with_structured_output` rather than parsing prose — it maps onto each provider's native schema enforcement.
- Wrap chains behind your own function signatures. `chain.ainvoke` in a router is the same leak as `import anthropic` in a router.
- Know what it hides: retries, token accounting, and prompt assembly all happen inside. Instrument deliberately (§5) or you will not be able to explain a bill or a latency spike.

When LangChain stops paying: you are using one provider, one prompt shape, and no loaders — then you are maintaining an abstraction layer you do not use.

---

## 3. LangGraph

LangGraph models an agent as an explicit **state machine**: nodes are functions, edges are transitions, and state is a typed object reduced across steps. This is the right tool when control flow is cyclic and must survive interruption.

```python
from typing import Annotated, TypedDict
from operator import add
from langgraph.graph import StateGraph, START, END
from langgraph.checkpoint.postgres import PostgresSaver


class State(TypedDict):
    document: str
    findings: Annotated[list[str], add]     # reducer: appended across nodes
    draft: str | None
    approved: bool


def extract(state: State) -> dict:
    return {"findings": [run_extraction(state["document"])]}

def draft(state: State) -> dict:
    return {"draft": write_draft(state["findings"])}

def needs_review(state: State) -> str:
    return "review" if risky(state["draft"]) else END


builder = StateGraph(State)
builder.add_node("extract", extract)
builder.add_node("draft", draft)
builder.add_node("review", human_review)         # interrupts for approval
builder.add_edge(START, "extract")
builder.add_edge("extract", "draft")
builder.add_conditional_edges("draft", needs_review, {"review": "review", END: END})
builder.add_edge("review", END)

graph = builder.compile(checkpointer=PostgresSaver(pool))   # durable state
result = await graph.ainvoke({"document": text, "findings": []},
                             config={"configurable": {"thread_id": job_id}})
```

What LangGraph gives you that a hand-written loop does not:

| Capability | Why it matters |
|------------|----------------|
| **Checkpointing** | State persists per thread; a crash or deploy resumes instead of re-paying for completed steps |
| **Human-in-the-loop** | `interrupt` pauses the graph awaiting approval, then resumes — the correct shape for mutating actions (`tool-calling`) |
| **Time travel** | Rewind to a prior checkpoint and take a different branch when debugging |
| **Explicit control flow** | The graph is readable and testable; node functions are ordinary Python |
| **Streaming per node** | Progress reporting that maps to real steps rather than tokens |
| **Durable execution** | Long jobs survive restarts — pairs naturally with `async-and-background-work` |

Guidance: keep node functions **pure and small** — call your own services, do not embed provider SDK calls in nodes; put the same turn, deadline, and cost budgets on the graph that you would on a loop; use a real checkpointer (Postgres) in production, not the in-memory one; and set `thread_id` to your job id so the graph and your job record agree.

Use a plain function when the flow is a straight line, and a graph when it genuinely cycles or must pause.

---

## 4. Adjacent options worth knowing

| Framework | Shape | Fits when |
|-----------|-------|-----------|
| **PydanticAI** | Typed agents, Pydantic-native results, dependency injection, model-agnostic | You like the FastAPI/Pydantic idiom and want typed agents without LangChain's surface |
| **Instructor** | A thin wrapper adding schema-validated output plus retries to existing SDK clients | You only need structured extraction; near-zero lock-in |
| **LlamaIndex** | Document ingestion, indexing, retrieval, query engines | RAG where ingestion and indexing are the hard part |
| **Haystack** | Explicit component pipelines for search and RAG | Production search pipelines; strong on evaluation |
| **Provider agent SDKs** | Vendor-specific agent harnesses | You have deliberately committed to one provider |

Combining is normal and usually better than adopting one framework wholesale: LlamaIndex for ingestion, your own adapters for generation, LangGraph only for the part that is genuinely a stateful agent.

---

## 5. Adopting without losing the boundary

```python
# app/agents/review.py  — the ONLY module that imports langgraph
class ReviewAgent:
    async def run(self, document: str, job_id: str) -> ReviewResult:
        state = await self._graph.ainvoke(..., config={"configurable": {"thread_id": job_id}})
        return ReviewResult.model_validate(state["result"])   # your type, not the framework's
```

| Rule | Reason |
|------|--------|
| Framework imports confined to one package | Replacing or upgrading it is a contained change |
| Your types cross the boundary, never the framework's | Domain code stays framework-free |
| Prompts stay in `prompts/`, versioned | Frameworks bury prompts in templates you cannot diff |
| Settings and model IDs from your config | Do not let a framework own configuration |
| Budgets, retries, and limits applied at your boundary | Framework defaults are not your policy |
| Pin versions; upgrade deliberately | These packages take breaking changes often |

**Observability**: frameworks hide the provider call, so instrument explicitly — callback handlers or an OpenTelemetry integration, emitting the same per-call record as `llm-reliability-and-cost` (provider, model, tokens, cost, latency, prompt version). Tracing (LangSmith, Langfuse, or plain OTel) is close to mandatory for a multi-node graph; without it, "the agent was slow" is undebuggable.

**Testing**: node functions and chain inputs/outputs are ordinary Python — unit test them with fakes. Test the graph's routing with stub nodes rather than real model calls. Keep the framework out of your test path wherever the logic is deterministic (`llm-testing-and-evals`).

---

## 6. Anti-patterns

| Anti-pattern | Consequence |
|--------------|-------------|
| Adopting a framework for a single provider call | More concepts, more dependencies, no benefit |
| `langchain` metapackage installed | Enormous transitive dependency surface |
| Framework objects in domain signatures | Domain code welded to a fast-moving dependency |
| Prompts embedded in framework templates | No versioning, no diffing, no evaluation |
| An agent where a `for` loop would do | Non-deterministic control flow, higher cost, harder debugging |
| LangGraph with the in-memory checkpointer in production | State lost on restart; durability was the reason to adopt it |
| Framework retries plus SDK retries plus your own | Attempts and cost multiply invisibly |
| No tracing on a multi-node graph | Latency and cost problems cannot be located |
| Unpinned framework versions | A patch release changes behaviour in production |
| Building on a deprecated abstraction (legacy chains/agents) | Migration work on the next upgrade |
| Framework's model defaults left in place | Wrong model, wrong token limits, wrong spend |

---

## 7. Checklist

- [ ] Decision recorded: why a framework (or none) for this service
- [ ] Only the partner packages actually used are installed; versions pinned
- [ ] Framework imports confined to one module or package
- [ ] Your own types and error taxonomy cross the boundary
- [ ] Prompts live in versioned files, not framework templates
- [ ] Model IDs and settings come from your config, not framework defaults
- [ ] Exactly one retry policy across SDK, framework, and application
- [ ] Budgets, turn caps, and deadlines applied at your boundary
- [ ] LangGraph: durable checkpointer in production; `thread_id` bound to the job id
- [ ] LangGraph: nodes small and pure; interrupts used for approval of mutating actions
- [ ] Per-call telemetry emitted despite the framework's abstraction
- [ ] Tracing enabled for multi-node graphs
- [ ] Deterministic logic tested without the framework in the path
- [ ] Exit cost understood: what it would take to remove this dependency
