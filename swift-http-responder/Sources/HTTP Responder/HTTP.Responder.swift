public import Client
public import HTTP

extension HTTP {

    public typealias Responder<Failure: Swift.Error> =
        Client::Client.Operation<HTTP.Request, HTTP.Response, Failure>
}
