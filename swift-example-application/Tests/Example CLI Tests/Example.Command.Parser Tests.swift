import Example
import Example_Application
import Example_CLI
import Example_Counter
import Example_Greeting
import Testing

@Suite
struct `Example.Command.Parser Tests` {

    @Test
    func `parses the greet command`() throws {
        var arguments = ArraySlice(["greet", "Ada"])
        #expect(try Example.Command.Parser().parse(&arguments) == .greet(.init("Ada")))
    }

    @Test
    func `parses the increment command`() throws {
        var arguments = ArraySlice(["increment", "3", "5"])
        #expect(
            try Example.Command.Parser().parse(&arguments)
                == .increment(value: .init(3), limit: .init(5))
        )
    }

    @Test
    func `refuses an unknown command`() {
        var arguments = ArraySlice(["frobnicate"])
        do throws(Example.Command.Parser.Error) {
            _ = try Example.Command.Parser().parse(&arguments)
            Issue.record("expected a parse failure")
        } catch {
            #expect(error == .command(found: "frobnicate"))
        }
    }

    @Test
    func `refuses a missing argument`() {
        var arguments = ArraySlice(["increment", "3"])
        do throws(Example.Command.Parser.Error) {
            _ = try Example.Command.Parser().parse(&arguments)
            Issue.record("expected a parse failure")
        } catch {
            #expect(error == .argument(expected: "limit"))
        }
    }

    @Test
    func `refuses a non-numeric argument`() {
        var arguments = ArraySlice(["increment", "three", "5"])
        do throws(Example.Command.Parser.Error) {
            _ = try Example.Command.Parser().parse(&arguments)
            Issue.record("expected a parse failure")
        } catch {
            #expect(error == .number(found: "three"))
        }
    }

    @Test
    func `refuses trailing arguments`() {
        var arguments = ArraySlice(["greet", "Ada", "Lovelace"])
        do throws(Example.Command.Parser.Error) {
            _ = try Example.Command.Parser().parse(&arguments)
            Issue.record("expected a parse failure")
        } catch {
            #expect(error == .trailing(found: "Lovelace"))
        }
    }
}
