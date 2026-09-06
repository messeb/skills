---
description: Operations research and optimization in Python — recognising an OR problem, choosing between OR-Tools CP-SAT, MILP solvers via PuLP/Pyomo, routing and network models, and heuristics; modelling patterns for scheduling, assignment, routing, packing, and rostering; objectives and soft constraints; infeasibility diagnosis; time limits and determinism; scaling; and combining a solver with an LLM safely.
---

# Operations research and optimization

Goal of this skill: recognise when a problem is a constrained optimization problem rather than a prediction or generation problem, model it correctly, and get a provably good solution in a bounded time.

Use this skill for scheduling, shift rostering, vehicle routing, assignment and matching, bin packing and cutting stock, production planning, capacity allocation, and timetabling.

---

## 1. Recognising an OR problem

Signals: you must **choose** among a combinatorial number of options; there are **hard constraints** that cannot be violated; there is an **objective** to minimise or maximise; and a human currently does it in a spreadsheet with rules of thumb.

| Not an OR problem | Is an OR problem |
|---|---|
| "Predict tomorrow's demand" | "Given predicted demand, choose the production plan that minimises cost" |
| "Summarise these shifts" | "Assign 40 staff to 120 shifts satisfying skills, rest rules, and fairness" |
| "Which customer will churn" | "Which retention offers to send within a fixed budget" |

Forecasting and optimization compose: an ML model produces the parameters, the solver makes the decision. Keep them as separate, separately testable stages.

**Never ask a language model to solve a constrained assignment problem.** It will produce a fluent, confident, infeasible answer with no proof of optimality. Models are excellent at *building* the model (translating a description into constraints) and at *explaining* a solution; the solving belongs to a solver.

---

## 2. Choosing a solver

| Tool | Kind | Best for | Limits |
|------|------|----------|--------|
| **OR-Tools CP-SAT** | Constraint programming + SAT | Scheduling, rostering, assignment, sequencing; integer and boolean decisions; excellent with logical constraints | Integers only — no continuous variables |
| **OR-Tools routing** | Specialised metaheuristics | Vehicle routing with capacities, time windows, pickup/delivery | A specialised API; not a general modelling language |
| **PuLP** | MILP modelling layer | Straightforward linear/integer programs; free solvers (CBC, HiGHS) | Weaker at complex logical constraints |
| **Pyomo** | General modelling language | Large or nonlinear models; many solver backends | Steeper learning curve |
| **HiGHS** | LP/MILP solver | Fast open-source LP/MILP backend | LP/MILP only |
| **Gurobi / CPLEX** | Commercial MILP | Very large models, best performance and diagnostics | Licence cost |
| **Heuristics / metaheuristics** | Approximate | Huge instances where any good solution beats none | No optimality proof |

Practical default: **CP-SAT** for anything with logical structure (this covers most scheduling and assignment work), **PuLP or Pyomo with HiGHS** when the model is naturally linear with continuous quantities, and the **routing library** for vehicle routing rather than modelling it from scratch.

---

## 3. Modelling patterns

### Assignment with skills and capacity

```python
from ortools.sat.python import cp_model

m = cp_model.CpModel()
x = {(w, s): m.NewBoolVar(f"x[{w},{s}]") for w in workers for s in shifts}

# Each shift covered exactly once
for s in shifts:
    m.AddExactlyOne(x[w, s] for w in workers)

# Skill feasibility
for w, s in x:
    if not skills[w] >= requirements[s]:
        m.Add(x[w, s] == 0)

# Max shifts per worker
for w in workers:
    m.Add(sum(x[w, s] for s in shifts) <= max_shifts[w])

# No overlapping shifts
for w in workers:
    for s1, s2 in overlapping_pairs:
        m.AddAtMostOne([x[w, s1], x[w, s2]])

# Fairness: minimise the spread of workload
loads = []
for w in workers:
    load = m.NewIntVar(0, len(shifts), f"load[{w}]")
    m.Add(load == sum(x[w, s] for s in shifts))
    loads.append(load)
max_load, min_load = m.NewIntVar(0, len(shifts), "max"), m.NewIntVar(0, len(shifts), "min")
m.AddMaxEquality(max_load, loads)
m.AddMinEquality(min_load, loads)

m.Minimize(10 * (max_load - min_load) + sum(cost[w, s] * x[w, s] for w, s in x))

solver = cp_model.CpSolver()
solver.parameters.max_time_in_seconds = 30.0
solver.parameters.num_workers = 8
solver.parameters.random_seed = 42                 # reproducible runs
status = solver.Solve(m)
```

| Pattern | Construct |
|---------|-----------|
| "Exactly one" / "at most one" | `AddExactlyOne`, `AddAtMostOne` |
| Non-overlapping tasks on a resource | `AddNoOverlap` with interval variables |
| Cumulative capacity over time | `AddCumulative` |
| Sequencing / precedence | `AddCircuit`, or start-time inequalities |
| Conditional constraint | `OnlyEnforceIf` with a boolean literal |
| All different (timetabling) | `AddAllDifferent` |
| Piecewise or step costs | Boolean indicators plus `AddMaxEquality` |

### Hard versus soft constraints

Most real problems are over-constrained. Model preferences as **penalties**, not as hard constraints — otherwise the model is infeasible and you learn nothing.

```python
violation = m.NewBoolVar("no_weekend_violation")
m.Add(weekend_shifts[w] == 0).OnlyEnforceIf(violation.Not())
penalties.append(WEIGHT_WEEKEND * violation)
m.Minimize(sum(penalties) + operating_cost)
```

