public import Example

extension Example.Counter {

    public struct Value: Sendable, Equatable {

        public let underlying: Swift.Int

        public init(_ underlying: Swift.Int) {
            self.underlying = underlying
        }
    }
}
