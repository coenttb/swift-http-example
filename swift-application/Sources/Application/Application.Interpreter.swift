extension Application {

    public struct Interpreter<Input, Output, Failure: Swift.Error>: Sendable {

        public var interpret: @Sendable (Input) async throws(Failure) -> Output

        public init(
            interpret: @escaping @Sendable (Input) async throws(Failure) -> Output
        ) {
            self.interpret = interpret
        }
    }
}
