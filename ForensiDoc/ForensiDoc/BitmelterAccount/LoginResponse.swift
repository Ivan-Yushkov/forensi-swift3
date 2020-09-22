//
//  LoginResponse.swift
//  ForensiDoc

import Foundation

public struct LoginResponse : JSONDecodable, BaseResponseable {
    let error: Bool
    let message: String
    let token: String
    
    init(_error: Bool, _message: String, _token: String){
        error = _error
        message = _message
        token = _token
    }
    
    static func create(_ error: Bool, message: String, token: String) -> LoginResponse {
        return LoginResponse(_error: error, _message: message, _token: token)
    }
    
    static func decode(_ json: _JSON) -> LoginResponse? {
        //TODO:When there is a key missing (like in this case it was token) then initialization of object stops whereas it should skip and initialize missing to default one
        if let error = json["error"] >>> JSONBool,
            let message = json["message"]  >>> JSONString {
            return LoginResponse.create(error, message: message, token: JSONString(json["token"], defValue: ""))
        }
        return .none
    }
}
