import Client
import Example
import Example_Application
import Example_Client
import Example_Counter
import Example_Counter_Client
import Example_Greeting
import Example_Greeting_Client
import Testing

@Suite
struct `Example.Application Tests` {

    static func client(from value: Example.Counter.Value) -> Example.Client {
        var current = value
        return .init(
            greeting: .init(greet: Example.Greeting.greet),
            counter: .init(
                increment: { limit throws(Example.Counter.Error) in
                    current = try Example.Counter.increment(current, limit: limit)
                    return current
                }
            )
        )
    }

    @Test
    func `the local application interprets both commands`() async throws {
        let application = Example.Application(Self.client(from: .init(0)))
        #expect(
            try await application(.greet(name: .init("Ada")))
                == .greeting(.init("Hello, Ada!"))
        )
        #expect(
            try await application(.increment(limit: .init(3)))
                == .counter(.init(1))
        )
        #expect(
            try await application(.increment(limit: .init(3)))
                == .counter(.init(2))
        )
    }

    @Test
    func `the local application surfaces the domain refusal directly`() async {
        let application = Example.Application(Self.client(from: .init(0)))
        do throws(Example.Counter.Error) {
            _ = try await application(.increment(limit: .init(0)))
            Issue.record("expected a refusal")
        } catch {
            #expect(error == .limit(reached: .init(0)))
        }
    }
}
