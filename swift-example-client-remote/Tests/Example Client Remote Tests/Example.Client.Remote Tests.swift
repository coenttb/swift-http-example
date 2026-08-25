import Client
import Client_Remote
import Either_Primitives
import Example
import Example_Client
import Example_Client_Remote
import Example_Counter
import Example_Counter_Client
import Example_Counter_Client_Remote
import Example_Greeting
import Example_Greeting_Client
import Example_Greeting_Client_Remote
import Testing

@Suite
struct `Example.Client.Remote Tests` {

    static func client(from value: Example.Counter.Value) -> Example.Client {
        var current = value
        return .init(
            greeting: .init(greet: { name in Example.Greeting.greet(name) }),
            counter: .init(
                increment: { limit throws(Example.Counter.Error) in
                        current = try Example.Counter.increment(current, limit: limit)
                        return current
                    }
            )
        )
    }

    @Test
    func `remote at Never is isomorphic to the client, forward`() async throws {
        let remote = Example.Client.Remote<Swift.Never>(Self.client(from: .init(1)))
        #expect(await remote.greeting.greet(.init("Ada")) == .init("Hello, Ada!"))
        #expect(try await remote.counter.increment(.init(3)) == .init(2))
        do throws(Either<Swift.Never, Example.Counter.Error>) {
            _ = try await remote.counter.increment(.init(2))
            Issue.record("expected a refusal")
        } catch {
            #expect(error.value == .limit(reached: .init(2)))
        }
    }

    @Test
    func `remote at Never is isomorphic to the client, backward`() async throws {
        let recovered = Example.Client(
            Example.Client.Remote<Swift.Never>(Self.client(from: .init(1)))
        )
        #expect(await recovered.greeting.greet(.init("Ada")) == .init("Hello, Ada!"))
        #expect(try await recovered.counter.increment(.init(3)) == .init(2))
        do throws(Example.Counter.Error) {
            _ = try await recovered.counter.increment(.init(2))
            Issue.record("expected a refusal")
        } catch {
            #expect(error == .limit(reached: .init(2)))
        }
    }

    @Test
    func `external failure stays distinguishable from the domain refusal`() async {
        struct Outage: Swift.Error, Equatable {}
        let failing = Example.Counter.Client.Remote<Outage>(
            increment: .init(
                run: { _ throws(Either<Outage, Example.Counter.Error>) in
                    throw .left(Outage())
                }
            )
        )
        do throws(Either<Outage, Example.Counter.Error>) {
            _ = try await failing.increment(.init(3))
            Issue.record("expected an external failure")
        } catch {
            #expect(error == .left(Outage()))
        }

        let refusing = Example.Counter.Client.Remote<Outage>(
            increment: Client.Operation(
                run: { (limit: Example.Counter.Limit) throws(Example.Counter.Error) in
                    try Example.Counter.increment(.init(3), limit: limit)
                }
            ).promoted()
        )
        do throws(Either<Outage, Example.Counter.Error>) {
            _ = try await refusing.increment(.init(3))
            Issue.record("expected a refusal")
        } catch {
            #expect(error == .right(.limit(reached: .init(3))))
        }
    }

    @Test
    func `root remote is the product of the subdomain remotes`() async throws {
        enum Failure: Swift.Error { case expected }
        let remote = Example.Client.Remote<Failure>(
            greeting: .init(
                greet: .init(run: { name in .init("supplied \(name.underlying)") })
            ),
            counter: .init(
                increment: .init(
                    run: { limit throws(Either<Failure, Example.Counter.Error>) in
                        .init(limit.underlying)
                    }
                )
            )
        )
        #expect(try await remote.greeting.greet(.init("x")) == .init("supplied x"))
        #expect(try await remote.counter.increment(.init(9)) == .init(9))
    }
}
