public import Example

extension Example.Counter {

    public static func increment(
        _ value: Value,
        limit: Limit
    ) throws(Example.Counter.Error) -> Value {
        guard value.underlying < limit.underlying else {
            throw .limit(reached: limit)
        }
        return .init(value.underlying + 1)
    }
}
