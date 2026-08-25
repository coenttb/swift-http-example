public import Example
public import Example_Counter
public import Example_Counter_Client
import Client
import Client_Remote
import Either_Primitives

extension Example.Counter.Client.Remote where Failure == Swift.Never {

    public init(_ client: Example.Counter.Client) {
        self.init(increment: client.increment.promoted())
    }
}

extension Example.Counter.Client {

    public init(_ remote: Example.Counter.Client.Remote<Swift.Never>) {
        self.init(increment: remote.increment.collapsed())
    }
}
