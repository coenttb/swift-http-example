# Swift Example Architecture

Ratified 2026-08-26. This document is the controlling design for the next
iteration of the workspace. Where the checked-out code differs, the code is a
checkpoint and this document is the authority; §Convergence sequences the gap.

## Purpose

This workspace is the smallest complete proof of one algebra-first application
vertical:

```text
domain
  -> typed effect signature
  -> derived client and call coproduct
  -> declarative bidirectional route
  -> typed response coding
  -> one server entry point, typed remote clients
  -> concrete application assembly
```

The canary exists to minimize the marginal cost of the Nth domain and the Mth
operation, across many transports and surfaces. Every unit must earn its
existence; the design deliberately introduces no new nominal concepts beyond
the existing institute algebra: enums, coders, prisms, eliminators, and the
universal client arrow.

## The factoring

There is one front door. A request is decoded into a reified value that says
which operation it addresses, with its data; that value is eliminated
exhaustively; each branch responds through its operation's typed response
coder:

```text
server = respond ∘ eliminate ∘ parse

1. parse:     HTTP.Request  -> Example.Call        (one router, one entry point)
2. eliminate: Example.Call  -> per-case branch     (compiler-forced exhaustive)
3. respond:   typed outcome -> HTTP.Response       (per-operation response coder)
```

This is the RepoTraffic factoring — parse into a route coproduct, switch,
respond — rebuilt on institute foundations: the coproduct is derived by
`@Calls` instead of handwritten, case embedding uses derived prisms instead of
`@Cases`, dispatch uses the derived eliminator (or a plain exhaustive
`switch`) instead of an unchecked convention, and — unlike RepoTraffic —
request bodies, responses, and typed refusals live inside the algebra rather
than out of band.

Three properties decide this factoring over per-operation endpoint values:

1. **Fewest concepts.** No `HTTP.Endpoint`, no first-match responder
   composition, no cross-responder no-match protocol. Dispatch is `OneOf`
   inside one router; branching is a coproduct eliminator.
2. **Compile-time exhaustiveness.** Adding an operation regenerates `Call`;
   every eliminator/switch fails to compile until the new case is handled. An
   unmounted operation cannot be a silent 404.
3. **`Call` is the transport-independent pivot.** It is derived from the
   `Signature` and knows nothing about HTTP. Each surface — HTTP, CLI argv,
   app deep links — is one bidirectional coder into the same `Call`.

## Domain

`swift-example` owns the namespace, values, refusals, and pure behavior. It
has no dependencies.

- `Example.Greeting` is the infallible operation `Name -> Message`.
- `Example.Counter` is the typed-refusal operation
  `Limit -> Value + Example.Counter.Error`.

Domain code knows nothing about clients, transport, HTTP, coding failures, or
macros. No domain value gains unconditional `Sendable`.

## Signatures and derivation

Each leaf domain declares one package-only protocol named `Signature`, with
both derivations attached:

```swift
extension Example.Counter {
    @Algebra          // terminal name: @Client — see §Macro ownership
    @Calls
    package protocol Signature {
        func increment(
            limit: Example.Counter.Limit
        ) async throws(Example.Counter.Error) -> Example.Counter.Value
    }
}
```

The protocol is compiler input only. `@Algebra` derives the concrete leaf
`Client` (client-arrow storage, natural method spelling, closure initializer,
and — because `@Calls` is present — direct call interpretation). `@Calls`
derives the `Call` coproduct with lawful case prisms, exhaustive `eliminate`,
and `Output`/`Failure` metadata. The universal runtime arrow remains
`Client<Input, Output, Failure>`.

The root is the coproduct and product of the leaves. Terminal state: derived
from a root `Signature` whose members are property requirements. Interim
state, buildable with today's macros: a handwritten five-line root enum wearing
the atomic derivations —

```swift
extension Example {
    @Prisms
    @Eliminator
    public enum Call {
        case greeting(Example.Greeting.Call)
        case counter(Example.Counter.Call)
    }
}
```

