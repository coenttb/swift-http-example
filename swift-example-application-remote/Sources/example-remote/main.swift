import Application_Primitives
import Client
import Client_Remote
import Either_Primitives
import Example
import Example_Application
import Example_Application_Remote
import Example_CLI
import Example_Client
import Example_Client_Remote
import Example_Counter
import Example_Counter_Client_Remote
import Example_Greeting
import Example_Greeting_Client_Remote

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
    print("usage: example-remote greet <name> | increment <value> <limit>")
    print("error: \(error)")
    exit(64)
}

let remote = Example.Client.Remote<Swift.Never>(
    greeting: .init(
        greet: .init(run: { name in Example.Greeting.greet(name) })
    ),
    counter: .init(
        increment: Client.Operation(
            run: { (increment: Example.Counter.Increment) throws(Example.Counter.Error) in
                try Example.Counter.increment(increment.value, limit: increment.limit)
            }
        ).promoted()
    )
)

let application = Example.Application(remote)

do throws(Either<Swift.Never, Example.Command.Error>) {
    let output = try await application.interpret(command)
    print(output.line)
} catch {
    switch error.value {
    case .counter(.limit(let reached)):
        print("refused: limit \(reached.underlying) reached")
    }
    exit(1)
}
