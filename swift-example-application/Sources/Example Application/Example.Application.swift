public import Application_Primitives
public import Example

extension Example {

    public typealias Application<Failure: Swift.Error> =
        Application_Primitives.Application.Interpreter<
            Example.Command, Example.Command.Output, Failure
        >
}