— alongside the existing handwritten `Example.Client` product. No other
handwritten mirrors are terminal: the remote products in
`swift-example-client-remote` remain only until `@Remote` lands (§Macro
ownership).

## Macro ownership

One macro per repository; no aggregate macro package; macros are named for
what they generate.

| Macro | Repository | Derives |
|---|---|---|
| `@Witness` | `swift-witness-derivation` | struct witness of a protocol; gains property-requirement support (a protocol witness includes property witnesses) |
| `@Client` (today `@Algebra`) | `swift-algebra-derivation` (repo rename principal-gated) | the client-arrow witness of a `Signature`; with property support, root products |
| `@Calls` | `swift-call-derivation` | the `Call` coproduct + prisms + eliminator + metadata; gains property-requirement support so a root `Signature` derives the root `Call` |
| `@Prisms` | `swift-prism-derivation` | lawful case optics (used directly on the interim root enum) |
| `@Eliminator` | `swift-eliminator-derivation` | exhaustive elimination; gains effect-polymorphic variants (async, typed-throws branches) for server dispatch |
| `@Remote` | `swift-remote-derivation` (new) | the `Either<External, Failure>`-row mirror of the same `Signature`, co-attached like `@Calls`; generated code depends on `swift-client-remote`, which remains the semantic owner of `promoted()`/`collapsed()` |

`@Calls` rejoins this vertical as a load-bearing dependency: the route
coproduct it derives is what RepoTraffic hand-wrote. The name `@Algebra` is
retained only until the rename lands; by this family's own convention the
macro that generates `Client` is `@Client`.

Macros expand where the `Signature` text lives; nothing can derive from a
protocol declared in another module.

Generated code spells every macro-introduced type reference by its full name,
module-anchored with the module-selector spelling (`Module::Type.Nest`)
wherever the macro knows the module — expansions land in arbitrary lexical
contexts and must be immune to shadowing at the expansion site. `Swift`
vocabulary is spelled `Swift.Never`, `Swift.Void`. Author-supplied types from
the attached declaration are reproduced verbatim, since a syntax-only macro
cannot know their modules. Until SwiftSyntax grows a module-selector node,
the `Module::` tokens are emitted via the splice already proven in the
`@Algebra` implementation.

## Routes

Each domain declares one router: a bidirectional coder between HTTP requests
and the domain's `Call`. Declarative composition, generic combinators, derived
prisms:

```swift
extension Example.Counter {
    @Parser.Builder
    public static var router: some Coder<HTTP.Route.Input, Call, HTTP.Route.Input, HTTP.Route.Error> {
        OneOf {
            HTTP.Route.Case(Call.prisms.increment) {
                HTTP.Route.Method(.post)
                HTTP.Route.Path { "counter" }
                HTTP.Route.Body(Example.Counter.Limit.coder)
            }
        }
    }
}
```

Rules:

- **Strings appear exactly once**, at the declaration. Every consumer — the
  server, remote clients, link generation — goes through the typed router
  value. No use site anywhere spells a path.
- **Typed captures** bind path segments, query fields, and header fields
  through bidirectional conversions (`Path { "referral"; Code.segment }`,
  `Query.Field("q") { Query.conversion }`). Whole-target equality is only the
  degenerate literal case.
- **Bodies are in-band**: `HTTP.Route.Body` lifts a value coder; a request's
  payload is part of its route branch, never attached afterward.
- **Mounting is composition**: the root router is `OneOf` over leaf routers,
  each behind its path prefix and embedded into `Example.Call` through the
  root prisms. Prefixes are declared once, at the mount.
- `HTTP.Route.Input` is the structured consumption record (method, decoded
  path segments, ordered query pairs, headers, body bytes) — components are
  split before percent-decoding; `%2F` is never a separator. Routers are
  typed over the record, because mounting composes there (a prefix consumes
  decoded segments); the `HTTP.Request?` boundary is crossed exactly once,
  at the root mount. Leftover-query strictness (ruled): after the alternation
  selects, surplus input is `malformed`, checked at the mount, never
  per-branch; where one branch's consumed query set is a subset of a
  sibling's, more-specific-first ordering is mandatory and the law suite
  pins it.
