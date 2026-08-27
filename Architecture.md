# Swift Example Architecture

The workspace is the minimal canary for:

```text
domain → client algebra → call algebra → bidirectional HTTP routing
       → remote client / responder → application
```

The current checkout is a migration checkpoint. Its Swift and manifests parse,
but package resolution and type-checking are not yet authoritative because the
new canonical repositories have not all been published.

## Ownership

| Package | Sole responsibility |
|---|---|
| `swift-example` | Domain values, refusals, and behavior |
| `swift-client` | One effectful client arrow |
| `swift-call` | Call branch, coverage, and result algebra |
| `swift-coder` | Generic bidirectional case lifting and alternatives |
| `swift-router` | Carrier-neutral routing and ordered rejection |
| `swift-witness-derivation` | `@Witness` |
| `swift-prism-derivation` | `@Prisms` |
| `swift-eliminator-derivation` | `@Eliminator` |
| `swift-call-derivation` | `@Calls` |
| `swift-client-derivation` | `@Client` |
| `swift-example-client` | Example client signatures |
| `swift-http` | The `HTTP` namespace over the HTTP standards model |
| `swift-http-coder` | HTTP response and content coding |
| `swift-http-router` | HTTP interpretation of generic routing |
| `swift-http-client` | Remote HTTP interpretation of a whole call algebra |
| `swift-http-responder` | Request-to-call and result-to-response interpretation |
| `swift-example-http` | Example routes and response representations |
| `swift-example-application` | Live behavior and assembly |

A case lift is `Coder.Case`; alternatives are `Coder.OneOf`. HTTP does not own
either algebra.

## Dependency direction

```text
swift-call ───────────────┐
                         ├→ swift-router ─→ swift-http-router
swift-coder ──────────────┘                         │
                                                   ├→ swift-http-client
swift-http ─────────────────────────────────────────┤
swift-http-coder ───────────────────────────────────┴→ swift-http-responder

swift-witness-derivation ─→ swift-client-derivation
swift-call + prism/eliminator derivation ─→ swift-call-derivation

swift-example ─→ swift-example-client ─→ swift-example-http
                                           │
                                           └→ swift-example-application
```

The manifests retain canonical GitHub URLs. `example.xcworkspace` supplies
local substitution.

## Domain and client algebra

Domains contain no HTTP or transport concepts. Each leaf declares one client
signature:

```swift
extension Example.Counter {
    @Client
    @Calls
    package protocol Signature {
        func increment(limit: Limit) async throws(Error) -> Value
    }
}
```

The root composes child clients:

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

`@Calls` derives the call coproduct, total result coproduct, prisms, branch
identifiers, and coverage product. `@Client` derives the transport-independent
witness and `Client.Remote<External>`. The remote view is reconstructed from one
`Client<Call, Call.Result, External>` arrow; it is not implemented once per
endpoint.

For a fallible operation, the total call result contains
`Swift.Result<Output, Refusal>`. The remote view exposes
`Either<External, Refusal>`, preserving:

```text
external transport/coding failure + domain refusal
```

## HTTP model

RFC 9110 owns version-independent semantics:

```swift
HTTP.Message.Request<Content>
HTTP.Message.Response<Content>
HTTP.Method
HTTP.Target
HTTP.Status
HTTP.Field
HTTP.Message.Headers
HTTP.Message.Trailers
```

Request and response content remain generic. `[Byte]` is one adapter choice,
not the definition of HTTP content. Version-specific framing remains under the
corresponding HTTP version namespace and is outside semantic routing.

## Routing

Routing follows the noun, capability, gerund, and provider pattern:

```text
HTTP.Router
HTTP.Router.Protocol
HTTP.Routing<Domain>
HTTP.Routable
```

A leaf route states only HTTP policy and intrinsic value coding:

```swift
extension Example.Greeting: HTTP.Routable {
    public static var router: some HTTP.Routing<Self> {
        HTTP.Target.resource(.init(unchecked: "/greeting"))
        HTTP.Method.post
        HTTP.Content(Name.self)
    }
}
```

The builder lifts the value through the unique derived call prism. A composed
domain names every child branch without exposing the call coproduct:

```swift
extension Example: HTTP.Routable {
    public static var router: some HTTP.Routing<Self> {
        HTTP.Route(\.greeting) { Greeting.router }
        HTTP.Route(\.counter) { Counter.router }
    }
}
```

The route builder folds derived branch identifiers into a structural coverage
product. `HTTP.Routable` requires that product to equal `Call.Coverage`, making a
missing, duplicate, extra, or reordered route a type error.

`Router.Rejection.retry` is non-consuming: a route that permits retry
must leave its input or output carrier unchanged. Ordered alternatives therefore
do not impose `Copyable` merely to create checkpoints.

Parsing and serialization operate on semantic
`HTTP.Message.Request<Content>`. Wire parsing and framing do not enter the
domain router.

## Response coding

Responses remain separate from request routing so authentication, logging,
authorization, caching, and other application behavior can run between the
parsed call and represented result.

```swift
extension Example.Greeting {
    public struct Responses: Coder.Protocol {
        public var body: some Coder.Protocol {
            Coder.Case(Call.Result.prisms.greet) {
                HTTP.Representation(.ok, Message.coder)
            }
        }
    }
}
```

Alternative representations use `Coder.OneOf`; HTTP does not introduce a
parallel choice algebra. `HTTP.Representation<Content, Value>` pairs a semantic
status with a content coder and does not fix the content container.

## Remote and responder interpretation

The remote edge is one whole-domain arrow. The application supplies the
concrete content and transport choice through one initializer:

```swift
let client = Example.Client.Remote(http: transport)
```

That initializer delegates to `HTTP.client(Example.self, response:transport:)`;
it contains no endpoint-specific implementation.

The server edge exposes the same seams independently:

```swift
let call = try HTTP.route(Example.self, request)
let result = await Example.Client.live(call)
let response = try HTTP.response(result, using: Example.Responses())
```

`HTTP.responder` composes those steps when no intermediate application policy
is needed. Source routing never invokes build, test, package, or wire-framing
operations.

## Marginal domain cost

Adding one leaf domain requires:

1. Domain values, refusal, and behavior.
2. One client signature.
3. Intrinsic value coders.
4. One declarative route body.
5. One response representation branch.
6. One live implementation.

At each composition boundary, the root adds one client property and one route
branch. Transport clients, responder plumbing, call/result coproducts, prisms,
coverage, and remote reconstruction are generic or derived once.
