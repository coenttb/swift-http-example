public import Example

extension Example.Greeting {

    public static func greet(_ name: Name) -> Message {
        .init("Hello, \(name.underlying)!")
    }
}
