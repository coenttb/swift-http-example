# Swift Example Architecture

## Status and authority

This document defines the intended end-state of the `swift-example` canary. It is grounded in the latest architectural decisions from the session that produced the handwritten checkpoint at `97ab849`, including the later adjudications about `Client.Operation`, Application, declarative coders, and the principal ruling that every macro has its own repository and package.

Current source is evidence. It is not authority when it contradicts this document.

The canary exists to discover the smallest reusable algebra for declaring a domain client once and interpreting it locally, remotely over HTTP, and as an HTTP responder. It is not a compatibility exercise. Superseded shapes should be removed as soon as their replacement is proven.

## Objective

The terminal vertical is:

```text
domain models
    -> typed effect signature
    -> concrete client interpretation
    -> representation-specific bidirectional endpoint coders
    -> remote-client and responder interpretations
    -> concrete application assemblies
```

The example must optimize for:

- correct algebra before infrastructure;
- one declaration of each domain operation;
- concrete struct witnesses at runtime;
- declarative composition at authoring sites;
- typed failure provenance;
- minimal direct and transitive dependencies;
- minimal concepts at ordinary call sites;
- no transport knowledge in domain clients;
- no unconditional concurrency or ownership promises;
- deletion of every superseded experiment.

The example is not intended to prove sockets, deployment, a server framework, dependency injection, Foundation coding, or production lifecycle management. An in-memory HTTP transport is sufficient.

## Vocabulary

### Domain

`Example`, `Example.Greeting`, and `Example.Counter` own values, invariants, domain failures, and pure domain behavior. They know nothing about clients, macros, HTTP, CLI, parsers, coders, applications, or transport failures.

Greeting is the infallible operation canary:

```text
Name -> Message
```

Counter is the typed-domain-refusal canary:

```text
Limit -> Value + Counter.Error
```

The pair is intentionally small. Additional subdomains do not strengthen the proof.

### Signature

A package-only Swift protocol named `Signature` is the compiler-readable typed effect signature of a domain:

```swift
extension Example.Counter {
    @Algebra
    @Calls
    package protocol Signature {
        func increment(
            limit: Limit
        ) async throws(Error) -> Value
    }
}
```

In algebraic terms, this is a many-sorted algebraic signature with computational effects. It declares operation symbols and their input, output, failure, effect, label, arity, and ownership syntax. It supplies no implementation.

`Signature` is never the public runtime client abstraction. It must remain:

- package-scoped;
- absent from ordinary consumer call sites;
- unused as an existential;
- unused as dependency-injection vocabulary;
- the single syntax source from which macros derive representations.

### Generic client

The generic effectful arrow is the value named `Client`:

```swift
public struct Client<Input, Output, Failure: Error> {
    public var run: (Input) async throws(Failure) -> Output
}
```

It has a callable surface:

```swift
let output = try await client(input)
```

The current empty `Client` namespace and nested `Client.Operation` are not terminal. They add a concept without adding algebra. `Client.Operation` must collapse into `Client`.

The generic client is structurally a typed asynchronous Kleisli arrow. `Client` is the domain-facing name because the package exists to supply client witnesses; no additional `Operation`, `Arrow`, `Effect`, or `Kleisli` wrapper is needed at call sites.

The first implementation may support only the ownership signatures that are mechanically proven. It must not claim universal `~Copyable` or `~Escapable` support merely by writing constraints that the stored escaping function cannot honor.

### Domain client

A domain client is a product interpretation of a signature. It is concrete and struct-backed:

```text
Example.Greeting.Client
    = interpretation of Greeting.Signature

Example.Counter.Client
    = interpretation of Counter.Signature

Example.Client
    = Example.Greeting.Client x Example.Counter.Client
```

The generated leaf client should preserve the signature's natural method spelling while storing generic clients privately:

```swift
extension Example.Counter {
    public struct Client {
        private let _increment:
            Client::Client<Limit, Value, Error>

        public init(
            increment: @escaping
                (Limit) async throws(Error) -> Value
        ) {
            self._increment = .init(run: increment)
        }

        public func increment(
            limit: Limit
        ) async throws(Error) -> Value {
            try await _increment(limit)
        }
    }
}
```

