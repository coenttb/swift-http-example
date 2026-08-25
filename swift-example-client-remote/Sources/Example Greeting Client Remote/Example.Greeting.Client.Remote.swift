public import Client
public import Example
public import Example_Greeting
public import Example_Greeting_Client

extension Example.Greeting.Client {

    public struct Remote<Failure: Swift.Error> {

        public var greet:
            Client.Operation<Example.Greeting.Name, Example.Greeting.Message, Failure>

        public init(
            greet: Client.Operation<Example.Greeting.Name, Example.Greeting.Message, Failure>
        ) {
            self.greet = greet
        }
    }
}
