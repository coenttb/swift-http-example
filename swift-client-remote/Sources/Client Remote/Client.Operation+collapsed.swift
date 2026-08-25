public import Client
public import Either_Primitives

extension Client.Operation {

    public func collapsed<External: Swift.Error>() -> Client.Operation<Input, Output, External>
    where Failure == Either<External, Swift.Never> {
        .init(
            run: { input throws(External) in
                do throws(Either<External, Swift.Never>) {
                    return try await self.run(input)
                } catch {
                    throw error.value
                }
            }
        )
    }

    public func collapsed<Refusal: Swift.Error>() -> Client.Operation<Input, Output, Refusal>
    where Failure == Either<Swift.Never, Refusal> {
        .init(
            run: { input throws(Refusal) in
                do throws(Either<Swift.Never, Refusal>) {
                    return try await self.run(input)
                } catch {
                    throw error.value
                }
            }
        )
    }
}