The module qualification above is schematic. The final generated spelling must compile naturally and must not leak implementation storage into consumer syntax.

`Example.Client` remains a named product rather than a mechanical `Pair` because `greeting` and `counter` are semantic roles. Its source may remain handwritten if generic generation would require another authoring concept solely to save a small named initializer.

### Calls

A call is first-order syntax reifying one operation from a signature. Calls are a coproduct corresponding to the client product:

```text
Client = Greeting handler x Counter handler
Call   = Greeting call    + Counter call
```

`@Calls` is explicit. Not every Swift function signature can necessarily be defunctionalized without losing ownership, lifetime, isolation, or result information. A client must remain derivable even when call reification is unsupported.

For supported signatures, generated call syntax must preserve:

- operation and parameter names;
- parameter order and arity;
- input types;
- output types;
- typed domain refusals;
- `async` and ownership semantics where representable;
- exhaustive elimination;
- lawful prisms for cases used by bidirectional routing.

It must not use `Any`, `any Error`, unchecked casts, or an untyped payload box. If Swift cannot faithfully represent a signature, `@Calls` must diagnose that signature rather than silently weaken it.

For a heterogeneous root call family, generated output and refusal sums are acceptable only at the call-family boundary. Leaf client methods retain their precise output and failure types. The client itself is the interpreter:

```swift
let output = try await client(call)
```

No separate `Application` alias is required merely to rename that generated elimination.

### Remote client

Remote lifting is a pointwise transformation of an operation's failure:

```text
Client<I, O, D>
    -> Client<I, O, Either<R, D>>
```

`D` is the domain refusal. `R` is an external failure supplied by an adapter. The domain client does not acquire a `SourceFailure` or transport generic.

For HTTP, the external row is itself:

```text
Either<TransportFailure, HTTP.Coding.Error>
```

Therefore a fallible remote domain operation exposes:

```text
Either<
    Either<TransportFailure, HTTP.Coding.Error>,
    DomainFailure
>
```

This grouping is intentional:

```text
(transport + coding) + domain refusal
```

An infallible domain refusal is `Never` and may be lawfully collapsed. Collapse helpers must eliminate `Either<X, Never>` or `Either<Never, X>` without changing provenance.

### HTTP endpoint

An endpoint is a pair of lawful bidirectional coders:

```text
RequestCoder:
    DomainInput <-> HTTP.Request

ResponseCoder:
    Either<DomainFailure, DomainOutput> <-> HTTP.Response

Endpoint = RequestCoder x ResponseCoder
```

The same endpoint is interpreted twice:

```text
remote client
    domain input
    -> encode request
    -> transport
    -> decode response outcome
    -> domain output or typed failure

responder
    HTTP request
    -> decode domain input
    -> invoke domain client
    -> encode domain outcome
    -> HTTP response
```

There must not be separate handwritten client routing and responder routing. They are dual interpretations of one endpoint description.

### Transport

An HTTP transport is simply:

```text
Client<HTTP.Request, HTTP.Response, TransportFailure>
```

`HTTP.Client` may remain a role typealias if it materially improves HTTP call sites. `HTTP.Responder` is structurally the same arrow in the same direction. A role alias is acceptable, but it must not introduce a second implementation or a new failure model.

### Application

The current `Example.Application` is structurally another generic client arrow, and its local and remote initializers manually eliminate `Example.Command`. That is not an independent algebra.

Application has two distinct possible meanings:

1. call interpretation, which belongs to the generated client/call algebra;
2. concrete executable assembly, which wires implementations, transports, configuration, lifecycle, CLI, or a server host.

Only the second meaning may retain the word Application.

There is no terminal generic `swift-application` package in this canary unless a distinct reusable value and laws are first demonstrated. Package-name symmetry is not evidence. In particular, an `Application<Input, Output, Failure>` or `Application.Interpreter<Input, Output, Failure>` identical to `Client<Input, Output, Failure>` must not be introduced.

The current `swift-example-application` and `swift-example-application-remote` packages must not survive in their current form. Their `Command`, `Command.Output`, aliases, and manual switches are superseded by generated call syntax and elimination.

## Concrete applications

The architecture supports the following assemblies without conflating them with an Application domain type:

### Local in-process application

