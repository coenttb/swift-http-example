# swift-example — decisions

Status: generic-algebra iteration (2026-08-25). HTTP adapter is a preserved,
excluded spike; see the final section.

## Generic algebra owners

- `swift-client` (family root; canonical home would be swift-foundations)
  owns `Client.Operation<Input, Output, Failure>` — the atomic operation row
  as a stored-closure witness with `callAsFunction`. Dependency-free.
- `swift-client-remote` owns the remote lift as lawful transformations:
  `Operation.Remote<External> = Operation<Input, Output, Either<External, Failure>>`
  (a parameterized member typealias), `promoted()` (embed a domain row into a
  remote row, refusal on the right), and two `collapsed()` witnesses of
  `T ⊕ Never ≅ T` (one per side). Depends on swift-client + either-primitives.
- `Application.Interpreter<Input, Output, Failure>` was added to the existing
  canonical `swift-application-primitives` (uncommitted local edit; no new
  Example-owned abstraction, no dependency added). `Example.Application<F>` is
  now a generic-instantiation typealias of it, and its local/remote
  constructors live in the application core and remote application packages
  respectively.
- Discovery: inside a type *named* `Client` (every domain's nested client),
  the self-name shadows the top-level `Client` namespace with no lookup
  fallback, and module qualification cannot rescue it while the module is also
  named `Client`. The module-selector spelling `Client::Client.Operation`
  resolves it and is now used in the two subclient struct bodies; enclosing-name
  shadowing (inside `Remote`) resolves without it. Macro-generated rows will
  need the selector spelling.

## Domain vocabulary, not envelopes

Operations use actual domain values — `Greeting.Name → Greeting.Message`,
`Counter.Value × Counter.Limit → Counter.Value throws Counter.Error`. There are
no `Request`/`Response` envelope types anywhere. `Example.Counter.Error` is a
domain refusal and lives in the domain package. Rejected along the way:
domain-level envelopes in `swift-example`, and client-owned envelopes
(`Example.Greeting.Client.Request`) — both standardized operations into
transport-shaped words the domain does not have.

## Client algebra

- `Example.Greeting.Client` / `Example.Counter.Client` are handwritten struct
  witnesses storing one effect arrow each, at the honest domain effect row:
  greet is infallible, increment throws only `Example.Counter.Error`.
- `Example.Client = Greeting.Client × Counter.Client`, a concrete named
  product (named because the fields have domain roles; not `Pair`).
- The client package is interfaces-only. Local interpretation
  (`Example.Client.local`) lives in the `Example Client Local` target of the
  application package, so importing `Example Client` imports no implementation.

## Remote algebra

- `Client.Remote<Failure>` is a distinct type per client because a remote
  witness throws more than the domain client; the parameter is named
  `Failure` (not `TransportFailure`) because it is the complete non-domain
  failure and may itself be `Either<TransportFailure, ProtocolFailure>`.
- Rows: `greet: (Name) async throws(Failure) → Message` (⊕ Never elided);
  `increment: (Value, Limit) async throws(Either<Failure, Counter.Error>) → Value`.
- `Example.Client.Remote<F> = Greeting.Client.Remote<F> × Counter.Client.Remote<F>`,
  built componentwise; the dependency graph mirrors the product.
- `Remote<Never> ≅ Client` is an explicit isomorphism (two initializers, both
  directions tested, refusal preserved) — not a definitional identity.
- Rejected remote spellings: `Client<Example.Client>.Remote<T>` and
  `Client.Remote<Example.Client, T>` — Swift extensions cannot add stored
  properties and constrained extensions cannot nest types, so a generic client
  has nothing lawful to store without erasure. Generic `swift-client` /
  `swift-client-remote` packages therefore remain unproven and uncreated.

## Application algebra

- `Example.Command = greet(Name) + increment(Value, Limit)`;
  `Example.Command.Output = greet(Message) + increment(Value)`;
  `Example.Command.Error = counter(Counter.Error)` (the refusal join).
- `Example.Application<Failure>` is a witness storing
  `interpret: (Command) async throws(Failure) → Output`.
  Local construction (`init(_ client: Example.Client)`,
  `Failure == Command.Error`) lives in the application core, which depends only
  on domain and client. Remote construction
  (`init(_ remote: Client.Remote<F>)`, `Failure == Either<F, Command.Error>`)
  lives in the remote application package. Local execution is not
  remote-shaped; an earlier interpreter defined only over `Remote<F>` was
  rejected for exactly that coupling.
- Finding, as requested: each Application constructor is a fold of the command
  sum through the client product — pure forwarding plus refusal-injection. The
  fold is written twice because Swift cannot abstract over the two effect rows
  (`E` vs `Either<F, E>`) without erasure. The witness itself still earns its
  place: it is what lets both mains be identical wiring. The duplicated fold is
  the precise target for the macro commission.
- CLI is an adapter target: argv → `Example.Command` (plain handwritten
  parser; the `Parser.Protocol` conformance was removed as not part of the
  proof) and `Output.line` rendering. `Example.Command.Parser.Error` is the
  parse failure vocabulary.

## Either

`Either` from swift-either-primitives is the only external algebraic
dependency in the checkpoint graph (its cone resolves 9 pins total). It carries
both sums: `Either<Failure, Counter.Error>` at the operation row and
`Either<F, Command.Error>` at the application row. `Either<_, Never>` /
`Either<Never, _>` collapses use the ecosystem's own `.value` accessors.

## Boilerplate remaining after the generic algebra (macro discovery)

What `Client.Operation` / `Application.Interpreter` could not absorb, and a
macro plausibly can:

- The domain client structs themselves: one stored `Client.Operation` row per
  operation, the memberwise initializer, and the `Client::` selector spelling.
- The `Remote<Failure>` twins: same rows with `Failure` applied —
  refusable rows via `.Remote<Failure>`, infallible rows by substituting the
  failure parameter directly (the collapsed spelling).
- The componentwise product composition of root client and root remote.
- The `Remote<Never> ≅ Client` initializer pair (today: `promoted()` /
  `collapsed()` per refusable row, pass-through per infallible row).
- The interpreter fold written twice (local `Failure == Command.Error`, remote
  `Failure == Either<External, Command.Error>`) because Swift cannot abstract
  over the two effect rows without erasure.
- Named input products like `Counter.Increment` restore argument labels lost
  by single-input rows; labeled forwarding methods collide with the stored
  property name and were dropped — a macro could generate them under a
  distinct spelling if wanted.

## HTTP (deferred spike)

`swift-example-http` is preserved on disk but excluded from the workspace and
from all checkpoint dependency graphs; it is not resolved or compiled. Its
lessons, recorded for the adapter iteration:

- `Example.HTTP` and `Example.Remoting` are wrong namespaces — HTTP vocabulary
  belongs to the HTTP-owned packages (`HTTP.Router`, `HTTP.Transport`,
  `HTTP.Exchange`, `HTTP.Body.Coder`), which must be reused, not shadowed.
- A generic operation descriptor whose `Refusal == Never` case stores a dummy
  refusal status and an always-throwing coder violates `T ⊕ Never ≅ T`; the
  `Never` case must structurally eliminate those slots. Extraction of any
  generic HTTP-operation form (e.g. `HTTP.Client<Example.Client>`) waits until
  two concrete endpoints prove a representation without impossible data.
- Snapshot of the spike: `.snapshots/spike-http-vertical-2026-08-25.tar.gz`.