- `HTTP.Route.Error` distinguishes `noMatch`, `malformed`, and `unprintable`.
  `OneOf` continues past `noMatch` only.

The `HTTP.Route` nest is deliberately transitional vocabulary: it seeds the
ratified `swift-routers` shape (`Router.Protocol` = `Coder` where
`Buffer == Input`; structured `Router.Input`) and converges there when that
package lands. Routes live in per-domain `Route` products so that link-only
consumers (websites, apps, CLIs) never import response coders or clients
beyond `Call`.

## Responses

Each operation declares one response coder — the piece RepoTraffic left out of
its algebra. Refusal and success statuses are stated once, and both directions
are owned:

```swift
extension Example.Counter.Response {
    public static let increment = HTTP.Response.Coder.choice(
        refusal: (.badRequest, Example.Counter.Error.text),
        success: (.ok, Example.Counter.Value.coder)
    )
}
```

- `HTTP.Response.Coder` owns the family: a single-status `Branch` leaf
  (status match × content focus) and `Success`/`Choice` shapes whose bodies
  are composed from generic combinators (`OneOf`, `Converted`) — no
  `Body == Never` implementation may hide handwritten dual parse/serialize
  where composition exists. Distinct statuses on a choice remain a
  precondition, so serialization can never select the other parse branch.
- Response coders parse to `Either<Refusal, Output>`; `Success` fixes the
  refusal row at `Never`.
- Errors are subject-owned: `HTTP.Route.Error` for the request side,
  `HTTP.Response.Coder.Error` for the response side. The interpretations'
  combined channel is the plain `Either` of the two — aliased for ergonomics,
  never a new nominal error type.

### Value coding

`Coder.Codable` conformance asserts an **intrinsic** representation — the
value's own canonical text/byte form, stable across transports and versions.
Wrapper values pass (`Name` ↔ its string, `Limit`/`Value` ↔ decimal text).
Context-dependent wire choices fail the test and use named representation
values instead: encoding `Example.Counter.Error` as the bare reached-limit
number is an HTTP choice, so it is the named `Example.Counter.Error.text`, and
the global conformance slot stays free.

## Failure algebra

Unchanged and non-negotiable:

```text
remote failure = Either<Either<TransportFailure, coding failure>, DomainFailure>
```

The association is `(transport + coding) + domain refusal`. Domain clients are
transport-independent and never acquire a generic source failure. `Never` rows
collapse inside the generic interpretation owners; `collapsed()`/`promoted()`
are public laws of `swift-client-remote`, not call-site ceremony.

## Interpretations

**Server** — application assembly, one entry point:

```swift
let respond: (HTTP.Request) async throws -> HTTP.Response = { request in
    switch try Example.router.parse(request) {           // or Call.eliminate once effect-polymorphic
    case .greeting(.greet(let name)):
        return try Example.Greeting.Response.greet.serialize(.right(await service.greeting.greet(name)))
    case .counter(.increment(let limit)):
        return try await HTTP.respond(Example.Counter.Response.increment) {
            try await service.counter.increment(limit: limit)
        }
    }
}
```

`HTTP.respond` is the one generic helper: run a typed-throwing service, fold
the outcome into `Either`, serialize. Mapping `noMatch` to 404 and `malformed`
to 400 is **application policy at this edge**, never part of the generic
algebra; `swift-http-responder` may ship an overridable default, labeled as
policy.

**Remote client** — per-operation typed arrows from the same declarations:

```swift
let remote = Example.Client.Remote(
    greeting: .init(greet: HTTP.client(
        router: Example.router, case: Example.Call.prisms.greeting.appending(Example.Greeting.Call.prisms.greet),
        response: Example.Greeting.Response.greet, transport: transport
    )),
    ...
)
```

