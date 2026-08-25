public import Client
public import Either_Primitives
public import HTTP
public import HTTP_Coder
public import Parser_Primitive
import Serializer_Primitive

extension HTTP.Endpoint {

    public func responder<Output, DomainFailure: Swift.Error>(
        using service: Client<RequestCoder.Output, Output, DomainFailure>
    ) -> HTTP.Responder<HTTP.Coding.Error>
    where ResponseCoder.Output == Either<DomainFailure, Output> {
        .init(
            run: { request throws(HTTP.Coding.Error) in
                var buffered = Optional(request)
                let input = try self.request.parse(&buffered)
                let outcome: Either<DomainFailure, Output>

                do throws(DomainFailure) {
                    outcome = .right(try await service.run(input))
                } catch {
                    outcome = .left(error)
                }

                var response: HTTP.Response?
                try self.response.serialize(outcome, into: &response)

                guard let response else {
                    throw .response
                }

                return response
            }
        )
    }
}
