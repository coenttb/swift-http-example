import Application
import Client
import Client_Remote
import Either_Primitives
import Example
import Example_Application
import Example_Application_Remote
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
struct `example-remote Tests` {

    static var client: Example.Client {
        .init(
            greeting: .init(greet: .init(run: { name in Example.Greeting.greet(name) })),
            counter: .init(
                increment: .init(
                    run: { increment throws(Example.Counter.Error) in
                        try Example.Counter.increment(increment.value, limit: increment.limit)
                    }
                )
            )
        )
    }

    @Test
    func `local and remote interpretations produce identical successes`() async throws {
        let local = Example.Application(Self.client)
        let remote = Example.Application(Example.Client.Remote<Swift.Never>(Self.client))

        let greeting = try await local.interpret(.greet(.init("Ada")))
        #expect(try await remote.interpret(.greet(.init("Ada"))) == greeting)
        #expect(greeting == .greet(.init("Hello, Ada!")))

        let count = try await local.interpret(.increment(value: .init(1), limit: .init(5)))
        #expect(try await remote.interpret(.increment(value: .init(1), limit: .init(5))) == count)
        #expect(count == .increment(.init(2)))
    }

    @Test
    func `local and remote interpretations preserve identical refusals`() async {
        let command = Example.Command.increment(value: .init(5), limit: .init(5))

        var local: Example.Command.Error?
        do throws(Example.Command.Error) {
            _ = try await Example.Application(Self.client).interpret(command)
            Issue.record("expected a refusal")
        } catch {
            local = error
        }

        var remote: Example.Command.Error?
        do throws(Either<Swift.Never, Example.Command.Error>) {
            _ = try await Example.Application(Example.Client.Remote<Swift.Never>(Self.client))
                .interpret(command)
            Issue.record("expected a refusal")
        } catch {
            remote = error.value
        }

        #expect(local == .counter(.limit(reached: .init(5))))
        #expect(local == remote)
    }

    @Test
    func `an injected external failure is observed on the external side`() async {
        struct Outage: Swift.Error, Equatable {}

        let remote = Example.Client.Remote<Outage>(
            greeting: .init(
                greet: .init(
                    run: { _ throws(Outage) in throw Outage() }
                )
            ),
            counter: .init(
                increment: .init(
                    run: { _ throws(Either<Outage, Example.Counter.Error>) in
                        throw .left(Outage())
                    }
                )
            )
        )
        let application = Example.Application(remote)

        do throws(Either<Outage, Example.Command.Error>) {
            _ = try await application.interpret(.greet(.init("Ada")))
            Issue.record("expected an external failure")
        } catch {
            #expect(error == .left(Outage()))
        }

        do throws(Either<Outage, Example.Command.Error>) {
            _ = try await application.interpret(.increment(value: .init(1), limit: .init(5)))
            Issue.record("expected an external failure")
        } catch {
            guard case .left = error else {
                Issue.record("external failure was misclassified as a refusal")
                return
            }
        }
    }
}
