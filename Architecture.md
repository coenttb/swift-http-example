# Swift Example Architecture

## Purpose

This workspace is the smallest complete proof of one algebra-first application
vertical:

```text
domain
  -> typed effect signature
  -> generated client and optional calls
  -> generic remote lifting
  -> declarative bidirectional HTTP
  -> remote client and responder
  -> concrete application assembly
```

Each unit exists for one semantic responsibility. There are no compatibility
layers, parallel implementations, generic Application aliases, or aggregate
macro packages.

## Domain

`swift-example` owns the namespace, values, refusals, and pure behavior. It has
no dependencies.

- `Example.Greeting` is the infallible operation
  `Name -> Message`.
- `Example.Counter` is the typed-refusal operation
  `Limit -> Value + Example.Counter.Error`.

Domain code knows nothing about clients, transport, HTTP, coding failures, or
macros.

## Signatures, clients, and calls

Each leaf domain declares one package-only protocol named `Signature`:

```swift
extension Example.Counter {
    @Algebra
    @Calls
    package protocol Signature {
        func increment(
            limit: Example.Counter.Limit
        ) async throws(Example.Counter.Error) -> Example.Counter.Value
    }
}
```

The protocol is compiler input only. It is never a runtime existential or
dependency-injection abstraction.

The universal runtime arrow is:

```swift
Client<Input, Output, Failure>
```

It stores one asynchronous typed-throwing function and is directly callable.
There is no empty Client namespace and no nested `Client.Operation`.

`@Algebra` generates a concrete leaf `Client` as a product interpretation of
the signature. It stores one generic client arrow per operation, preserves the
natural method spelling, and exposes a closure initializer. `Example.Client`
is the handwritten named product of `Example.Greeting.Client` and
`Example.Counter.Client`; its field names are semantic roles.

`@Calls` explicitly reifies the same operations as a `Call` coproduct. The
generated call family preserves labels, arity, input, output, and typed refusal.
It includes:

- lawful case prisms;
- exhaustive `eliminate`;
- precise `Output` and `Failure` metadata;
- direct interpretation by the generated client.

A canonical `Swift.Never` failure remains the empty row; it does not acquire a
generated refusal case.

Unsupported generic, `Self`-dependent, inherited, overloaded,
untyped-throwing, ownership-qualified, isolated, defaulted, or variadic
signature syntax is diagnosed instead of being weakened.

## Macro ownership

There are exactly five public macros and five clean-sheet repositories:

| Macro | Repository | Ownership |
|---|---|---|
| `@Witness` | `swift-witness-derivation` | struct-of-closures witness derivation |
| `@Prisms` | `swift-prism-derivation` | lawful coproduct injections and projections |
| `@Eliminator` | `swift-eliminator-derivation` | exhaustive universal elimination |
| `@Calls` | `swift-call-derivation` | reified call coproduct and metadata |
| `@Algebra` | `swift-algebra-derivation` | domain client derivation |

Each repository exports one public macro only. Witness, Prism, and Eliminator
also export one non-plugin Core product for lawful composition.

`Algebra Derivation Macros` calls `Witness Derivation Core` with generic
client-arrow storage. `Call Derivation Macros` constructs the call enum and
then calls `Prism Derivation Core` and `Eliminator Derivation Core`. Composed
owners do not clone the atomic derivations and do not attach another macro from
their expansion.

SwiftSyntax nodes are the syntactic authority. Each owner analyzes the concrete
declaration shape it needs; there is no lossy Declaration/Type/Source mirror
and no sixth macro-support package. Only the Core and plugin targets that name
SwiftSyntax products depend on those exact products.

Generated prism values use the canonical
`swift-optic-primitives` `Optic.Prism`. The Prism and Call public products
make that generated-runtime dependency available to their consumers.

## Remote lifting

`swift-client-remote` owns the pointwise failure transformation:

```text
Client<I, O, D>
  -> Client<I, O, Either<R, D>>
```

`R` is an adapter failure and `D` remains the domain refusal. `promoted()`
right-embeds domain failure. The two `collapsed()` operations eliminate
`Either<X, Never>` and `Either<Never, X>` without fake failures.