Keep the weights in configuration and document what they mean relative to each other. A weight vector nobody can explain becomes untouchable, because no one knows what changing it will do.

---

## 4. Infeasibility

An infeasible model is the normal state during development. Diagnose it systematically rather than by guessing:

1. **Relax to find the culprit**: convert suspect hard constraints to soft ones with large penalties. If the solver then finds a solution, the penalised constraints are the conflict.
2. **Solve subsets**: drop constraint families one at a time until it becomes feasible.
3. **Check the data first** — most "solver bugs" are a shift requiring a skill nobody has, or capacity totalling less than demand. Validate inputs before solving and fail with a business-readable message.
4. **Use `AddAssumptions`** in CP-SAT and read `SufficientAssumptionsForInfeasibility()` to get a minimal conflicting set.
5. **Always return an explanation**, never a bare "infeasible": *"Tuesday night needs 3 nurses with ICU certification; only 2 are available."*

---

## 5. Running solvers in a service

| Concern | Practice |
|---------|----------|
| **Always set a time limit** | Without one, a solve can run for hours and hold a worker |
| Accept the best feasible solution | Optimality is usually not required; log the gap and whether it was proven optimal |
| Run in a worker process | Solvers are CPU-bound and release the GIL unpredictably; never on the event loop |
| Set `random_seed` and fix `num_workers` | Multi-threaded search is otherwise non-deterministic — the same input gives different plans, which users notice |
| Warm start from the previous solution | Faster, and produces stable plans rather than a completely different roster each run |
| Add a solution callback | Stream progress for long solves |
| Cap instance size at the API boundary | Combinatorial growth turns a large request into a denial of service |
| Version the model | Record which model version and weights produced a plan |

```python
status = solver.Solve(model)
if status in (cp_model.OPTIMAL, cp_model.FEASIBLE):
    result = Solution(
        assignments=extract(solver, x),
        objective=solver.ObjectiveValue(),
        bound=solver.BestObjectiveBound(),
        proven_optimal=status == cp_model.OPTIMAL,
        wall_time_s=solver.WallTime(),
    )
```

**Validate every returned solution against the constraints independently**, in plain Python. A model bug produces a solution the solver believes is valid; an independent feasibility check is cheap insurance and catches modelling errors that no unit test will.

---

## 6. Scaling

| Technique | When |
|-----------|------|
| Tighten variable domains | Always — a smaller search space is the cheapest win |
| Symmetry breaking | Interchangeable workers or machines cause enormous redundant search |
| Decompose by time or region | Solve a week at a time instead of a year |
| Fix known decisions | Locked shifts and confirmed orders become constants |
| Column generation / rolling horizon | Very large routing and scheduling problems |
| Heuristic warm start | Give the solver a good incumbent immediately |
| Aggregate | Solve at a coarse granularity, then refine |

If the model is still intractable, reconsider the formulation before buying a commercial solver. A better model routinely beats a faster solver by an order of magnitude.

---

## 7. Combining with an LLM

| Use a model for | Do not use a model for |
|-----------------|------------------------|
| Turning a natural-language policy into candidate constraints, for human review | Producing the assignment |
| Explaining a solution to an end user | Judging feasibility |
| Explaining *why* a request is infeasible, from the conflict set | Inventing which constraint to relax without approval |
| Generating scenario descriptions to test with | Estimating an objective value |

The safe pattern: model proposes constraints in a **structured schema** (`structured-output`), a human approves them, the solver decides, an independent validator checks feasibility, and the model then narrates the verified result.

---

## 8. Anti-patterns

| Anti-pattern | Consequence |
|--------------|-------------|
| Asking an LLM to solve the assignment | Fluent, infeasible plans presented as optimal |
| No time limit | Requests hang; workers exhausted |
| Every preference as a hard constraint | Permanently infeasible model |
| Unexplained infeasibility returned to users | Nobody can act on it |
| Undocumented penalty weights | Nobody dares change them |
| Non-deterministic solves | Plans change between identical runs; users lose trust |
| Solver on the event loop | The API stalls for the duration of the solve |
| Solution not independently validated | Modelling bugs reach production as valid-looking plans |
| Input data unvalidated before solving | Infeasibility caused by bad data blamed on the model |
| Floating-point money or time in a CP model | CP-SAT is integer-only; scale to minor units and minutes |
| No symmetry breaking with interchangeable resources | Exponential redundant search |
| Rewriting vehicle routing from scratch | Months of work already solved by the routing library |

---

## 9. Checklist

- [ ] Problem confirmed as constrained optimization, not prediction or generation
- [ ] Solver chosen deliberately; routing problems use the routing library
- [ ] Decision variables, hard constraints, and the objective written down before coding
- [ ] Integers and scaled units used throughout a CP model
- [ ] Preferences modelled as weighted penalties; weights in config and documented
- [ ] Input data validated before solving, with business-readable errors
- [ ] Time limit, `random_seed`, and worker count set for reproducibility
- [ ] Best feasible solution accepted; gap and proven-optimality recorded
- [ ] Solution independently validated against constraints in plain Python
- [ ] Infeasibility diagnosed to a minimal conflict set and explained in business terms
- [ ] Solve runs in a worker process, off the event loop
- [ ] Instance size capped at the API boundary
- [ ] Warm start used for stable plans across runs
- [ ] Model version and weights recorded with every produced plan
- [ ] Tests on instances with known optima; feasibility asserted for every returned solution
