public import Application
public import Either_Primitives
public import Example
public import Example_Application
public import Example_Client
public import Example_Client_Remote
import Client
import Example_Counter
import Example_Counter_Client_Remote
import Example_Greeting
import Example_Greeting_Client_Remote

extension Application.Interpreter
where
    Input == Example.Command,
    Output == Example.Command.Output
{

    public init<ExternalFailure: Swift.Error>(
        _ remote: Example.Client.Remote<ExternalFailure>
    ) where Failure == Either<ExternalFailure, Example.Command.Error> {
        self.init(
            interpret: { command async throws(Either<ExternalFailure, Example.Command.Error>) in
                switch command {
                case .greet(let name):
                    do throws(ExternalFailure) {
                        return .greet(try await remote.greeting.greet(name))
                    } catch {
                        throw .left(error)
                    }
                case .increment(let value, let limit):
                    do throws(Either<ExternalFailure, Example.Counter.Error>) {
                        return .increment(
                            try await remote.counter.increment(.init(value: value, limit: limit))
                        )
                    } catch {
                        switch error {
                        case .left(let external):
                            throw .left(external)
                        case .right(let refusal):
                            throw .right(.counter(refusal))
                        }
                    }
                }
            }
        )
    }
}