Constructs `Example.Client` from local Greeting and Counter implementations and invokes it directly. It imports no HTTP or remote-client package.

### Remote HTTP client application

Accepts an `HTTP.Client<TransportFailure>`, interprets Example endpoints as `Example.Client.Remote<Either<TransportFailure, HTTP.Coding.Error>>`, and invokes the resulting domain-shaped client.

### HTTP responder application

Accepts a local `Example.Client` and interprets the same Example endpoints as HTTP responders. Domain refusal is encoded into the HTTP response; it is not reported as a responder transport failure.

### Local CLI application

Declaratively codes CLI input into generated calls, interprets them with a local `Example.Client`, and declaratively codes call output for the terminal.

### Remote CLI application

Uses the same CLI call syntax but interprets calls with the HTTP-derived remote client.

Only the first three are required for the minimal HTTP canary. CLI support is a subsequent representation canary and must not pull argument-parser or terminal dependencies into the core graph.

## Macro architecture

### Public authoring surface

The normal author declares a package-only signature once:

```swift
extension Example.Greeting {
    @Algebra
    @Calls
    package protocol Signature {
        func greet(_ name: Name) async -> Message
    }
}
```

`@Algebra` always derives the concrete client interpretation. `@Calls` opts into reified syntax and the operations needed to eliminate and route it.

Consumers see generated concrete types and methods. They do not see or traffic in `Signature` existentials.

### Derivations

The derivation vocabulary is:

| Derivation | Responsibility | Nature | Terminal package |
|---|---|---|---|
| `@Witness` | Concrete struct-of-closures interpretation of a signature | Atomic | `swift-witness-derivation` |
| `@Prisms` | One lawful prism per coproduct case | Atomic | `swift-prism-derivation` |
| `@Eliminator` | Universal exhaustive operation out of a coproduct | Atomic | `swift-eliminator-derivation` |
| `@Calls` | Defunctionalized call family plus required result/refusal metadata | Composed | `swift-call-derivation` |
| `@Algebra` | Normal domain-authoring facade over the client derivation | Deliberately composed facade | `swift-algebra-derivation` |
| `@Cases` | Finite case metadata | Orthogonal; deferred | No package until admitted |
| `@Fold` | Catamorphism for recursive data | Inapplicable; excluded | None |
| `@Dual` | Ambiguous bundle of unrelated derivations | Excluded | None |

`@Algebra` and `@Calls` must share the same internal signature model. No macro may carry a second parser or emitter for the same declaration shape.

### Preservation rules

Macros preserve exactly what the signature states. They must never invent:

- `Sendable`;
- `@Sendable`;
- `async`;
- failure widening;
- type erasure;
- isolation;
- ownership conventions;
- HTTP or CLI representation choices.

Unsupported syntax receives a precise diagnostic. Silent degradation is forbidden.

### Package ownership

Every admitted public macro has exactly one semantic owner and exactly one repository/package release boundary. That package contains one public macro declaration, its compiler plugin, its unique derivation contract, diagnostics, expansion tests, and consumer tests. It may expose a non-plugin core product so a composed macro can reuse the derivation without copying its parser or emitter.

The terminal clean-sheet owners are:

- `swift-witness-derivation` for `@Witness`;
- `swift-prism-derivation` for `@Prisms`;
- `swift-eliminator-derivation` for `@Eliminator`;
- `swift-call-derivation` for `@Calls`;
- `swift-algebra-derivation` for `@Algebra`.

There is no `swift-client-macros` package in the terminal graph. A client-themed macro grab-bag combines independently reusable derivations, makes every consumer resolve unrelated plugins, and hides which package owns each expansion contract. The interrupted `swift-client-macros` directory is prototype evidence only. Useful ideas and tests may be rewritten at their terminal owners; the directory, package identity, workspace reference, and manifest dependency must not survive convergence.

This macro layer is a full rewrite. Existing implementations in `swift-declaration-derivation`, `swift-witness-derivation`, `swift-coproduct-derivation`, `swift-defunctionalize`, `swift-dual`, and `swift-witnesses` are prior art only. They may supply counterexamples, terminology, diagnostics, and test cases, but no source is retained merely because it already exists. Reusing the `swift-witness-derivation` repository name does not authorize incremental completion of its current stored-member implementation.

