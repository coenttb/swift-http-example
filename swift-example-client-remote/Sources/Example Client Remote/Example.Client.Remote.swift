public import Example
public import Example_Client
public import Example_Counter
public import Example_Counter_Client
public import Example_Counter_Client_Remote
public import Example_Greeting
public import Example_Greeting_Client
public import Example_Greeting_Client_Remote

extension Example.Client {

    public struct Remote<Failure: Swift.Error>: Sendable {

        public var greeting: Example.Greeting.Client.Remote<Failure>

        public var counter: Example.Counter.Client.Remote<Failure>

        public init(
            greeting: Example.Greeting.Client.Remote<Failure>,
            counter: Example.Counter.Client.Remote<Failure>
        ) {
            self.greeting = greeting
            self.counter = counter
        }
    }
}
