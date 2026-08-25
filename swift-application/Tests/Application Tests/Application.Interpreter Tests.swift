import Application
import Testing

@Suite
struct `Application.Interpreter Tests` {

    @Test
    func `an interpreter folds input to output`() async {
        let double = Application.Interpreter<Int, Int, Never>(interpret: { value in value * 2 })
        #expect(await double(21) == 42)
    }

    @Test
    func `an interpreter surfaces its declared failure`() async throws {
        enum Refusal: Swift.Error, Equatable {
            case negative
        }
        let guarded = Application.Interpreter<Int, Int, Refusal>(
            interpret: { value throws(Refusal) in
                guard value >= 0 else {
                    throw .negative
                }
                return value
            }
        )
        #expect(try await guarded(7) == 7)
        do throws(Refusal) {
            _ = try await guarded(-1)
            Issue.record("expected a refusal")
        } catch {
            #expect(error == .negative)
        }
    }
}
