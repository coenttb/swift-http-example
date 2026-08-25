import Client
import Example
import Example_Client
import Example_Counter
import Example_Counter_Client
import Example_Greeting
import Example_Greeting_Client
import Testing

@Suite
struct `Example.Client Tests` {

    @Test
    func `root client composes both subclients`() async throws {
        let client = Example.Client(
            greeting: .init(greet: .init(run: { name in .init("hi \(name.underlying)") })),
            counter: .init(
                increment: .init(
                    run: { increment throws(Example.Counter.Error) in increment.value }
                )
            )
        )
        #expect(await client.greeting.greet(.init("x")) == .init("hi x"))
        #expect(
            try await client.counter.increment(.init(value: .init(7), limit: .init(9)))
                == .init(7)
        )
    }

    @Test
    func `counter client surfaces the declared domain refusal`() async {
        let client = Example.Counter.Client(
            increment: .init(
                run: { increment throws(Example.Counter.Error) in
                    try Example.Counter.increment(increment.value, limit: increment.limit)
                }
            )
        )
        do throws(Example.Counter.Error) {
            _ = try await client.increment(.init(value: .init(5), limit: .init(5)))
            Issue.record("expected a refusal")
        } catch {
            #expect(error == .limit(reached: .init(5)))
        }
    }
}
