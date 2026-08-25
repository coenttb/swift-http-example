public import Example
public import Example_Application
import Example_Counter
import Example_Greeting

extension Example.Command.Output {

    public var line: Swift.String {
        switch self {
        case .greet(let message):
            message.underlying
        case .increment(let value):
            "\(value.underlying)"
        }
    }
}
