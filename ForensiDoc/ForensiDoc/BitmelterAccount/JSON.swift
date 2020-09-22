//
//  JSON.swift
//  ForensiDoc

import Foundation

typealias _JSON = AnyObject
typealias JSONDictionary = Dictionary<String, _JSON>
typealias JSONArray = Array<_JSON>

protocol JSONDecodable {
    static func decode(_ json: _JSON) -> Self?
}


func JSONBool(_ object: _JSON) -> Bool? {
    return object as? Bool;
}

func JSONBool(_ object: _JSON?, defValue: Bool) ->Bool? {
    if let b = object as? Bool {
        return b
    }
    return defValue
}

func JSONString(_ object: _JSON) -> String? {
    let r = object as? String
    return r
}

func JSONString(_ object: _JSON?, defValue: String) -> String {
    if let s = object as? String {
        return s
    }
    return defValue
}

func JSONInt(_ object: _JSON) -> Int? {
    let r = object as? Int
    return r
}

func JSONInt(_ object: _JSON?, defValue: Int) -> Int? {
    if let i = object as? Int {
        return i
    }
    return defValue
}

func JSONObject(_ object: _JSON) -> JSONDictionary? {
    let r = object as? JSONDictionary
    return r
}

func decodeJSON(_ data: Data) -> Result<_JSON> {
    var jsonErrorOptional: NSError?
    let jsonOptional: _JSON!
    do {
        jsonOptional = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0))
    } catch let error as NSError {
        jsonErrorOptional = error
        jsonOptional = nil
    }
    
    return resultFromOptional(jsonOptional, error: jsonErrorOptional)
}

func decodeObject<A: JSONDecodable>(_ json: _JSON) -> Result<A> {
    let error = NSError(domain: domainError, code: 0, userInfo: [NSLocalizedDescriptionKey:kUnableToDecodeResponseError])
    return resultFromOptional(A.decode(json), error: error)
}
