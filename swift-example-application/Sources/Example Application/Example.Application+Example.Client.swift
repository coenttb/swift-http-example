public import Client
public import Example
public import Example_Client
public import Example_Counter
import Example_Counter_Client
import Example_Greeting
import Example_Greeting_Client

extension Client
where
    Input == Example.Command,
    Output == Example.Command.Output,
    Failure == Example.Counter.Error
{

    public init(_ client: Example.Client) {
        self.init(
            run: { command async throws(Example.Counter.Error) in
                switch command {
                case .greeting(let name):
                    return .greeting(await client.greeting.greet(name))

                case .counter(let limit):
                    return .counter(try await client.counter.increment(limit: limit))
                }
            }
        )
    }
}
