public import Example
public import Example_Greeting
public import HTTP
public import HTTP_Coder

extension Example.Greeting {

    public enum Endpoint {

        public static var greeting: HTTP.Endpoint<Request, Response> {
            .init(request: .init(), response: .init())
        }
    }
}
