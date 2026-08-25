public import Example

extension Example.Counter {

    public struct Limit: Equatable, Sendable {

        public let underlying: Swift.Int

        public init(_ underlying: Swift.Int) {
            self.underlying = underlying
        }
    }
}
