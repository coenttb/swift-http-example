public import Example

extension Example.Counter {

    public struct Increment: Sendable, Equatable {

        public var value: Example.Counter.Value

        public var limit: Example.Counter.Limit

        public init(value: Example.Counter.Value, limit: Example.Counter.Limit) {
            self.value = value
            self.limit = limit
        }
    }
}