The rewrite may retain `swift-declaration-derivation` only as a rewritten, non-macro compiler substrate if the five macro owners genuinely need one normalized declaration/signature IR, analysis, diagnostics, and SwiftSyntax adapter. It must expose no public macro and no client, HTTP, prism, witness, or call policy. If one macro does not need the shared substrate, it does not depend on it. Because SwiftSyntax and compiler plugins are not L1/Embedded capabilities, the shared substrate and every macro owner belong at a macro-capable Foundations layer; current inventory placement is not terminal authority.

`@Algebra` composes the non-plugin core of `swift-witness-derivation`; it does not redeclare `@Witness`. `@Calls` composes the non-plugin cores of `swift-prism-derivation` and `swift-eliminator-derivation`; it does not redeclare those macros. This is package and implementation composition, not reliance on one macro expanding another macro attribute.

Macro implementation dependencies are compile-time dependencies only. Generated runtime code depends on `swift-client`, domain types, and expressly required algebraic primitives—not on SwiftSyntax or a macro runtime. Handwritten-client consumers depend on none of the derivation packages.

### Macro proof order

1. Rewrite and prove the normalized declaration/signature substrate, if the common substrate earns its existence.
2. Rewrite and prove `@Witness` independently at `swift-witness-derivation`.
3. Rewrite and prove `@Algebra` at `swift-algebra-derivation`, first generating Greeting from one infallible unary signature and then Counter while preserving its typed refusal and argument label.
4. Rewrite and prove `@Prisms` and `@Eliminator` independently at their separate owners.
5. Rewrite and prove `@Calls` at `swift-call-derivation`, composing the two atomic core products and generating output/refusal metadata without `Any`.
6. Prove local generated clients and calls at their intended cross-module call sites.
7. Probe zero-argument and multi-argument operations, labels, typed throws, and overload diagnostics.
8. Probe ownership, lifetime, and isolation syntax; support only mechanically faithful cases.
9. Replace handwritten client and call code only after each owner’s expansion tests and cross-module use are green.

## Declarative coding

### Required authoring style

Endpoint coders must be structural compositions exposed through instance `var body`. They should read like the represented grammar at the point of use.

The intended request shape is schematically:

```swift
extension Example.Greeting.Endpoint {
    public struct Request: Parser.Bidirectional {
        public var body: some Parser.Bidirectional<
            HTTP.Request?,
            Example.Greeting.Name,
            HTTP.Coding.Error
        > {
            HTTP.Request.Coder {
                Method(.post)
                Path {
                    "greeting"
                }
                Body {
                    Name.Coder()
                }
            }
        }
    }
}
```

The exact generic spellings are to be proven against the compiler. The semantic requirements are not provisional:

- request coding is product composition of method, target/path, query, headers, and body;
- response coding is coproduct selection by status composed with body coding;
- constants are stated declaratively;
- variable fields are mapped bidirectionally to domain values;
- representation failures map to one semantic `HTTP.Coding.Error` at the body boundary;
- domain refusal remains data in `Either<DomainFailure, Output>`;
- parse/serialize round trips are lawful and canonical.

`Coder.Witness` is permitted only as an irreducible leaf or temporary compiler probe. An endpoint `body` whose top-level expression is a parse/serialize closure pair is not terminal, even if tests pass.

### Generic and HTTP-specific ownership

`Coder.Protocol` owns the general bidirectional relation. `Parser.Bidirectional` is the specialization where parse input and serialization buffer are the same type.

`swift-http-coder` owns the HTTP-specific structural vocabulary needed to compose request and response models. `swift-example-http` owns only the semantic choices connecting Example operations to that vocabulary.

The current coder-primitives statement that coders are "leaf by design" must not be used to justify imperative endpoint witnesses. Either existing bidirectional parser/serializer combinators lawfully provide the composition, or the missing smallest combinator belongs at its canonical generic or HTTP-specific owner.

Do not create a second HTTP request, response, method, status, target, or path model to make composition easier. `HTTP` remains the user-facing typealias of the canonical RFC 9110 namespace.

### Canonical coders

`Coder.Codable` is used only where a type genuinely has one canonical representation. Domain values may have CLI, HTTP, JSON, form, and database representations. Representation-specific coders remain values owned by their adapter unless one representation is normatively canonical.

