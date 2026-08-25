public import Example
public import Example_Counter
public import Example_Greeting

extension Example.Command {

    public static func greet(name: Example.Greeting.Name) -> Self {
        .greeting(name)
    }

    public static func increment(limit: Example.Counter.Limit) -> Self {
        .counter(limit)
    }
}
