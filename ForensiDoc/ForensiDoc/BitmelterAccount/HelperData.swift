//
//  HelperData.swift
//  ForensiDoc

import Foundation

open class HelperData: NSObject, NSSecureCoding {
    fileprivate let emailForPasswordResetKey = "emailForPasswordResetKey"
    fileprivate let accountActivationCodeKey = "accountActivationCodeKey"
    fileprivate let resetPasswordCodeKey = "resetPasswordCodeKey"
    
    open var emailForPasswordRest: String {
        didSet {
            if emailForPasswordRest != oldValue {
                DataManager.sharedInstance.saveHelperData(self)
            }
        }
    }
    
    open var accountActivationCode: String {
        didSet {
            if accountActivationCode != oldValue {
                DataManager.sharedInstance.saveHelperData(self)
            }
        }
    }
    
    open var resetPasswordCode: String {
        didSet {
            if resetPasswordCode != oldValue {
                DataManager.sharedInstance.saveHelperData(self)
            }
        }
    }
    
    override init() {
        self.emailForPasswordRest = ""
        self.accountActivationCode = ""
        self.resetPasswordCode = ""
    }
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(self.emailForPasswordRest, forKey: emailForPasswordResetKey)
        aCoder.encode(self.accountActivationCode, forKey: accountActivationCodeKey)
        aCoder.encode(self.resetPasswordCode, forKey: resetPasswordCodeKey)
    }
    
    required convenience public init?(coder aDecoder: NSCoder) {
        self.init()
        if aDecoder.containsValue(forKey: emailForPasswordResetKey) {
            if let v = aDecoder.decodeObject(forKey: emailForPasswordResetKey) as? String {
                self.emailForPasswordRest = v
            }
        }
        if aDecoder.containsValue(forKey: accountActivationCodeKey) {
            if let v = aDecoder.decodeObject(forKey: accountActivationCodeKey) as? String  {
                self.accountActivationCode = v
            }
        }
        if aDecoder.containsValue(forKey: resetPasswordCodeKey) {
            if let v = aDecoder.decodeObject(forKey: resetPasswordCodeKey) as? String {
                self.resetPasswordCode = v
            }
        }
    }
    
    open func hasResetPasswordCode() -> Bool {
        return self.resetPasswordCode.count > 0
    }
    
    open func hasAccountActivationCode() -> Bool {
        return self.accountActivationCode.count > 0
    }
    
    public class var supportsSecureCoding : Bool {
        return true
    }
}
