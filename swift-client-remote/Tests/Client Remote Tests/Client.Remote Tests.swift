import Client
import Client_Remote
import Either_Primitives
import Testing

@Suite
struct `Client.Remote Tests` {

    enum Refusal: Swift.Error, Equatable {
        case negative
    }

    enum Outage: Swift.Error, Equatable {
        case down
    }

    static var guarded: Client<Int, Int, Refusal> {
        .init(
            run: { value throws(Refusal) in
                guard value >= 0 else {
                    throw .negative
                }
                return value
            }
        )
    }

    @Test
    func `promotion embeds the domain refusal on the right`() async throws {
        let remote: Client<Int, Int, Refusal>.Remote<Outage> = Self.guarded.promoted()
        #expect(try await remote(7) == 7)
        do throws(Either<Outage, Refusal>) {
            _ = try await remote(-1)
            Issue.record("expected a refusal")
        } catch {
            #expect(error == .right(.negative))
        }
    }

    @Test
    func `a promoted client collapses back at Never`() async {
        let there: Client<Int, Int, Refusal>.Remote<Swift.Never> =
            Self.guarded.promoted()
        let back: Client<Int, Int, Refusal> = there.collapsed()
        do throws(Refusal) {
            _ = try await back(-1)
            Issue.record("expected a refusal")
        } catch {
            #expect(error == .negative)
        }
    }

    @Test
    func `an infallible remote row collapses to the external failure alone`() async {
        let failing = Client<Int, Int, Either<Outage, Swift.Never>>(
            run: { _ throws(Either<Outage, Swift.Never>) in
                throw .left(.down)
            }
        )
        let collapsed: Client<Int, Int, Outage> = failing.collapsed()
        do throws(Outage) {
            _ = try await collapsed(1)
            Issue.record("expected an outage")
        } catch {
            #expect(error == .down)
        }
    }
}