`swift-http-client` owns the generic arrow builder — print the call through
the router, execute, parse through the operation's response coder — plus the
`Refusal == Never` overload that pre-collapses. `HTTP.Client<Failure>` and
`HTTP.Responder<Failure>` remain typealiases of the universal arrow; natural
`send`/`respond(to:)` spellings are constrained extensions, not derived
nominal types. `HTTP.Transport` (streaming plane, canonical owner) is a
separate contract and is not collapsed into this vertical.

**Loopback**: the assembled server function is a lawful transport
(`HTTP.Client(run: respond)`), proving local, served, and remote behavior
equivalent from one set of declarations.

## Bodies

Two planes, one bridge:

- **Materialized plane** (this vertical): `HTTP.Request`/`HTTP.Response` with
  `body: [Byte]?` — equatable values on which the coder laws are provable.
  `[Byte]` is the canary's instantiation, not a claim that the terminal coding
  contract is array-bound.
- **Streaming plane** (canonical, out of scope here): move-only bodies with
  `none`/`bytes`/`stream` structure and bounded materialization as the single
  bridge. Convergence is blocked on repairing the canonical owner's head
  (`Body`-as-generic-value versus `Body`-as-coder-namespace collision;
  recommended resolution `HTTP.Message.Body<Failure>`) and is upstream work,
  not this workspace's.

## Naming

- Domain first, `Nest.Name`, no compound names except spec-mandated terms.
- Deleted vocabulary: `HTTP.Coding` (taxonomy by mechanism), `HTTP.Endpoint`
  (dissolved — its atoms are the router branch and the response coder),
  per-domain `Endpoint`/`Request`/`Response` shells, `Coder.Witness` shells.
- Never nest a type named `HTTP` inside a domain (`Example.Counter.HTTP`
  shadows the global facade); per-domain HTTP artifacts use `router` and a
  `Response` nest.
- `swift-http` remains the ruled owner of the user-facing namespace:
  `public typealias HTTP = RFC_9110`, depending on `swift-rfc-9110` only. RFC
  types are used directly; no RFC model is duplicated.

## Package graph

Fifteen workspace identities, one addition pending (`swift-remote-derivation`).
Roles after convergence:

```text
swift-client                universal arrow (unchanged)
swift-client-remote         failure-row lift laws (unchanged)
swift-http                  HTTP = RFC_9110 facade (ruled, unchanged)
swift-http-coder            HTTP.Route.* (Input, leaves, Case, Error) +
                            HTTP.Response.Coder family; HTTP.Coding deleted
swift-http-client           HTTP.Client alias + generic remote-arrow builder
swift-http-responder        HTTP.Responder alias + HTTP.respond helper +
                            labeled default edge policy
swift-witness-derivation    + property requirements
swift-algebra-derivation    @Algebra -> @Client (repo rename principal-gated)
swift-call-derivation       rejoins the vertical; + property requirements
swift-prism-derivation      unchanged; used by the interim root enum
swift-eliminator-derivation + effect-polymorphic eliminate
swift-example               unchanged
swift-example-client        Signatures (@Algebra @Calls), interim root enum,
                            root Client; re-adds Call/Prism/Eliminator deps
swift-example-client-remote retained until @Remote lands, then dissolves
swift-example-http          per-domain Route products + Response products;
                            endpoint/value-coder shells deleted
```

Manifests name canonical GitHub URLs; the workspace provides local
substitution; a path dependency is never a fallback. Targets declare exactly
the products they use. `Package.resolved` is generated state.

Upstream, outside this workspace but blocking it: the staged bidirectional
coder conformances in `swift-coder-primitives` (`Take`/`Skip`/`OneOf`/
`Converted`/`Error.Map` as coders; `Coder.Element` leaves) and
`swift-parser-primitives` (`Parser.Error.Map` member access) must land on
`main` before the declarative router composition can compile here.