## Package graph

The intended runtime dependency direction is:

```text
swift-example                         swift-client
      |                                    |
      +---------- swift-example-client ----+
                         |
swift-client-remote -----+----- swift-example-client-remote
          |
          +---------------- Either Primitives

RFC 9110 <- swift-http <- swift-http-coder
                               |
                 +-------------+-------------+
                 |                           |
         swift-http-client          swift-http-responder
                 |                           |
                 +-------- swift-example-http+

swift-example-client
    |-- compile-time only --> swift-algebra-derivation
    `-- compile-time only --> swift-call-derivation

swift-algebra-derivation --> Witness Derivation Core

swift-call-derivation
    |--> Prism Derivation Core
    `--> Eliminator Derivation Core

each macro owner --> rewritten declaration/signature substrate only when required
```

The macro-side arrows are package dependencies, not generated-runtime dependencies. `swift-example-client` declares only the macro products for attributes written at its source sites. A composed owner imports the smallest non-plugin core product of an atomic owner; it does not import or redeclare the atomic public macro.

The exact direct products must be declared wherever their types or members appear. Transitive visibility is not a dependency strategy.

### Package responsibility matrix

| Package | Owns | Allowed direct dependencies |
|---|---|---|
| `swift-example` | `Example` namespace, Greeting and Counter domain models and failures | None |
| `swift-client` | Generic `Client<Input, Output, Failure>` and its intrinsic invocation operations | None |
| `swift-client-remote` | Generic `Remote`, promotion, and lawful `Never` collapse | `swift-client`, `Either Primitives` |
| Rewritten `swift-declaration-derivation` | Optional shared normalized declaration/signature IR, analysis, diagnostics, and SwiftSyntax adapter; no macro | SwiftSyntax only where the adapter requires it; no client or HTTP policy |
| `swift-witness-derivation` | The single atomic `@Witness` expansion contract and reusable Witness Derivation Core | Rewritten declaration/signature substrate and SwiftSyntax/tooling only as required |
| `swift-prism-derivation` | The single atomic `@Prisms` expansion contract and reusable Prism Derivation Core | Rewritten declaration substrate, canonical optic product, and SwiftSyntax/tooling only as required |
| `swift-eliminator-derivation` | The single atomic `@Eliminator` expansion contract and reusable Eliminator Derivation Core | Rewritten declaration substrate and SwiftSyntax/tooling only as required |
| `swift-algebra-derivation` | The single composed `@Algebra` client-authoring facade | Witness Derivation Core, rewritten signature substrate, and `swift-client` only where its generated contract requires it |
| `swift-call-derivation` | The single composed `@Calls` call-reification facade | Prism and Eliminator Derivation Core products, rewritten signature substrate, and exact algebraic primitives named by generated code |
| `swift-example-client` | Greeting and Counter signatures, generated leaf clients, named root client product | `swift-example`, `swift-client`, `swift-algebra-derivation`, and `swift-call-derivation` |
| `swift-example-client-remote` | Pointwise remote versions and root remote product | Example client products, `swift-client-remote`, `Either Primitives` |
| `swift-http` | Exported HTTP convergence product and `HTTP = RFC_9110` | RFC 9110 only |
| `swift-http-coder` | HTTP coding error, endpoint pair, declarative request/response coder vocabulary | `swift-http` and exact coder/parser/serializer products |
| `swift-http-client` | Remote-client interpretation of an endpoint | `swift-client`, `swift-http`, `swift-http-coder`, exact coding products, `Either Primitives` |
| `swift-http-responder` | Responder interpretation of an endpoint | `swift-client`, `swift-http`, `swift-http-coder`, exact coding products, `Either Primitives` if required by its public algebra |
| `swift-example-http` | Greeting and Counter endpoint descriptions and Example-specific assembly helpers | Exact Example client/domain and HTTP interpretation products; atomic coding/algebraic products only when named directly |

`swift-example-application` and `swift-example-application-remote` are absent from the terminal runtime graph unless they are replaced by concrete executable assembly packages with responsibilities beyond call elimination.

## Dependency discipline

