public import Example
public import Example_Counter
public import Example_Counter_Client
public import Example_Greeting
public import Example_Greeting_Client

extension Example {

    public struct Client {

        public var greeting: Example.Greeting.Client

        public var counter: Example.Counter.Client

        public init(
            greeting: Example.Greeting.Client,
            counter: Example.Counter.Client
        ) {
            self.greeting = greeting
            self.counter = counter
        }
    }
}
