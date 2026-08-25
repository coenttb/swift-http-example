import Example
import Example_Counter
import Testing

@Suite
struct `Example.Counter Tests` {

    @Test
    func `increment below the limit succeeds`() throws {
        #expect(try Example.Counter.increment(.init(3), limit: .init(5)) == .init(4))
    }

    @Test
    func `increment at the limit refuses`() {
        do throws(Example.Counter.Error) {
            _ = try Example.Counter.increment(.init(5), limit: .init(5))
            Issue.record("expected a refusal")
        } catch {
            #expect(error == .limit(reached: .init(5)))
        }
    }
}
