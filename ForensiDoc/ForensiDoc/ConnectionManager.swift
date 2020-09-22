//
//  UrlsManager.swift
//  ForensiDoc
//
//  Created by Andrzej Czarkowski on 20/11/2014.
//  Copyright (c) 2014 Bitmelter Ltd. All rights reserved.
//

import Foundation

class ConnectionManager {
    class var sharedInstance :ConnectionManager {
        struct Singleton {
            static let instance = ConnectionManager()
        }
        
        return Singleton.instance
    }
    
    let scheme : String = "http"
    let host : String = "forensidoc.dev"
    
    func beginRegisterRequest(data: [String : AnyObject]) -> NSURLRequest {
        return _postJSONRequestWithPath("/auth/register", data: data)
    }
    
    func beginLoginRequest(data: [String : AnyObject]) -> NSURLRequest {
        return _postJSONRequestWithPath("/auth/api", data: data)
    }
    
    func beginLogOutRequest(data: [String : AnyObject]) -> NSURLRequest {
        return _postJSONRequestWithPath("/auth/logout", data: data)
    }
    
    func beginSendNewActivationCode(data: [String : AnyObject]) -> NSURLRequest {
        return _postJSONRequestWithPath("/api/user/activation/send", data: data)
    }
    
    func beginRequestPasswordReset(data: [String : AnyObject]) -> NSURLRequest {
        return _postJSONRequestWithPath("/api/user/password/reset/request", data: data)
    }
    
    func beginPasswordReset(data: [String : AnyObject]) -> NSURLRequest {
        return _postJSONRequestWithPath("/api/user/password/reset", data: data)
    }
    
    func beginAccountDetailChangeRequest(data: [String: AnyObject]) -> NSURLRequest {
        return _postJSONRequestWithPath("/api/user/update", data: data)
    }
    
    func beginActivateAccountRequest(email: String, activationCode: String) -> NSURLRequest {
        let encodedEmail = email.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
        var urlEmail = ""
        if let e = encodedEmail {
           urlEmail = e
        }
        return _getJSONRequestWithPath("/auth/activate/\(urlEmail)/\(activationCode)")
    }
    
    private func _getJSONRequestWithPath(path: String) ->NSURLRequest {
        return _getJSONRequest(path, method: "GET", data: .None)
    }
    
    private func _postJSONRequestWithPath(path: String, data: [String : AnyObject]) -> NSURLRequest{
        return _getJSONRequest(path, method: "POST", data: data)
    }
    
    private func _getJSONRequest(path: String, method: String, data: [String : AnyObject]?) -> NSURLRequest {
        
        let fullUrl = "\(scheme)://\(host)\(path)"
        
        let url = NSURL(string: fullUrl)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let d = data {
            var jsonSerializationError: NSError?
            let jsonData: NSData?
            do {
                jsonData = try NSJSONSerialization.dataWithJSONObject(d, options: .PrettyPrinted)
            } catch let error as NSError {
                jsonSerializationError = error
                jsonData = nil
            }
            if let _ = jsonSerializationError {
                
            } else  {
                if let d = jsonData {
                    let jsonString = NSString(data: d, encoding: NSUTF8StringEncoding)
                    request.HTTPBody = jsonString?.dataUsingEncoding(NSASCIIStringEncoding)
                }
            }
        }
        
        return request
    }
}
