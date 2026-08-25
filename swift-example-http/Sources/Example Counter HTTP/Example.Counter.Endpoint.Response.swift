public import Byte_Primitive
public import Coder_Witness_Primitives
public import Either_Primitives
public import Example
public import Example_Counter
public import HTTP
public import HTTP_Coder
public import Parser_Primitive
public import Serializer_Primitive

extension Example.Counter.Endpoint {

    public struct Response: Coder.`Protocol` {

        public typealias Input = HTTP.Response?
        public typealias Output = Either<Example.Counter.Error, Example.Counter.Value>
        public typealias Buffer = HTTP.Response?
        public typealias Failure = HTTP.Coding.Error
        public typealias Body = Coder.Witness<Input, Output, Buffer, Failure>

        public init() {}

        public var body: Body {
            Body(
                parse: { input throws(Failure) in
                    guard
                        let response = input,
                        let body = response.body,
                        let value = Swift.Int(
                            String(decoding: body.lazy.map(\.underlying), as: UTF8.self)
                        )
                    else {
                        throw .response
                    }

                    input = nil
                    switch response.status {
                    case .ok:
                        return .right(.init(value))

                    case .badRequest:
                        return .left(.limit(reached: .init(value)))

                    default:
                        throw .response
                    }
                },
                serialize: { output, buffer throws(Failure) in
                    switch output {
                    case .left(.limit(reached: let limit)):
                        buffer = .init(
                            status: .badRequest,
                            body: String(limit.underlying).utf8.map(Byte.init)
                        )

                    case .right(let value):
                        buffer = .init(
                            status: .ok,
                            body: String(value.underlying).utf8.map(Byte.init)
                        )
                    }
                }
            )
        }
    }
}
