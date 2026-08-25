public import Byte_Primitive
public import Coder_Witness_Primitives
public import Example
public import Example_Greeting
public import HTTP
public import HTTP_Coder
public import Parser_Primitive
import RFC_3986
public import Serializer_Primitive

extension Example.Greeting.Endpoint {

    public struct Request: Coder.`Protocol` {

        public typealias Input = HTTP.Request?
        public typealias Output = Example.Greeting.Name
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
                        path.segments == ["greeting"],
                        let body = request.body
                    else {
                        throw .request
                    }

                    input = nil
                    return .init(String(decoding: body.lazy.map(\.underlying), as: UTF8.self))
                },
                serialize: { name, buffer throws(Failure) in
                    buffer = .init(
                        method: .post,
                        target: .origin(path: ["greeting"], query: nil),
                        body: name.underlying.utf8.map(Byte.init)
                    )
                }
            )
        }
    }
}
