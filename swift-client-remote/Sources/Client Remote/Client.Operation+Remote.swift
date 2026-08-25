public import Client
public import Either_Primitives

extension Client.Operation {

    public typealias Remote<External: Swift.Error> =
        Client.Operation<Input, Output, Either<External, Failure>>
}
