public import Example
public import Example_Greeting
public import Example_Greeting_Client
import Client

extension Example.Greeting.Client {

    public static var local: Self {
        .init(greet: .init(run: { name in Example.Greeting.greet(name) }))
    }
}
