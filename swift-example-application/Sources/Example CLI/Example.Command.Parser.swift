public import Example
public import Example_Application
import Example_Counter
import Example_Greeting

extension Example.Command {

    public struct Parser: Sendable {

        public init() {}
    }
}

extension Example.Command.Parser {

    public func parse(
        _ input: inout Swift.ArraySlice<Swift.String>
    ) throws(Example.Command.Parser.Error) -> Example.Command {
        guard let command = input.first else {
            throw .command(found: nil)
        }
        input.removeFirst()
        switch command {
        case "greet":
            guard let name = input.first else {
                throw .argument(expected: "name")
            }
            input.removeFirst()
            if let extra = input.first {
                throw .trailing(found: extra)
            }
            return .greet(.init(name))
        case "increment":
            let value = try self.number(&input, expected: "value")
            let limit = try self.number(&input, expected: "limit")
            if let extra = input.first {
                throw .trailing(found: extra)
            }
            return .increment(value: .init(value), limit: .init(limit))
        default:
            throw .command(found: command)
        }
    }
}

extension Example.Command.Parser {

    func number(
        _ input: inout Swift.ArraySlice<Swift.String>,
        expected: Swift.String
    ) throws(Example.Command.Parser.Error) -> Swift.Int {
        guard let argument = input.first else {
            throw .argument(expected: expected)
        }
        input.removeFirst()
        guard let number = Swift.Int(argument) else {
            throw .number(found: argument)
        }
        return number
    }
}
