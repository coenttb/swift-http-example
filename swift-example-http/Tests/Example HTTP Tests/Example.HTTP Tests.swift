import Client
import Either_Primitives
import Example
import Example_Application
import Example_Application_Remote
import Example_Client
import Example_Client_Remote
import Example_Counter
import Example_Counter_Client
import Example_Counter_HTTP
import Example_Greeting
import Example_Greeting_Client
import Example_Greeting_Client_Remote
import Example_Greeting_HTTP
import HTTP
import HTTP_Client
import HTTP_Coder
import Parser_Primitive
import Serializer_Primitive
import Testing

@Suite
struct `Example.HTTP Tests` {

    enum Outage: Swift.Error, Equatable {
        case unavailable
    }

    static func client(from value: Example.Counter.Value) -> Example.Client {
        var current = value
        return .init(
            greeting: .init(greet: Example.Greeting.greet),
            counter: .init(
                increment: { limit throws(Example.Counter.Error) in
                    current = try Example.Counter.increment(current, limit: limit)
                    return current
                }
            )
        )
    }

    @Test
    func `endpoint coders round trip domain values`() throws {
        var request: HTTP.Request?
        try Example.Greeting.Endpoint.Request().serialize(.init("Ada"), into: &request)
        #expect(
            try Example.Greeting.Endpoint.Request().parse(&request) == .init("Ada")
        )

        var response: HTTP.Response?
        try Example.Counter.Endpoint.Response().serialize(
            .left(.limit(reached: .init(3))),
            into: &response
        )
        #expect(
            try Example.Counter.Endpoint.Response().parse(&response)
                == .left(.limit(reached: .init(3)))
        )
    }

    @Test
    func `HTTP clients and responders compose into one application`() async throws {
        typealias ExternalFailure = Either<HTTP.Coding.Error, HTTP.Coding.Error>

        let service = Self.client(from: .init(0))
        let remote = Example.Client.Remote<ExternalFailure>(
            greeting: Example.Greeting.Endpoint.remote(
                using: Example.Greeting.Endpoint.responder(using: service.greeting)
            ),
            counter: Example.Counter.Endpoint.remote(
                using: Example.Counter.Endpoint.responder(using: service.counter)
            )
        )
        let application = Example.Application(remote)

        #expect(
            try await application(.greet(name: .init("Ada")))
                == .greeting(.init("Hello, Ada!"))
        )
        #expect(
            try await application(.increment(limit: .init(1)))
                == .counter(.init(1))
        )

        do throws(Either<ExternalFailure, Example.Counter.Error>) {
            _ = try await application(.increment(limit: .init(1)))
            Issue.record("expected a domain refusal")
        } catch {
            #expect(error == .right(.limit(reached: .init(1))))
        }
    }

    @Test
    func `transport and coding failures remain distinguishable`() async {
        let unavailable = Example.Greeting.Endpoint.remote(
            using: HTTP.Client<Outage>(
                run: { _ throws(Outage) in throw .unavailable }
            )
        )
        do throws(Either<Outage, HTTP.Coding.Error>) {
            _ = try await unavailable.greet(.init("Ada"))
            Issue.record("expected a transport failure")
        } catch {
            #expect(error == .left(.unavailable))
        }

        let invalid = Example.Greeting.Endpoint.remote(
            using: HTTP.Client<Swift.Never>(
                run: { _ in .init(status: .notFound) }
            )
        )
        do throws(Either<Swift.Never, HTTP.Coding.Error>) {
            _ = try await invalid.greet(.init("Ada"))
            Issue.record("expected a coding failure")
        } catch {
            #expect(error == .right(.response))
        }
    }
}
