extension Client {

    public struct Operation<Input, Output, Failure: Swift.Error>: Sendable {

        public var run: @Sendable (Input) async throws(Failure) -> Output

        public init(
            run: @escaping @Sendable (Input) async throws(Failure) -> Output
        ) {
            self.run = run
        }
    }
}
