extension Application.Interpreter {

    @inlinable
    public func callAsFunction(_ input: Input) async throws(Failure) -> Output {
        try await interpret(input)
    }
}
