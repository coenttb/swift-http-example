public import Client
public import Either_Primitives

extension Client {

    public typealias Remote<External: Swift.Error> =
        Client<Input, Output, Either<External, Failure>>
}
