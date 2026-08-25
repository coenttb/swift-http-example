public import Client
import Either_Primitives

extension Client {

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
