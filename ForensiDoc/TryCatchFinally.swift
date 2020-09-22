//
//  TryCatchFinally.swift
//  ForensiDoc
//
//  Created by Andrzej Czarkowski on 19/05/2016.
//  Copyright © 2016 Bitmelter Ltd. All rights reserved.
//

import Foundation


func hack_try(_ hack_try:@escaping ()->()) -> TryCatch {
    return TryCatch(hack_try)
}
class TryCatch {
    let tryFunc : ()->()
    var catchFunc = { (e:NSException!)->() in return }
    var finallyFunc : ()->() = {}
    
    init(_ hack_try:@escaping ()->()) {
        tryFunc = hack_try
    }
    
    func hack_catch(_ hack_catch:@escaping (NSException)->()) -> TryCatch {
        // objc bridging needs NSException!, not NSException as we'd like to expose to clients.
        catchFunc = { (e:NSException!) in hack_catch(e) }
        return self
    }
    
    func finally(_ finally:@escaping ()->()) {
        finallyFunc = finally
    }
    
    deinit {
        tryCatchFinally(tryFunc, catchFunc, finallyFunc)
    }
}
