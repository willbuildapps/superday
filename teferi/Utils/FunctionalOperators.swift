import Foundation

precedencegroup ForwardComposition {
    associativity: left
}

infix operator >>>: ForwardComposition
func >>> <A, B, C>(f: @escaping (A) -> B, g: @escaping (B) -> C) -> ((A) -> C)
{
    return { a in
        return g(f(a))
    }
}
