//
//  UrlsManager.swift
//  ForensiDoc

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
    
    func beginRegisterRequest(_ data: [String : AnyObject]) -> URLRequest {
        return _postJSONRequestWithPath("/auth/register", data: data)
    }
    
    func beginLoginRequest(_ data: [String : AnyObject]) -> URLRequest {
        return _postJSONRequestWithPath("/auth/api", data: data)
    }
    
    func beginLogOutRequest(_ data: [String : AnyObject]) -> URLRequest {
        return _postJSONRequestWithPath("/auth/logout", data: data)
    }
    
    func beginSendNewActivationCode(_ data: [String : AnyObject]) -> URLRequest {
        return _postJSONRequestWithPath("/api/user/activation/send", data: data)
    }
    
    func beginRequestPasswordReset(_ data: [String : AnyObject]) -> URLRequest {
        return _postJSONRequestWithPath("/api/user/password/reset/request", data: data)
    }
    
    func beginPasswordReset(_ data: [String : AnyObject]) -> URLRequest {
        return _postJSONRequestWithPath("/api/user/password/reset", data: data)
    }
    
    func beginAccountDetailChangeRequest(_ data: [String: AnyObject]) -> URLRequest {
        return _postJSONRequestWithPath("/api/user/update", data: data)
    }
    
    func beginActivateAccountRequest(_ email: String, activationCode: String) -> URLRequest {
        let encodedEmail = email.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        var urlEmail = ""
        if let e = encodedEmail {
           urlEmail = e
        }
        return _getJSONRequestWithPath("/auth/activate/\(urlEmail)/\(activationCode)")
    }
    
    fileprivate func _getJSONRequestWithPath(_ path: String) ->URLRequest {
        return _getJSONRequest(path, method: "GET", data: .none)
    }
    
    fileprivate func _postJSONRequestWithPath(_ path: String, data: [String : AnyObject]) -> URLRequest{
        return _getJSONRequest(path, method: "POST", data: data)
    }
    
    fileprivate func _getJSONRequest(_ path: String, method: String, data: [String : AnyObject]?) -> URLRequest {
        
        let fullUrl = "\(scheme)://\(host)\(path)"
        
        let url = URL(string: fullUrl)
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let d = data {
            var jsonSerializationError: NSError?
            let jsonData: Data?
            do {
                jsonData = try JSONSerialization.data(withJSONObject: d, options: .prettyPrinted)
            } catch let error as NSError {
                jsonSerializationError = error
                jsonData = nil
            }
            if let _ = jsonSerializationError {
                
            } else  {
                if let d = jsonData {
                    let jsonString = NSString(data: d, encoding: String.Encoding.utf8.rawValue)
                    request.httpBody = jsonString?.data(using: String.Encoding.ascii.rawValue)
                }
            }
        }
        
        return request as URLRequest
    }
}
