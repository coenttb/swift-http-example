public import Client
public import Example
public import Example_Counter

extension Example.Counter {
    
    public struct Client: Sendable {
        
        public var increment:
        Client::Client.Operation<
            Example.Counter.Increment, Example.Counter.Value, Example.Counter.Error
        >
        
        public init(
            increment: Client::Client.Operation<
            Example.Counter.Increment, Example.Counter.Value, Example.Counter.Error
            >
        ) {
            self.increment = increment
        }
    }
}
