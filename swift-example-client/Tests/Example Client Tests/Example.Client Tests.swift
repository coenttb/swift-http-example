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
        var current = Example.Counter.Value(0)
        let client = Example.Client(
            greeting: .init(greet: { name in .init("hi \(name.underlying)") }),
            counter: .init(
                increment: { limit throws(Example.Counter.Error) in
                        current = try Example.Counter.increment(current, limit: limit)
                        return current
                    }
            )
        )
        #expect(await client.greeting.greet(.init("x")) == .init("hi x"))
        #expect(try await client.counter.increment(limit: .init(9)) == .init(1))
        #expect(try await client.counter.increment(limit: .init(9)) == .init(2))
    }

    @Test
    func `counter client surfaces the declared domain refusal`() async {
        let client = Example.Counter.Client(
            increment: { limit throws(Example.Counter.Error) in
                    try Example.Counter.increment(.init(5), limit: limit)
                }
        )
        do throws(Example.Counter.Error) {
            _ = try await client.increment(limit: .init(5))
            Issue.record("expected a refusal")
        } catch {
            #expect(error == .limit(reached: .init(5)))
        }
    }
}