## Laws and evidence

- coder round trips: `parse(serialize(value)) == value` for admitted values,
  canonical serialization, residual-input rejection, malformed-UTF-8 rejection;
- **router coverage**: for every `Call` case, print-then-parse round-trips —
  enumerated through the eliminator so a missing router branch fails the law
  suite (branch coverage is a law, not a type; this is the one residual gap of
  the reified-coproduct factoring and it is tested, not assumed);
- exhaustive dispatch by construction (a new operation breaks every
  eliminator/switch until handled);
- typed refusal, transport, and coding failures remain distinguishable end to
  end; both `Never` collapses hold;
- local, served, and remote invocations agree through the loopback transport;
- prism/eliminator/witness laws as before.

No type gains unconditional `Sendable`, `@Sendable`, `~Copyable`, or
`~Escapable` outside an actual semantic or compiler boundary. New test targets
follow one test target per target (`<Target> Tests`).

## Convergence

Dependency-ordered; each milestone ends at a compiler-proven, committable
checkpoint. Spike gates escalate to the outer loop before proceeding.

- **M0** Verify the committed checkpoint in the warm workspace (the current
  HTTP reduction has no authoritative compiler evidence yet).
- **M1** (upstream, outer-loop coordinated) Land the staged primitives
  conformances; re-resolve here.
- **M2** `swift-http-coder`: `HTTP.Route.Input`, leaf coders, `Case` node
  (prism→conversion bridge — spike: partial unapply through `Converted`),
  `HTTP.Route.Error`. Delete `HTTP.Coding` request/target-equality path as the
  routers replace it.
- **M3** `HTTP.Response.Coder` family with composed bodies; migrate value
  coders per the intrinsic rule (`Error.text` becomes a named value).
- **M4** Re-add `@Calls` to the Example signatures; interim root enum with
  `@Prisms @Eliminator`; per-domain routers; root router with mounting.
- **M5** Server entry point (exhaustive switch interim), `HTTP.respond`
  helper, remote-arrow builder + `Never` overload; rewire the vertical test to
  the single front door; delete endpoint-era files.
- **M6** Law suite: case-enumerated router coverage, loopback equivalence,
  provenance tests.
- **M7** Macro capabilities, each spike-gated: effect-polymorphic
  `eliminate`; property requirements in Witness/Calls (root derivation);
  `@Client` rename (macro + products; repo URL rename remains
  principal-gated); `@Remote` + dissolution of
  `swift-example-client-remote`.
- **M8** Cleanup: naming sweep, manifest prune, this document's status notes,
  workspace identity gate re-run.

## Workspace identity gate

Every package supplied by `example.xcworkspace` for a canonical URL identity
is a standalone Git repository rooted exactly at its FileRef directory. Before
Xcode is opened and again at handoff, the mechanical audit checks every
FileRef, submodule, and locally represented URL dependency for: exact package
root and root `Package.swift`; exact `.git` root; nonempty `HEAD`; `origin`
equal to the normalized canonical manifest URL; an existing remote with a root
`Package.swift`. Multiple canonical identities may not share a parent Git
root. A path dependency is never a fallback.

## Verification protocol

Authoritative compiler and runtime evidence for this workspace comes only from
the warm `example.xcworkspace` via the Xcode connection. Never use
`xcodebuild`, raw SwiftPM build/test, the Institute Build Coordinator, generic
UI automation, a fresh DerivedData directory, concurrent builds, or cache and
package-graph resets. Do not edit, copy, or delete `Package.resolved`. One
build system per checkout.

Work in the primitives repositories (M1) is fleet work and uses
`institute package build|test --fresh` there, per Institute rules.

Verify the smallest affected scheme after each dependency-ordered checkpoint,
then the complete Example HTTP vertical. Commit only compiler-proven
checkpoints, with the configured human Git identity, no AI attribution, and
explicit pathspecs. Never force-push; never tag; pushes beyond the standing
posture and repository renames require principal approval.
