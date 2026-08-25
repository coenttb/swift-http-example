public import Example

extension Example.Counter {

    public enum Error: Swift.Error, Sendable, Equatable {

        case limit(reached: Limit)
    }
}
