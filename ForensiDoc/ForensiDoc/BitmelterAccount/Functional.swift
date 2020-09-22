//
//  Functional.swift
//  ForensiDoc

import Foundation

infix operator >>> { associativity left precedence 150 }
infix operator <^> { associativity left } // Functor's fmap (usually <$>)
infix operator <*> { associativity left } // Applicative's apply

func >>><A, B>(a: A?, f: (A) -> B?) -> B? {
    if let x = a {
        return f(x)
    } else {
        return .none
    }
}

func >>><A, B>(a: Result<A>, f: (A) -> Result<B>) -> Result<B> {
    switch a {
    case let .value(x):     return f(x.value)
    case let .error(error): return .error(error)
    }
}

func <^><A, B>(f: (A) -> B, a: A?) -> B? {
    if let x = a {
        return f(x)
    } else {
        return .none
    }
}

func <*><A, B>(f: ((A) -> B)?, a: A?) -> B? {
    if let x = a {
        if let fx = f {
            return fx(x)
        }
    }
    return .none
}
