//
//  BaseResponse.swift
//  ForensiDoc

import Foundation

protocol BaseResponseable {
    var error: Bool { get }
    var message: String { get }
}

public struct BaseResponse: JSONDecodable, BaseResponseable {
    let error: Bool
    let message: String
    
    init(_error: Bool, _message: String){
        error = _error;
        message = _message;
    }
    
    static func create(_ error: Bool, message: String) -> BaseResponse {
        return BaseResponse(_error: error, _message: message)
    }
    
    static func decode(_ json: _JSON) -> BaseResponse? {
        if let error = json["error"] >>> JSONBool,
            let message = json["message"]  >>> JSONString  {
            return BaseResponse.create(error, message: message)
        }
        return .none
    }
}
