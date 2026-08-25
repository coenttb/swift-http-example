public import Client
public import Example
public import Example_Counter

extension Example.Counter {
    
    public struct Client {

        public let increment: Client::Client.Operation<
            Example.Counter.Limit, Example.Counter.Value, Example.Counter.Error
        >

        public init(
            increment: @escaping (
                Example.Counter.Limit
            ) async throws(Example.Counter.Error) -> Example.Counter.Value
        ) {
            self.increment = .init(run: increment)
        }
    }
}
