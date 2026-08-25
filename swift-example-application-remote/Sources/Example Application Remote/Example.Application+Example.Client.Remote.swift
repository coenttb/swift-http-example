public import Client
public import Either_Primitives
public import Example
public import Example_Application
public import Example_Client
public import Example_Client_Remote
public import Example_Counter
import Example_Counter_Client_Remote
import Example_Greeting
import Example_Greeting_Client_Remote

extension Client
where
    Input == Example.Command,
    Output == Example.Command.Output
{

    public init<ExternalFailure: Swift.Error>(
        _ remote: Example.Client.Remote<ExternalFailure>
    ) where Failure == Either<ExternalFailure, Example.Counter.Error> {
        self.init(
            run: { command async throws(Either<ExternalFailure, Example.Counter.Error>) in
                switch command {
                case .greeting(let name):
                    do throws(ExternalFailure) {
                        return .greeting(try await remote.greeting.greet(name))
                    } catch {
                        throw .left(error)
                    }

                case .counter(let limit):
                    return .counter(try await remote.counter.increment(limit))
                }
            }
        )
    }
}
