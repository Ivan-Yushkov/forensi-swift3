//
//  JSON.swift
//  ForensiDoc
//
//  Created by Andrzej Czarkowski on 22/11/2014.
//  Copyright (c) 2014 Bitmelter Ltd. All rights reserved.
//

import Foundation

typealias _JSON = AnyObject
typealias JSONDictionary = Dictionary<String, _JSON>
typealias JSONArray = Array<_JSON>

protocol JSONDecodable {
    static func decode(json: _JSON) -> Self?
}


func JSONBool(object: _JSON) -> Bool? {
    return object as? Bool;
}

func JSONBool(object: _JSON?, defValue: Bool) ->Bool? {
    if let b = object as? Bool {
        return b
    }
    return defValue
}

func JSONString(object: _JSON) -> String? {
    let r = object as? String
    return r
}

func JSONString(object: _JSON?, defValue: String) -> String {
    if let s = object as? String {
        return s
    }
    return defValue
}

func JSONInt(object: _JSON) -> Int? {
    let r = object as? Int
    return r
}

func JSONInt(object: _JSON?, defValue: Int) -> Int? {
    if let i = object as? Int {
        return i
    }
    return defValue
}

func JSONObject(object: _JSON) -> JSONDictionary? {
    let r = object as? JSONDictionary
    return r
}

func decodeJSON(data: NSData) -> Result<_JSON> {
    var jsonErrorOptional: NSError?
    let jsonOptional: _JSON!
    do {
        jsonOptional = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
    } catch let error as NSError {
        jsonErrorOptional = error
        jsonOptional = nil
    }
    
    return resultFromOptional(jsonOptional, error: jsonErrorOptional)
}

func decodeObject<A: JSONDecodable>(json: _JSON) -> Result<A> {
    let error = NSError(domain: domainError, code: 0, userInfo: [NSLocalizedDescriptionKey:kUnableToDecodeResponseError])
    return resultFromOptional(A.decode(json), error: error)
}
