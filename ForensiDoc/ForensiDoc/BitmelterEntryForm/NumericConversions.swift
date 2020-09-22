//
//  NumericStringConversions.swift
//  BitmelterEntryForm
//
//  Created by Andrzej Czarkowski on 27/05/2015.
//  Copyright (c) 2015 Bitmelter Ltd. All rights reserved.
//

import Foundation

public extension String {
    func toDouble() -> Double? {
        let f = NumberFormatter()
        f.numberStyle = NumberFormatter.Style.decimal
        
        if let n = f.number(from: self) {
            return n.doubleValue
        }
        return .none
    }
    
    func toFloat() -> Float? {
        let f = NumberFormatter()
        f.numberStyle = NumberFormatter.Style.decimal
        
        if let n = f.number(from: self) {
            return n.floatValue
        }
        return .none
    }
    
    func toInt() -> Int? {
        let f = NumberFormatter()
        f.numberStyle = NumberFormatter.Style.decimal
        
        if let n = f.number(from: self) {
            return n.intValue
        }
        return .none
    }
}

public extension NSString {
    func toInt() -> Int? {
        let f = NumberFormatter()
        f.numberStyle = NumberFormatter.Style.decimal
        
        if let n = f.number(from: self as String) {
            return n.intValue
        }
        
        return .none
    }
    
    func toDouble() -> Double? {
        let f = NumberFormatter()
        f.numberStyle = NumberFormatter.Style.decimal
        
        if let n = f.number(from: self as String) {
            return n.doubleValue
        }
        return .none
    }
    
    func toFloat() -> Float? {
        let f = NumberFormatter()
        f.numberStyle = NumberFormatter.Style.decimal
        
        if let n = f.number(from: self as String) {
            return n.floatValue
        }
        return .none
    }
}

public extension Double {
    func format(_ f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}

public extension Float {
    func format(_ f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}

public extension Int {
    func format(_ f: String) -> String {
        return String(format: "%\(f)d", self)
    }
}
