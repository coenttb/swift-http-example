public import Example
public import Example_Client
public import Example_Counter
public import Example_Counter_Client
public import Example_Counter_Client_Remote
public import Example_Greeting
public import Example_Greeting_Client
public import Example_Greeting_Client_Remote

extension Example.Client.Remote where Failure == Swift.Never {

    public init(_ client: Example.Client) {
        self.init(
            greeting: .init(client.greeting),
            counter: .init(client.counter)
        )
    }
}

extension Example.Client {

    public init(_ remote: Example.Client.Remote<Swift.Never>) {
        self.init(
            greeting: .init(remote.greeting),
            counter: .init(remote.counter)
        )
    }
}
