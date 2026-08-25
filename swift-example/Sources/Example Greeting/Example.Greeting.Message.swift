public import Example

extension Example.Greeting {

    public struct Message: Sendable, Equatable {

        public let underlying: Swift.String

        public init(_ underlying: Swift.String) {
            self.underlying = underlying
        }
    }
}
