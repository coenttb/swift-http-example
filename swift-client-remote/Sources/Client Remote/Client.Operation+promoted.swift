public import Client
public import Either_Primitives

extension Client.Operation {

    public func promoted<External: Swift.Error>() -> Remote<External> {
        .init(
            run: { input throws(Either<External, Failure>) in
                do throws(Failure) {
                    return try await self.run(input)
                } catch {
                    throw .right(error)
                }
            }
        )
    }
}
