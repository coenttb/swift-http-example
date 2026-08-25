public import Client
public import HTTP

extension HTTP {

    public typealias Responder<Failure: Swift.Error> =
        Client::Client<HTTP.Request, HTTP.Response, Failure>
}
