public import Example
public import Example_Counter
public import Example_Greeting

extension Example.Command {

    public enum Output: Equatable {

        case greeting(Example.Greeting.Message)

        case counter(Example.Counter.Value)
    }
}
