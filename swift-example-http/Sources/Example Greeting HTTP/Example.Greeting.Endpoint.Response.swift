public import Byte_Primitive
public import Coder_Witness_Primitives
public import Either_Primitives
public import Example
public import Example_Greeting
public import HTTP
public import HTTP_Coder
public import Parser_Primitive
public import Serializer_Primitive

extension Example.Greeting.Endpoint {

    public struct Response: Coder.`Protocol` {

        public typealias Input = HTTP.Response?
        public typealias Output = Either<Swift.Never, Example.Greeting.Message>
        public typealias Buffer = HTTP.Response?
        public typealias Failure = HTTP.Coding.Error
        public typealias Body = Coder.Witness<Input, Output, Buffer, Failure>

        public init() {}

        public var body: Body {
            Body(
                parse: { input throws(Failure) in
                    guard
                        let response = input,
                        response.status == .ok,
                        let body = response.body
                    else {
                        throw .response
                    }

                    input = nil
                    return .right(
                        .init(String(decoding: body.lazy.map(\.underlying), as: UTF8.self))
                    )
                },
                serialize: { output, buffer throws(Failure) in
                    switch output {
                    case .left(let impossible):
                        switch impossible {}

                    case .right(let message):
                        buffer = .init(
                            status: .ok,
                            body: message.underlying.utf8.map(Byte.init)
                        )
                    }
                }
            )
        }
    }
}
