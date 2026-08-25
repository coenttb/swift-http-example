public import Example
public import Example_Application

extension Example.Command.Parser {

    public enum Error: Swift.Error, Sendable, Equatable {

        case command(found: Swift.String?)

        case argument(expected: Swift.String)

        case number(found: Swift.String)

        case trailing(found: Swift.String)
    }
}
