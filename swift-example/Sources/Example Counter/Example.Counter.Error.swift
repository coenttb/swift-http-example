public import Example

extension Example.Counter {

    public enum Error: Swift.Error, Equatable {

        case limit(reached: Limit)
    }
}
