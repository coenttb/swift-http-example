import Example
import Example_Greeting
import Testing

@Suite
struct `Example.Greeting Tests` {

    @Test
    func `greet composes the message from the name`() {
        #expect(Example.Greeting.greet(.init("Ada")) == .init("Hello, Ada!"))
    }
}
