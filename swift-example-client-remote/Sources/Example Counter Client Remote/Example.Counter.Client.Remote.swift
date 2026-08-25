public import Client
public import Client_Remote
import Either_Primitives
public import Example
public import Example_Counter
public import Example_Counter_Client

extension Example.Counter.Client {

    public struct Remote<Failure: Swift.Error> {

        public var increment:
            Client<
                Example.Counter.Limit, Example.Counter.Value, Example.Counter.Error
            >.Remote<Failure>

        public init(
            increment: Client<
                Example.Counter.Limit, Example.Counter.Value, Example.Counter.Error
            >.Remote<Failure>
        ) {
            self.increment = increment
        }
    }
}
