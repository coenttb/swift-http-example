public import Client
public import Example
public import Example_Greeting

extension Example.Greeting {

    public struct Client {

        public let greet:
            Client::Client.Operation<Example.Greeting.Name, Example.Greeting.Message, Swift.Never>

        public init(
            greet: @escaping (Example.Greeting.Name) async -> Example.Greeting.Message
        ) {
            self.greet = .init(run: greet)
        }
    }
}
