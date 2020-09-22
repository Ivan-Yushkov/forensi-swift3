//
//  HelperData.swift
//  ForensiDoc
//
//  Created by Andrzej Czarkowski on 14/01/2015.
//  Copyright (c) 2015 Bitmelter Ltd. All rights reserved.
//

import Foundation

public class HelperData: NSObject, NSSecureCoding {
    private let emailForPasswordResetKey = "emailForPasswordResetKey"
    private let accountActivationCodeKey = "accountActivationCodeKey"
    private let resetPasswordCodeKey = "resetPasswordCodeKey"
    
    public var emailForPasswordRest: String {
        didSet {
            if emailForPasswordRest != oldValue {
                DataManager.sharedInstance.saveHelperData(self)
            }
        }
    }
    
    public var accountActivationCode: String {
        didSet {
            if accountActivationCode != oldValue {
                DataManager.sharedInstance.saveHelperData(self)
            }
        }
    }
    
    public var resetPasswordCode: String {
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
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.emailForPasswordRest, forKey: emailForPasswordResetKey)
        aCoder.encodeObject(self.accountActivationCode, forKey: accountActivationCodeKey)
        aCoder.encodeObject(self.resetPasswordCode, forKey: resetPasswordCodeKey)
    }
    
    required convenience public init?(coder aDecoder: NSCoder) {
        self.init()
        if aDecoder.containsValueForKey(emailForPasswordResetKey) {
            if let v = aDecoder.decodeObjectForKey(emailForPasswordResetKey) as? String {
                self.emailForPasswordRest = v
            }
        }
        if aDecoder.containsValueForKey(accountActivationCodeKey) {
            if let v = aDecoder.decodeObjectForKey(accountActivationCodeKey) as? String  {
                self.accountActivationCode = v
            }
        }
        if aDecoder.containsValueForKey(resetPasswordCodeKey) {
            if let v = aDecoder.decodeObjectForKey(resetPasswordCodeKey) as? String {
                self.resetPasswordCode = v
            }
        }
    }
    
    public func hasResetPasswordCode() -> Bool {
        return self.resetPasswordCode.characters.count > 0
    }
    
    public func hasAccountActivationCode() -> Bool {
        return self.accountActivationCode.characters.count > 0
    }
    
    public class func supportsSecureCoding() -> Bool {
        return true
    }
}