//
//  LoginResponse.swift
//  ForensiDoc
//
//  Created by Andrzej Czarkowski on 26/11/2014.
//  Copyright (c) 2014 Bitmelter Ltd. All rights reserved.
//

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
    
    static func create(error: Bool)(message: String)(token: String) -> LoginResponse {
        return LoginResponse(_error: error, _message: message, _token: token)
    }
    
    static func decode(json: _JSON) -> LoginResponse? {
        //TODO:When there is a key missing (like in this case it was token) then initialization of object stops whereas it should skip and initialize missing to default one
        return JSONObject(json) >>> { d in
            LoginResponse.create <^>
                d["error"]    >>> JSONBool    <*>
                d["message"]  >>> JSONString  <*>
                JSONString(d["token"], defValue: "")
        }
    }
}