- Package manifests retain GitHub URL dependencies.
- `example.xcworkspace` supplies local package substitution.
- `swift-http` continues to own the `HTTP` namespace as a typealias to RFC 9110.
- No duplicate RFC or HTTP models are permitted.
- No `swift-http-body` or other grab-bag package is permitted.
- Use `Byte Primitive`, not a byte umbrella, when only `Byte` is required.
- `Either`, `Pair`, and `Product` are allowed when they directly express required algebra.
- Named domain products remain named when their fields carry semantic roles.
- Foundation, Dependencies, URLRouting, networking frameworks, server frameworks, and CLI frameworks remain outside the minimal proof unless a demonstrated requirement cannot be met by the canonical atomic owner.
- A new package, product, or target must own an independent concept, dependency cone, or release boundary. A new name around an existing arrow does not qualify.

## Concurrency, ownership, and lifetime

Neither `Client`, a domain client, a coder, nor an endpoint is inherently `Sendable`.

- Do not add `Sendable` or `@Sendable` without an actual shared-concurrency boundary.
- Prefer `sending` for transfer across an isolation boundary when transfer is the semantics.
- Use `borrowing` and `consuming` only where their call semantics and storage are compiler-proven.
- Do not claim `~Copyable` or `~Escapable` support from unrelated fixture types.
- Macro expansion must preserve declared ownership and isolation exactly or diagnose it.
- Tests against synthetic witness types do not prove the public generic `Client` supports those features.

Strict memory safety and language feature flags do not substitute for semantic ownership evidence.

## Laws and required evidence

### Client laws

- Generated clients preserve every supported signature exactly.
- `Example.Client` is the named product of Greeting and Counter clients.
- Remote lifting distributes pointwise over that product.
- `Remote<Never>` lawfully collapses to the corresponding domain client.
- External failure and domain refusal remain observably distinct.

### Coder laws

For every supported value `x`:

```text
parse(serialize(x)) = x
```

For every accepted representation `r`:

```text
serialize(parse(r)) = canonical(r)
```

Endpoint branches are disjoint or have an explicit canonical precedence. Representation errors are semantic at the public boundary rather than exposed as nested combinator tree archaeology.

### Interpretation laws

- Local and HTTP round-trip interpretations produce identical successes.
- Local and HTTP round-trip interpretations preserve identical domain refusals.
- Transport failure remains distinguishable from coding failure.
- Responder interpretation encodes domain refusal as a response outcome.
- Remote and responder interpretations use the same endpoint value.
- No source command or endpoint coder performs building, testing, process launch, or package resolution.

### Dependency evidence

- Every direct dependency is justified by a public or implementation-level type/member use.
- No dependency is retained solely because it was used by a superseded experiment.
- The selected Xcode schemes resolve workspace packages locally while manifests retain URLs.
- The warm workspace verification path remains incremental.

## Current checkpoint disposition

### Keep

- Greeting and Counter as the two domain canaries.
- The domain models and meaningful Counter refusal.
- Generic external/domain failure composition using `Either`.
- `swift-http` as the RFC 9110 convergence product and namespace typealias.
- `HTTP.Endpoint` as a request-coder/response-coder pair.
- Derivation of a remote client and responder from the same endpoint.
- In-memory round-trip and failure-provenance tests.
- The URL-manifest/local-workspace substitution model.

### Rework

- Collapse `Client.Operation` into generic `Client`.
- Rewrite useful lessons and tests from the interrupted `swift-client-macros` prototype at one terminal repository/package per macro; do not repair or mechanically split the aggregate implementation.
- Replace handwritten domain clients with macro-generated concrete clients.
- Make call derivation explicit and typed through `@Calls`.
- Replace top-level endpoint `Coder.Witness` bodies with declarative composition.
- Reduce Example HTTP target imports once HTTP structural coders own path, method, status, and body mechanics.
- Review whether `HTTP.Client` and `HTTP.Responder` aliases improve call sites without duplicating implementation.
- Replace manual remote product boilerplate only when signature reuse can be achieved without reversing package dependencies or adding a runtime macro dependency.

### Delete

