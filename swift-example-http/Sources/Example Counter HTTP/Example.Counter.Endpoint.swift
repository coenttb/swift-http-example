public import Example
public import Example_Counter
public import HTTP
public import HTTP_Coder

extension Example.Counter {

    public enum Endpoint {

        public static var counter: HTTP.Endpoint<Request, Response> {
            .init(request: .init(), response: .init())
        }
    }
}
