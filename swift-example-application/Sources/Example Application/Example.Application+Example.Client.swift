public import Application
public import Example
public import Example_Client
import Client
import Example_Counter
import Example_Counter_Client
import Example_Greeting
import Example_Greeting_Client

extension Application.Interpreter
where
    Input == Example.Command,
    Output == Example.Command.Output,
    Failure == Example.Command.Error
{

    public init(_ client: Example.Client) {
        self.init(
            interpret: { command async throws(Example.Command.Error) in
                switch command {
                case .greet(let name):
                    return .greet(await client.greeting.greet(name))
                case .increment(let value, let limit):
                    do throws(Example.Counter.Error) {
                        return .increment(
                            try await client.counter.increment(.init(value: value, limit: limit))
                        )
                    } catch {
                        throw .counter(error)
                    }
                }
            }
        )
    }
}
