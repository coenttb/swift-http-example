public import Either_Primitives
public import Client
public import Example
public import Example_Counter
public import Example_Counter_Client
public import Example_Counter_Client_Remote
public import HTTP
public import HTTP_Client
public import HTTP_Coder
public import HTTP_Responder

extension Example.Counter.Endpoint {

    public static func remote<TransportFailure: Swift.Error>(
        using transport: HTTP.Client<TransportFailure>
    ) -> Example.Counter.Client.Remote<Either<TransportFailure, HTTP.Coding.Error>> {
        .init(increment: counter.client(using: transport))
    }

    public static func responder(
        using client: Example.Counter.Client
    ) -> HTTP.Responder<HTTP.Coding.Error> {
        counter.responder(using: .init(run: client.increment))
    }
}
