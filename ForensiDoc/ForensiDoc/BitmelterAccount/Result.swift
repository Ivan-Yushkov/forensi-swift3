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
    case error(NSError)
    case value(Box<A>)
    
    init(_ error: NSError?, _ value: A) {
        if let err = error {
            self = .error(err)
        } else {
            self = .value(Box(value))
        }
    }
}

func resultFromOptional<A>(_ optional: A?, error: NSError?) -> Result<A> {
    if let a = optional {
        return .value(Box(a))
    } else {
        if let e = error {
            return .error(e)
        }
        return .error(NSError(domain: domainError, code: 0, userInfo: [NSLocalizedDescriptionKey:kUnknownErrorHasOccured]))
    }
}

