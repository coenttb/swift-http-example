public import Example
public import Example_Greeting
public import Example_Greeting_Client
import Client

extension Example.Greeting.Client.Remote where Failure == Swift.Never {

    public init(_ client: Example.Greeting.Client) {
        self.init(greet: .init(run: client.greet))
    }
}

extension Example.Greeting.Client {

    public init(_ remote: Example.Greeting.Client.Remote<Swift.Never>) {
        self.init(greet: remote.greet.run)
    }
}
