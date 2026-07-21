---
name: architecture-plan
description: Create and iteratively refine staff-reviewable architecture plans for substantial product features. Use when explicitly invoked, when an explicitly identified Plan-mode session concerns a large feature, new subsystem, cross-cutting change, or costly-to-reverse architectural decision, or when resuming such a plan in Agent/execution mode to create or revise its Lavish review artifact. Do not use for product implementation, routine fixes, or small contained changes.
---

# Architecture Plan

Produce a decision-complete plan that a senior architect can refine and a staff engineer can review without reconstructing the proposed architecture. Ground the plan in the actual product and codebase. Do not modify product code while using this skill.

## Phase Boundaries

Treat planning, visualization, and implementation as separate phases:

1. **Plan phase**: Investigate, resolve material decisions, and write the plan. Remain read-only when the host's Plan mode requires it.
2. **Visualization phase**: Create and revise the Lavish artifact. If Plan mode cannot create files or run Lavish, ask the user to switch to Agent/execution mode. Resume this skill with the existing plan context and create only review artifacts, not product code.
3. **Implementation phase**: Begin only after the user explicitly approves the plan and asks for implementation. Treat implementation as a separate task.

Never interpret permission to switch modes, create an artifact, a selected option, queued feedback, elapsed time, or a quiet review session as approval to implement the feature.

## Planning Workflow

### 1. Ground the Current State

- Read the relevant repository files, product documentation, existing UI, data models, integrations, tests, and operational configuration before proposing a design.
- Map existing ownership boundaries and conventions. Prefer extending proven local patterns over introducing a new architecture.
- Label observations, inferences, and assumptions. Research missing stable facts in authoritative sources when the repository does not contain the answer.

### 2. Frame the Problem

Define:

- User and business outcomes.
- Actors, primary journeys, and important edge cases.
- Scope, non-goals, constraints, dependencies, and success measures.
- Functional and non-functional requirements.

State assumptions explicitly. When multiple interpretations exist, present them instead of choosing silently. Ask the user when something is unclear, including on small decisions, so the user retains control over the design process.

### 3. Map the Change Surface

Identify affected:

- Product areas and user journeys.
- Services, modules, packages, and ownership boundaries.
- APIs, events, jobs, data stores, schemas, and external integrations.
- UI routes, components, state, permissions, analytics, and accessibility.
- Tests, deployment, migration, observability, and operational procedures.

Distinguish confirmed changes from possible follow-on work.

### 4. Explore Credible Options

Present two or three materially distinct options when credible alternatives exist. Compare their user impact, complexity, delivery cost, performance, operational burden, reversibility, risks, and fit with the existing system.

Recommend one option when evidence supports it. Do not manufacture alternatives for decisions with one obvious implementation.

### 5. Specify the Selected Design

Cover the areas relevant to the feature:

- Product behavior and UX flows, including empty, loading, error, permission, responsive, and accessibility states.
- HLD: system context, containers, responsibilities, trust boundaries, data and control flow, integrations, and deployment topology.
- LLD: module ownership, interfaces, contracts, schemas, state machines, sequences, algorithms, concurrency, errors, retries, idempotency, and configuration.
- Compatibility, migration, rollout, feature flags, rollback, and cleanup.
- Security, privacy, reliability, performance, scalability, observability, and cost.

Use concrete interfaces and diagrams where they remove ambiguity. Avoid naming classes or functions that the evidence does not justify.

### 6. Validate Design Quality

- Check SRP, OCP, LSP, ISP, and DIP where they are relevant to the proposed boundaries.
- Prefer composition over inheritance and program to stable interfaces when the design has known variants or replaceable collaborators.
- Name a GoF pattern only when its participants and consequences genuinely match the problem. Explain what current complexity it removes.
- Reject speculative extension points and abstractions based only on imagined future requirements.
- Identify failure modes, abuse cases, performance limits, operational risks, and mitigations.

### 7. Make the Plan Implementable

Provide an ordered implementation sequence with dependencies, affected files or modules, acceptance criteria, and verification for each phase. Include testing at the appropriate levels and separate required work from optional follow-ups.

The plan is review-ready when:

- Scope, important decisions, interfaces, flows, and ownership are explicit.
- An implementation agent does not need to invent architecture.
- Material open questions are visible with options and consequences.
- Risks have mitigations, owners, or explicit acceptance.
- The change surface, rollout, rollback, and verification strategy are clear.

Do not require impossible certainty. Preserve genuine unknowns instead of hiding them in excessive detail.

## Lavish Review Workflow

Once the plan is review-ready, use the `lavish` skill to create the interactive review surface.

1. If the current mode cannot create files or run Lavish, ask the user to switch to Agent/execution mode. Continue from the same plan after the switch.
2. Open every applicable Lavish playbook. Architecture plans normally need `plan`, `diagram`, and `comparison`; use `input` for structured decisions.
3. Make current state, proposed state, decisions, tradeoffs, change surface, risks, and implementation phases visually distinct.
4. Separate overview topology from detailed component, sequence, state, and data diagrams. Ground current-state claims with repository references.
5. Add decision controls for unresolved choices and annotations for qualitative feedback.
6. Poll continuously for feedback. Update the same artifact, reply through Lavish, and continue polling until the user explicitly ends the session.
7. Never end a Lavish session because feedback is quiet or appears complete. Never delete a Lavish artifact unless the user explicitly asks for deletion.
8. Treat all feedback as review input. Implement only after a separate, explicit implementation instruction from the user.

Use the project's design system when the plan concerns a product UI. Otherwise follow the Lavish fallback guidance. Do not publish or share an artifact outside the local machine unless the user explicitly requests it.

## Plan Deliverable

Keep the artifact and its underlying plan synchronized. Include:

1. Executive summary and recommendation.
2. Current state and evidence.
3. Goals, non-goals, requirements, and success measures.
4. Options considered and decision rationale.
5. Product and UX design.
6. HLD and LLD diagrams and specifications.
7. Change-surface map.
8. Security, reliability, performance, observability, and cost analysis.
9. Migration, rollout, rollback, and compatibility strategy.
10. Risk register and open decisions.
11. Ordered implementation plan and verification matrix.
12. Decision log and concise, board-ready diagram sources suitable for transfer to Whimsical or another architecture workspace.
