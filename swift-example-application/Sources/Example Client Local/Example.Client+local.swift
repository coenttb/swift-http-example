public import Example
public import Example_Client
import Example_Counter_Client
import Example_Greeting_Client

extension Example.Client {

    public static var local: Self {
        .init(greeting: .local, counter: .local)
    }
}
