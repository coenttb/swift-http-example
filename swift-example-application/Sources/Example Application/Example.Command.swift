public import Example
public import Example_Counter
public import Example_Greeting

extension Example {

    public enum Command: Sendable, Equatable {

        case greet(Example.Greeting.Name)

        case increment(value: Example.Counter.Value, limit: Example.Counter.Limit)
    }
}
