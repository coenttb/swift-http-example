# Swift Example Architecture

This workspace is the handwritten syntax canary for one reusable vertical:

```text
domain → client algebra → bidirectional HTTP coding → application
```

The checked-in Swift sources are the proposal. They intentionally express the
desired call sites before generic upstream infrastructure is changed. This
checkpoint is therefore structural and has not yet earned compiler evidence.

## Packages

| Package | Owns |
|---|---|
| `swift-example` | Domain namespaces, values, refusals, and pure behavior |
| `swift-example-client` | Transport-independent signatures and their derived clients and calls |
| `swift-example-http` | Intrinsic value coders, request routers, and response coders |
| `swift-example-application` | Live client interpretation and application assembly |

`swift-example-client-remote` is absent. A remote client is an interpretation
of the same client algebra, not another handwritten domain mirror.

Generic client, HTTP, coder, and derivation packages are upstream dependencies.
They remain read-only during this syntax pass.

## Domain

`swift-example` has no dependencies. `Example.Greeting` demonstrates an
infallible operation. `Example.Counter` demonstrates a typed domain refusal.
Neither domain knows about clients, HTTP, coding failures, or transport.

## Client algebra

Each domain declares only its effect signature:

```swift
extension Example.Counter {
    @Client
    @Calls
    package protocol Signature {
        func increment(limit: Limit) async throws(Error) -> Value
    }
}
```

The root composes subdomain clients through property requirements:

```swift
extension Example {
    @Client
    @Calls
    package protocol Signature {
        var greeting: Greeting.Client { get }
        var counter: Counter.Client { get }
    }
}
```

`@Client` derives the client product, natural methods, initializers, call
interpretation, and the generic remote interpretation. `@Calls` derives the
call and result coproducts, their case optics, and exhaustive composition.
Prisms and elimination are composed implementation capabilities, not extra
domain-author concepts.

The universal effectful arrow remains the semantic runtime primitive. Domain
clients never acquire a transport or source-failure generic.

## HTTP

Request routing and response coding are separate bidirectional declarations:

```text
HTTP.Request ⇄ Example.Call
Example.Call.Result ⇄ HTTP.Response
```

The root router mounts subdomain routers:

```swift
HTTP.Request.Coder(Example.Call.self) {
    OneOf {
        Case(\.greeting) {
            HTTP.Request.Path { "greeting" }
            Example.Greeting.router
        }
        Case(\.counter) {
            HTTP.Request.Path { "counter" }
            Example.Counter.router
        }
    }
}
```

Responses compose independently:

```swift
HTTP.Response.Coder(Example.Counter.Call.self) {
    Case(\.increment) {
        OneOf {
            HTTP.Response.Status(.badRequest) {
                HTTP.Response.Body(Example.Counter.Error.text)
            }
            HTTP.Response.Status(.ok) {
                HTTP.Response.Body(Example.Counter.Value.coder)
            }
        }
    }
}
```

This separation leaves a normal application seam between routing and response
transport. Authentication, logging, headers, caching, and other higher-level
behavior can inspect the request and call, invoke the application, and modify
the response without being embedded in the route declaration.

Value representations are ordinary declarative coders with `var body`.
Intrinsic representations use `Coder.Codable`; contextual representations use
a named coder such as `Example.Counter.Error.text`.

There is no `HTTP.Coding`, `HTTP.Endpoint`, domain `Endpoint` shell, or
`Operation.Witness` in the example.

## Application

The application owns the live domain interpretation and the assembly step:

```swift
let client = Example.Client.live

let server = HTTP.Server(
    router: Example.router,
    respond: { call, request in
        let response = try await Example.response(to: call, using: client)
        return response.addingHeader(...)
    }
)

let remote = Example.Client.remote(
    over: server.client,
    router: Example.router,
    responses: Example.responses
)
```

Local and remote callers use the same domain-shaped client:

```swift
let message = try await remote.greeting.greet(.init("Ada"))
```

The remote failure association remains:

```text
(transport + coding) + domain refusal
```

The algebra owns that association. It is not exposed as call-site promotion,
collapse, or generic ceremony.

## Marginal domain cost

Adding a leaf domain requires:

1. Domain values and pure behavior.
2. One `Signature` declaration.
3. Intrinsic or named value coders.
4. One request-router branch.
5. One response-coder branch.
6. One live interpreter implementation.

Root composition adds one property and one branch at each coproduct boundary.
No transport-specific client mirror is written. The amount of domain-authored
code is linear in the number of operations; generic interpretation machinery
is constant.

## Upstream capabilities required

The example assumes, but does not implement upstream during this pass:

- `@Client` support for method and property requirements;
- `@Calls` derivation of call and result coproducts plus composable case optics;
- exhaustive generic call interpretation by a derived client;
- derived remote interpretation preserving the failure algebra;
- declarative `HTTP.Request.Coder` and indexed `HTTP.Response.Coder` builders;
- request and response interpretation into generic HTTP client/responder arrows;
- `var body` coder combinators used by the value representations.

Those capabilities must be implemented at their semantic owners only after
the call-site syntax is accepted.
