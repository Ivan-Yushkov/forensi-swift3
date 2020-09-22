//
//  User.swift
//  ForensiDoc
//
//  Created by Andrzej Czarkowski on 23/11/2014.
//  Copyright (c) 2014 Bitmelter Ltd. All rights reserved.
//

import Foundation

public class User: NSObject, NSSecureCoding {
    private let userNameKey = "username"
    private let passwordKey = "password"
    private let firstNameKey = "firstname"
    private let lastNameKey = "lastname"
    private let logonTokenKey = "logontoken"
    private let activatedKey = "activated"
    private let usingTouchIdKey = "usingtouchid"
    private let passCodeKey = "passcode"
    private let localUserOnlyKey = "localUserOnly"
    
    public var localUserOnly: Bool {
        didSet {
            if localUserOnly != oldValue {
                DataManager.sharedInstance.saveUser(self)
            }
        }
    }
    
    public var passCode: String {
        didSet {
            if passCode != oldValue {
                DataManager.sharedInstance.saveUser(self)
            }
        }
    }
    
    public var usingTouchId: Bool {
        didSet {
            if usingTouchId != oldValue {
                DataManager.sharedInstance.saveUser(self)
            }
        }
    }
    
    public var userName: String {
        didSet {
            if userName != oldValue {
                DataManager.sharedInstance.saveUser(self)
            }
        }
    }
    
    public var password: String {
        didSet {
            if password != oldValue {
                DataManager.sharedInstance.saveUser(self)
            }
        }
    }
    
    public var firstName: String {
        didSet {
            if firstName != oldValue {
                DataManager.sharedInstance.saveUser(self)
            }
        }
    }
    
    public var lastName: String {
        didSet {
            if lastName != oldValue {
                DataManager.sharedInstance.saveUser(self)
            }
        }
    }
    
    public var logonToken: String {
        didSet {
            if logonToken != oldValue {
                DataManager.sharedInstance.saveUser(self)
            }
        }
    }
    
    public var activated: Bool {
        didSet{
            if activated != oldValue {
               DataManager.sharedInstance.saveUser(self)
            }
        }
    }
    
    public override init(){
        self.userName = ""
        self.password = ""
        self.firstName = ""
        self.lastName = ""
        self.logonToken = ""
        self.activated = false
        self.usingTouchId = false
        self.passCode = ""
        self.localUserOnly = false
    }
    
    public func encodeWithCoder(aCoder: NSCoder){
        aCoder.encodeObject(self.userName, forKey: userNameKey)
        aCoder.encodeObject(self.password, forKey: passwordKey)
        aCoder.encodeObject(self.firstName, forKey: firstNameKey)
        aCoder.encodeObject(self.lastName, forKey: lastNameKey)
        aCoder.encodeObject(self.logonToken, forKey: logonTokenKey)
        aCoder.encodeBool(self.activated, forKey: activatedKey)
        aCoder.encodeBool(self.usingTouchId, forKey: usingTouchIdKey)
        aCoder.encodeObject(self.passCode, forKey: passCodeKey)
        aCoder.encodeBool(self.localUserOnly, forKey: localUserOnlyKey)
    }
    
    required public convenience init?(coder aDecoder: NSCoder) {
        self.init()
        if aDecoder.containsValueForKey(userNameKey) {
            //TODO:Tis throws exception
            if let v = aDecoder.decodeObjectForKey(userNameKey) as? String {
                self.userName = v
            }
        }
        
        if aDecoder.containsValueForKey(passwordKey) {
            if let v = aDecoder.decodeObjectForKey(passwordKey) as? String {
                self.password = v
            }
        }
        
        if aDecoder.containsValueForKey(firstNameKey) {
            if let v = aDecoder.decodeObjectForKey(firstNameKey) as? String {
                self.firstName = v
            }
        }
        
        if aDecoder.containsValueForKey(lastNameKey) {
            if let v = aDecoder.decodeObjectForKey(lastNameKey) as? String {
                self.lastName = v
            }
        }
        
        if aDecoder.containsValueForKey(logonTokenKey) {
            if let v = aDecoder.decodeObjectForKey(logonTokenKey) as? String {
                self.logonToken = v
            }
        }
        
        if aDecoder.containsValueForKey(activatedKey) {
            self.activated = aDecoder.decodeBoolForKey(activatedKey)
        }
        
        if aDecoder.containsValueForKey(usingTouchIdKey) {
            self.usingTouchId = aDecoder.decodeBoolForKey(usingTouchIdKey)
        }
        
        if aDecoder.containsValueForKey(passCodeKey) {
            if let v = aDecoder.decodeObjectForKey(passCodeKey) as? String {
                self.passCode = v
            }
        }
        
        if aDecoder.containsValueForKey(localUserOnlyKey) {
            self.localUserOnly = aDecoder.decodeBoolForKey(localUserOnlyKey)
        }
    }
    
    public func isUsingPasscode() -> Bool{
        return self.passCode.characters.count > 0
    }
    
    public func isLoggedOn() -> Bool {
        return
            self.logonToken.characters.count > 0 ||
                    self.localUserOnly
    }
    
    public func isRegisteredButNotActivated() -> Bool {
        return
            self.userName.characters.count > 0 &&
                !self.activated
    }
    
    public func isRegisteredAndActivated() -> Bool {
        return
            self.userName.characters.count > 0 &&
            !self.isRegisteredButNotActivated()
    }
    
    public func hasCreatedPasscode() -> Bool {
        return
            self.passCode.characters.count > 0 ||
            self.usingTouchId
    }
    
    public class func supportsSecureCoding() -> Bool {
        return true
    }
}
