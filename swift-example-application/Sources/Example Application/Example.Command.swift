public import Example
public import Example_Counter
public import Example_Greeting

extension Example {

    public enum Command: Equatable {

        case greeting(Example.Greeting.Name)

        case counter(Example.Counter.Limit)
    }
}
