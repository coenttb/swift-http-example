public import Byte_Primitive
public import Coder_Witness_Primitives
public import Example
public import Example_Counter
public import HTTP
public import HTTP_Coder
public import Parser_Primitive
import RFC_3986
public import Serializer_Primitive

extension Example.Counter.Endpoint {

    public struct Request: Coder.`Protocol` {

        public typealias Input = HTTP.Request?
        public typealias Output = Example.Counter.Limit
        public typealias Buffer = HTTP.Request?
        public typealias Failure = HTTP.Coding.Error
        public typealias Body = Coder.Witness<Input, Output, Buffer, Failure>

        public init() {}

        public var body: Body {
            Body(
                parse: { input throws(Failure) in
                    guard
                        let request = input,
                        request.method == .post,
                        case .origin(let path, nil) = request.target,
                        path.segments == ["counter"],
                        let body = request.body,
                        let limit = Swift.Int(
                            String(decoding: body.lazy.map(\.underlying), as: UTF8.self)
                        )
                    else {
                        throw .request
                    }

                    input = nil
                    return .init(limit)
                },
                serialize: { limit, buffer throws(Failure) in
                    buffer = .init(
                        method: .post,
                        target: .origin(path: ["counter"], query: nil),
                        body: String(limit.underlying).utf8.map(Byte.init)
                    )
                }
            )
        }
    }
}
