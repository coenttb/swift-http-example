public import Client
import Client_Remote
public import Either_Primitives
public import Example
public import Example_Greeting
public import Example_Greeting_Client
public import Example_Greeting_Client_Remote
public import HTTP
public import HTTP_Client
public import HTTP_Coder
public import HTTP_Responder

extension Example.Greeting.Endpoint {

    public static func remote<TransportFailure: Swift.Error>(
        using transport: HTTP.Client<TransportFailure>
    ) -> Example.Greeting.Client.Remote<Either<TransportFailure, HTTP.Coding.Error>> {
        let operation: Client<
            Example.Greeting.Name,
            Example.Greeting.Message,
            Either<Either<TransportFailure, HTTP.Coding.Error>, Swift.Never>
        > = greeting.client(using: transport)

        return .init(greet: operation.collapsed())
    }

    public static func responder(
        using client: Example.Greeting.Client
    ) -> HTTP.Responder<HTTP.Coding.Error> {
        greeting.responder(using: .init(run: client.greet))
    }
}
