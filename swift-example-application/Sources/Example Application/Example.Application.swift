public import Application
public import Example

extension Example {

    public typealias Application<Failure: Swift.Error> =
        Application::Application.Interpreter<
            Example.Command, Example.Command.Output, Failure
        >
}
