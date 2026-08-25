public import Example
public import Example_Counter
public import Example_Greeting

extension Example.Command {

    public enum Output: Sendable, Equatable {

        case greet(Example.Greeting.Message)

        case increment(Example.Counter.Value)
    }
}
