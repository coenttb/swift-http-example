public import Example
public import Example_Counter

extension Example.Command {

    public enum Error: Swift.Error, Sendable, Equatable {

        case counter(Example.Counter.Error)
    }
}
