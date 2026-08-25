import Application
import Example
import Example_Application
import Example_Client
import Example_Client_Local
import Example_Counter
import Example_Greeting
import Testing

@Suite
struct `Example.Application Tests` {

    @Test
    func `the local application interprets both commands`() async throws {
        let application = Example.Application(Example.Client.local)
        #expect(
            try await application.interpret(.greet(.init("Ada")))
                == .greet(.init("Hello, Ada!"))
        )
        #expect(
            try await application.interpret(.increment(value: .init(1), limit: .init(3)))
                == .increment(.init(2))
        )
    }

    @Test
    func `the local application surfaces the domain refusal directly`() async {
        let application = Example.Application(Example.Client.local)
        do throws(Example.Command.Error) {
            _ = try await application.interpret(.increment(value: .init(3), limit: .init(3)))
            Issue.record("expected a refusal")
        } catch {
            #expect(error == .counter(.limit(reached: .init(3))))
        }
    }
}