- The `swift-client-macros` package identity, directory, workspace reference, and consumer dependency after any uniquely useful uncommitted evidence has been preserved for the rewrite.
- Empty `Client` namespace shell.
- Nested `Client.Operation` spelling after migration.
- `Application` aliases structurally identical to `Client`.
- Manual `Example.Command`/`Output` sums when generated calls supersede them.
- Manual local and remote Application switches.
- `swift-example-application` and `swift-example-application-remote` in their current forms.
- Endpoint-level imperative parse/serialize closure pairs after declarative coders are green.
- Vestigial tests, imports, products, targets, packages, scratch directories, comments, and documentation describing superseded approaches.

## Convergence order

The next implementation round proceeds in architectural dependency order:

1. Freeze the interrupted `swift-client-macros` aggregate and inventory uniquely useful uncommitted evidence without repairing or resolving it.
2. Establish clean working copies for the five terminal macro repositories and, only if proven necessary, the rewritten non-macro declaration/signature substrate.
3. Rewrite the shared substrate first, or reject it and record why independent implementations do not duplicate parsing.
4. Collapse the empty `Client` namespace and `Client.Operation` into generic `Client`; migrate handwritten generic call sites so macro output targets the terminal runtime algebra.
5. Rewrite `swift-witness-derivation`, then rewrite `swift-algebra-derivation` against its core product.
6. Prove `@Algebra` on Greeting, then Counter, with owner-local expansion tests and cross-module Example client tests.
7. Rewrite and prove `swift-prism-derivation` and `swift-eliminator-derivation` independently.
8. Rewrite and prove `swift-call-derivation`, composing the atomic core products without erasure or effect loss.
9. Preserve useful prototype evidence, then remove `swift-client-macros`, its workspace reference, and its consumer dependency before continuing the vertical.
10. Replace handwritten Example clients and call/application switches with generated forms.
11. Delete the current Application packages if no distinct executable responsibility remains.
12. Introduce the smallest declarative HTTP request/response coding vocabulary at the correct owner.
13. Rewrite Greeting endpoint bodies declaratively and prove round-trip laws.
14. Rewrite Counter response choice/refusal coding declaratively and prove failure provenance.
15. Derive remote clients and responders from those same endpoints.
16. Remove every dependency, product, target, file, and test made obsolete by the new vertical.
17. Review the complete call-site syntax and direct/transitive dependency graph before declaring the canary terminal.

Do not migrate unrelated ecosystem macros or create production networking infrastructure. Clean-sheet work is limited to the five terminal macro owners and the one shared non-macro substrate if it passes its ownership test.

## Verification protocol

### Workspace identity gate

Every `example.xcworkspace` FileRef that supplies a package named by a GitHub URL is a
standalone Git repository rooted at that package directory. Its normalized `origin` equals
the manifest URL, its `HEAD` exists, and the remote exists with a root `Package.swift`.
The integration records these identities as submodules while manifests retain canonical URLs.
The complete FileRef/dependency matrix must report zero mismatches before Xcode is opened and
again at terminal handoff; a path dependency or shared parent Git root is never a fallback.

- Use `/Users/coen/Developer/coenttb/swift-institute/swift-example/example.xcworkspace`.
- Use the Codex-Xcode connection; do not invoke `xcodebuild` or raw SwiftPM.
- Never use Institute Build Coordinator, `institute package`, or `.workspace-build-*` for this work.
- Reuse the existing warm workspace/package graph.
- Never reset package caches, delete or edit `Package.resolved`, or create a fresh DerivedData directory per attempt.
- Never run builds concurrently.
- Verify the smallest affected scheme first, then the vertical Example HTTP tests, then each retained package boundary.
- Preserve unrelated dirty and untracked work.
- Do not commit or push unless the user separately requests it.

## Definition of done

The canary is terminal only when a domain author writes no more than:

1. domain values and domain failures;
2. one package-only `Signature` per leaf domain;
3. local operation implementations;
4. declarative representation-specific endpoint bodies;
5. a small named root client product or an equally natural derived composition;
6. concrete assembly wiring.

Everything else is generic or generated:

- operation storage and forwarding;
- call syntax and elimination where requested;
- external/domain failure lifting;
- request execution;
- response outcome handling;
- remote client derivation;
- responder derivation.

The result must demonstrate both operations end to end, preserve `(transport + coding) + domain refusal`, use no top-level imperative endpoint witnesses, contain no duplicate Application arrow, and retain no superseded implementation merely for compatibility.
