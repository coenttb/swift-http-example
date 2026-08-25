extension Client.Operation {

    @inlinable
    public func callAsFunction(_ input: Input) async throws(Failure) -> Output {
        try await run(input)
    }
}
