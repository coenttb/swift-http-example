public import Client
public import Client_Remote
public import Either_Primitives
public import Example
public import Example_Counter
public import Example_Counter_Client

extension Example.Counter.Client {

    public struct Remote<Failure: Swift.Error>: Sendable {

        public var increment:
            Client.Operation<
                Example.Counter.Increment, Example.Counter.Value, Example.Counter.Error
            >.Remote<Failure>

        public init(
            increment: Client.Operation<
                Example.Counter.Increment, Example.Counter.Value, Example.Counter.Error
            >.Remote<Failure>
        ) {
            self.increment = increment
        }
    }
}
