//
//  NetworkingManager.swift
//  ForensiDoc
//
//  Created by Andrzej Czarkowski on 20/11/2014.
//  Copyright (c) 2014 Bitmelter Ltd. All rights reserved.
//

import Foundation

class NetworkingManager {
    class var sharedInstance: NetworkingManager {
        struct Singleton {
            static let instance = NetworkingManager()
        }
        return Singleton.instance
    }
    
    func login(_ email: String, password: String, callback: @escaping (Result<LoginResponse>) -> ()) -> URLSessionTask {
        let data = ["email" : email, "password" : password]
        let loginRequest = ConnectionManager.sharedInstance.beginLoginRequest(data)
        let task = performRequest(loginRequest, callback: { (baseResponse: Result<LoginResponse>) -> () in
            callback(baseResponse)
        })
        return task
    }
    
    func register(_ email: String, password: String, firstName: String = "", lastName: String = "", callback: @escaping (Result<BaseResponse>) -> ()) -> URLSessionTask {
        
        //TODO:Compose full name
        let name = "John Smith" // "\(firstName) \(lastName)"
        
        
        let data = ["email" : email, "password" : password, "password_confirmation": password, "name" : name]
        
        let registerRequest = ConnectionManager.sharedInstance.beginRegisterRequest(data)
        let task = performRequest(registerRequest, callback: { (baseResponse: Result<BaseResponse>) -> () in
            callback(baseResponse)
        })
        return task
    }
    
    func requestPasswordReset(_ email: String, callback: @escaping (Result<BaseResponse>) -> ()) -> URLSessionTask {
        let data = ["email" : email]
        
        let beginPasswordResetRequest = ConnectionManager.sharedInstance.beginRequestPasswordReset(data)
        let task = performRequest(beginPasswordResetRequest, callback: { (baseResponse: Result<BaseResponse>) -> () in
            callback(baseResponse)
        })
        return task
    }
    
    func resetPassword(_ email: String, newPassword: String, resetCode: String, callback: @escaping (Result<BaseResponse>) -> ()) -> URLSessionTask {
        let data = ["email": email, "new_password": newPassword, "code": resetCode]
        let passwordResetRequest = ConnectionManager.sharedInstance.beginPasswordReset(data)
        let task = performRequest(passwordResetRequest, callback: { (baseResponse: Result<BaseResponse>) -> () in
            callback(baseResponse)
        })
        
        return task
    }
    
    func activateAccount(_ email: String, activationCode: String, callback: @escaping (Result<BaseResponse>) -> ()) -> URLSessionTask {
        let activateRequest = ConnectionManager.sharedInstance.beginActivateAccountRequest(email, activationCode: activationCode)
        let task = performRequest(activateRequest, callback: { (baseResponse: Result<BaseResponse>) -> () in
            callback(baseResponse)
        })
        return task
    }
    
    func sendNewActivationCode(_ email: String, callback: @escaping (Result<BaseResponse>) -> ()) -> URLSessionTask {
        let data = ["email": email]
        let sendNewActivationCodeRequest = ConnectionManager.sharedInstance.beginSendNewActivationCode(data)
        let task = performRequest(sendNewActivationCodeRequest, callback: { (baseResponse: Result<BaseResponse>) -> () in
            callback(baseResponse)
        })
        return task
    }
    
    func changeAccountDetails(_ currentEmail: String, newEmail: String, firstName: String, lastName: String, callback: @escaping (Result<BaseResponse>) -> ()) -> URLSessionTask {
        let data = ["email": currentEmail, "new_email": newEmail, "first_name": firstName, "last_name": lastName]
        let changeAccountDetailsRequest = ConnectionManager.sharedInstance.beginAccountDetailChangeRequest(data)
        let task = performRequest(changeAccountDetailsRequest, callback: { (baseResponse: Result<BaseResponse>) -> () in
            callback(baseResponse)
        })
        return task
    }
}
