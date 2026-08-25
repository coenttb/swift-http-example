public import Example
public import Example_Counter
public import Example_Counter_Client
import Client

extension Example.Counter.Client {

    public static var local: Self {
        .init(
            increment: .init(
                run: { increment throws(Example.Counter.Error) in
                    try Example.Counter.increment(increment.value, limit: increment.limit)
                }
            )
        )
    }
}
