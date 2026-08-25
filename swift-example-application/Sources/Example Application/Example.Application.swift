public import Client
public import Example

extension Example {

    public typealias Application<Failure: Swift.Error> =
        Client::Client<
            Example.Command, Example.Command.Output, Failure
        >
}
