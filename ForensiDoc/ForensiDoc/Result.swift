//
//  Result.swift
//  ForensiDoc
//
//  Created by Andrzej Czarkowski on 22/11/2014.
//  Copyright (c) 2014 Bitmelter Ltd. All rights reserved.
//

import Foundation

final class Box<A> {
    let value: A
    
    init(_ value: A) {
        self.value = value
    }
}


enum Result<A> {
    case Error(NSError)
    case Value(Box<A>)
    
    init(_ error: NSError?, _ value: A) {
        if let err = error {
            self = .Error(err)
        } else {
            self = .Value(Box(value))
        }
    }
}

func resultFromOptional<A>(optional: A?, error: NSError?) -> Result<A> {
    if let a = optional {
        return .Value(Box(a))
    } else {
        if let e = error {
            return .Error(e)
        }
        return .Error(NSError(domain: domainError, code: 0, userInfo: [NSLocalizedDescriptionKey:kUnknownErrorHasOccured]))
    }
}

