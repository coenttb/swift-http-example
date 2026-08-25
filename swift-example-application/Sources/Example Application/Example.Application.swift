public import Client
public import Example

extension Example {

    public typealias Application<Failure: Swift.Error> =
        Client::Client.Operation<
            Example.Command, Example.Command.Output, Failure
        >
}
