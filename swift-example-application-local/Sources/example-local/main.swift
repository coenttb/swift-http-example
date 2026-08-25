import Application
import Example
import Example_Application
import Example_CLI
import Example_Client
import Example_Client_Local
import Example_Counter

#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#endif

var arguments = CommandLine.arguments.dropFirst()
let command: Example.Command
do throws(Example.Command.Parser.Error) {
    command = try Example.Command.Parser().parse(&arguments)
} catch {
    print("usage: example-local greet <name> | increment <value> <limit>")
    print("error: \(error)")
    exit(64)
}

let application = Example.Application(Example.Client.local)

do throws(Example.Command.Error) {
    let output = try await application.interpret(command)
    print(output.line)
} catch {
    switch error {
    case .counter(.limit(let reached)):
        print("refused: limit \(reached.underlying) reached")
    }
    exit(1)
}
