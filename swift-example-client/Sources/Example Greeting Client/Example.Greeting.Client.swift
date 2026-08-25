public import Client
public import Client_Macros
public import Example
public import Example_Greeting

extension Example.Greeting {
    @Algebra
    package protocol Signature {
        func greet(_ name: Example.Greeting.Name) async -> Example.Greeting.Message
    }
}
