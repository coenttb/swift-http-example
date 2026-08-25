public import Client
public import Example
public import Example_Greeting

extension Example.Greeting {

    public struct Client: Sendable {

        public var greet:
        Client::Client.Operation<Example.Greeting.Name, Example.Greeting.Message, Swift.Never>

        public init(
            greet: Client::Client.Operation<Example.Greeting.Name, Example.Greeting.Message, Swift.Never>
        ) {
            self.greet = greet
        }
    }
}
