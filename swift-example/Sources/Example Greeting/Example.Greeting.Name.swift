public import Example

extension Example.Greeting {

    public struct Name: Equatable {

        public let underlying: Swift.String

        public init(_ underlying: Swift.String) {
            self.underlying = underlying
        }
    }
}