`swift-example-client-remote` applies that transformation to the generated
leaf clients and retains the named root product. Each leaf remote stores its
lifted arrow internally while preserving the domain operation's natural method
spelling. It does not add transport knowledge to a domain client.

For HTTP:

```text
R = Either<TransportFailure, HTTP.Coding.Error>

remote failure
  = Either<
      Either<TransportFailure, HTTP.Coding.Error>,
      DomainFailure
    >
```

The association is intentionally `(transport + coding) + domain refusal`.
Greeting's domain row is `Never` and collapses naturally.

## HTTP and bidirectional coding

`swift-http` owns the user-facing namespace:

```swift
public typealias HTTP = RFC_9110
```

It does not duplicate RFC 9110 models. The vertical uses the RFC request,
response, method, status, target, and body types directly.

`swift-http-coder` owns the HTTP-specific bidirectional vocabulary:

- `HTTP.Coding.Body.Text<Value>` is the irreducible UTF-8 leaf;
- `HTTP.Coding.Request<Content>` is exact method, target, and content;
- `HTTP.Coding.Response.Success<Content>` is an infallible-domain response;
- `HTTP.Coding.Response.Choice<Refusal, Success>` is a disjoint status
  coproduct;
- `HTTP.Endpoint<RequestCoder, ResponseCoder>` is the product of request and
  response coders.

Structural HTTP coders map their content failures to
`HTTP.Coding.Error.request` or `.response`. Domain refusal remains data in
the response coder's `Either<DomainFailure, Output>`.

`swift-example-http` owns only representation choices. Each domain value has
a small HTTP body coder, and each endpoint request or response exposes its
structural composition through `var body`. There is no user-facing top-level
parse/serialize closure pair and no `Coder.Witness` endpoint.

The same endpoint value has two interpretations:

```text
remote client:
  domain input
    -> request serialization
    -> HTTP transport
    -> response parsing
    -> domain output or associated failure

responder:
  HTTP request
    -> request parsing
    -> domain client
    -> response serialization
    -> HTTP response
```

`swift-http-client` owns the first interpretation.
`swift-http-responder` owns the second. Neither duplicates routing syntax.
Both require successful request and response parsers to consume the complete
outer HTTP message.

## Concrete assembly

Application is assembly, not a second universal arrow. The terminal canary has
no `Application<Input, Output, Failure>`, `Example.Command`, or Application
package.

The integration boundary constructs:

1. equivalent local and service `Example.Client` values from the same initial
   state;
2. Greeting and Counter responders from the service client;
3. an in-memory HTTP transport from those responders;
4. the corresponding `Example.Client.Remote`;
5. direct local and HTTP-derived invocations.

This assembly proves distinct local, responder, and remote wiring without
inventing another runtime abstraction or executable lifecycle that the canary
does not need.

## Package graph

The workspace contains these fifteen package identities:

```text
swift-client
swift-client-remote

swift-witness-derivation
swift-prism-derivation
swift-eliminator-derivation
swift-call-derivation
swift-algebra-derivation

swift-http
swift-http-coder
swift-http-client
swift-http-responder

swift-example
swift-example-client
swift-example-client-remote
swift-example-http
```

The essential macro edges are:

```text
swift-algebra-derivation
  -> Witness Derivation Core

swift-call-derivation
  -> Prism Derivation Core
  -> Eliminator Derivation Core
```

In the following complete package graph, every indented arrow is a direct edge
from the nearest unindented package:

