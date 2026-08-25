import Client
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
struct `Example.Application.Remote Tests` {

    enum Outage: Swift.Error, Equatable {
        case unavailable
    }

    @Test
    func `application preserves external failure and domain refusal`() async {
        let remote = Example.Client.Remote<Outage>(
            greeting: .init(
                greet: .init(run: { _ throws(Outage) in throw .unavailable })
            ),
            counter: .init(
                increment: .init(
                    run: { limit throws(Either<Outage, Example.Counter.Error>) in
                        throw .right(.limit(reached: limit))
                    }
                )
            )
        )
        let application = Example.Application(remote)

        do throws(Either<Outage, Example.Counter.Error>) {
            _ = try await application(.greet(name: .init("Ada")))
            Issue.record("expected an external failure")
        } catch {
            #expect(error == .left(.unavailable))
        }

        do throws(Either<Outage, Example.Counter.Error>) {
            _ = try await application(.increment(limit: .init(3)))
            Issue.record("expected a domain refusal")
        } catch {
            #expect(error == .right(.limit(reached: .init(3))))
        }
    }
}