```text
swift-client-remote
  -> swift-client
  -> Either Primitives

swift-witness-derivation
  -> SwiftSyntax

swift-prism-derivation
  -> Optic Primitives
  -> SwiftSyntax

swift-eliminator-derivation
  -> SwiftSyntax

swift-call-derivation
  -> swift-prism-derivation
  -> swift-eliminator-derivation
  -> Optic Primitives
  -> SwiftSyntax

swift-algebra-derivation
  -> swift-witness-derivation
  -> SwiftSyntax
  -> swift-client (consumer fixture only)

swift-example-client
  -> swift-example
  -> swift-client
  -> swift-algebra-derivation
  -> swift-call-derivation

swift-example-client-remote
  -> swift-example
  -> swift-example-client
  -> swift-client
  -> swift-client-remote
  -> Either Primitives

swift-http -> RFC 9110

swift-http-coder
  -> swift-http
  -> Byte Primitive
  -> Coder Primitive
  -> Either Primitives
  -> Parser Primitive
  -> Serializer Primitive
  -> RFC 3986 (consumer fixture only)

swift-http-client
  -> swift-client
  -> swift-http
  -> swift-http-coder
  -> Either Primitives
  -> Parser Primitive
  -> Serializer Primitive

swift-http-responder
  -> swift-client
  -> swift-http
  -> swift-http-coder
  -> Either Primitives
  -> Parser Primitive
  -> Serializer Primitive

swift-example-http
  -> swift-example
  -> swift-example-client
  -> swift-example-client-remote
  -> swift-client
  -> swift-client-remote
  -> swift-http
  -> swift-http-coder
  -> swift-http-client
  -> swift-http-responder
  -> Coder Primitive
  -> Either Primitives
  -> Parser Primitive
  -> Serializer Primitive
  -> RFC 3986
```

Manifests name canonical GitHub URLs. Targets declare the exact products whose
types or members they use; transitive visibility is not a dependency strategy.
The graph contains no Foundation convenience dependency, HTTP-body grab bag,
duplicate HTTP/RFC model, rejected macro prototype, or path dependency.
Where only `Byte` is required, the dependency is `Byte Primitive`.

## Laws and evidence

The retained compiler and runtime fixtures prove:

- witness forwarding for infallible and typed-refusal operations;
- zero- and multiple-argument forwarding;
- prism injection/projection and rejection of every other case;
- exhaustive elimination of every coproduct case;
- call composition from Prism and Eliminator cores;
- generated Greeting and Counter clients and call interpretation;
- pointwise remote promotion and both lawful `Never` collapses;
- separation of external failure from domain refusal;
- rejection of malformed UTF-8 before domain decoding;
- rejection of residual request or response body without consuming the outer
  message;
- request and response parse/serialize round trips;
- identical endpoint use for remote-client and responder interpretation;
- distinct transport, coding, and domain failure provenance.

Coders satisfy `parse(serialize(value)) == value` for admitted values. Response
choice statuses are distinct, so serialization cannot select a different parse
branch.

No type in this vertical gains unconditional `Sendable`, `@Sendable`,
`~Copyable`, or `~Escapable` claims merely for generality. Such constraints
belong only at an actual semantic or compiler boundary.

## Workspace identity gate

Every package supplied by `example.xcworkspace` for a canonical URL identity
is a standalone Git repository rooted exactly at its FileRef directory.
Before Xcode is opened and again at handoff, a mechanical audit checks every
workspace FileRef, submodule, and locally represented URL dependency for:

1. an exact package root and root `Package.swift`;
2. an exact `.git` root at that directory;
3. a nonempty `HEAD`;
4. an `origin` equal to the normalized canonical manifest URL;
5. an existing remote with a root `Package.swift`.

Optional trailing `.git` is ignored only during URL normalization. Multiple
canonical package identities may not share a parent Git root. A path dependency
is never a fallback.

The terminal matrix is:

```text
workspace_refs=15
submodules=15
local_url_checks=29
mismatches=0
remote_checks=15
remote_mismatches=0
```

After this gate passes, Xcode is allowed to read the local substitutions.

## Verification protocol

Authoritative compiler and runtime evidence comes only from the warm workspace:

```text
/Users/coen/Developer/coenttb/swift-institute/swift-example/example.xcworkspace
```

Use the Codex-Xcode connection. Never use `xcodebuild`, raw SwiftPM
build/test/package administration, Institute Build Coordinator, generic UI
automation, a fresh DerivedData directory, concurrent builds, or cache and
package-graph resets. Do not edit, copy, or delete `Package.resolved`.

Verify the smallest affected scheme after each dependency-ordered checkpoint,
then the complete Example HTTP vertical. Commit and push only ordinary
compiler-proven checkpoints with the configured human Git identity.
