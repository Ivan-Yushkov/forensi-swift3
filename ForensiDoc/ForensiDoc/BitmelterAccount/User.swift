//
//  User.swift
//  ForensiDoc
//
//  Created by Andrzej Czarkowski on 23/11/2014.
//  Copyright (c) 2014 Bitmelter Ltd. All rights reserved.
//

import Foundation

open class User: NSObject, NSSecureCoding {
    fileprivate let userNameKey = "username"
    fileprivate let passwordKey = "password"
    fileprivate let firstNameKey = "firstname"
    fileprivate let lastNameKey = "lastname"
    fileprivate let logonTokenKey = "logontoken"
    fileprivate let activatedKey = "activated"
    fileprivate let usingTouchIdKey = "usingtouchid"
    fileprivate let passCodeKey = "passcode"
    fileprivate let localUserOnlyKey = "localUserOnly"
    
    open var localUserOnly: Bool {
        didSet {
            if localUserOnly != oldValue {
                DataManager.sharedInstance.saveUser(self)
            }
        }
    }
    
    open var passCode: String {
        didSet {
            if passCode != oldValue {
                DataManager.sharedInstance.saveUser(self)
            }
        }
    }
    
    open var usingTouchId: Bool {
        didSet {
            if usingTouchId != oldValue {
                DataManager.sharedInstance.saveUser(self)
            }
        }
    }
    
    open var userName: String {
        didSet {
            if userName != oldValue {
                DataManager.sharedInstance.saveUser(self)
            }
        }
    }
    
    open var password: String {
        didSet {
            if password != oldValue {
                DataManager.sharedInstance.saveUser(self)
            }
        }
    }
    
    open var firstName: String {
        didSet {
            if firstName != oldValue {
                DataManager.sharedInstance.saveUser(self)
            }
        }
    }
    
    open var lastName: String {
        didSet {
            if lastName != oldValue {
                DataManager.sharedInstance.saveUser(self)
            }
        }
    }
    
    open var logonToken: String {
        didSet {
            if logonToken != oldValue {
                DataManager.sharedInstance.saveUser(self)
            }
        }
    }
    
    open var activated: Bool {
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
    
    open func encode(with aCoder: NSCoder){
        aCoder.encode(self.userName, forKey: userNameKey)
        aCoder.encode(self.password, forKey: passwordKey)
        aCoder.encode(self.firstName, forKey: firstNameKey)
        aCoder.encode(self.lastName, forKey: lastNameKey)
        aCoder.encode(self.logonToken, forKey: logonTokenKey)
        aCoder.encode(self.activated, forKey: activatedKey)
        aCoder.encode(self.usingTouchId, forKey: usingTouchIdKey)
        aCoder.encode(self.passCode, forKey: passCodeKey)
        aCoder.encode(self.localUserOnly, forKey: localUserOnlyKey)
    }
    
    required public convenience init?(coder aDecoder: NSCoder) {
        self.init()
        if aDecoder.containsValue(forKey: userNameKey) {
            //TODO:Tis throws exception
            if let v = aDecoder.decodeObject(forKey: userNameKey) as? String {
                self.userName = v
            }
        }
        
        if aDecoder.containsValue(forKey: passwordKey) {
            if let v = aDecoder.decodeObject(forKey: passwordKey) as? String {
                self.password = v
            }
        }
        
        if aDecoder.containsValue(forKey: firstNameKey) {
            if let v = aDecoder.decodeObject(forKey: firstNameKey) as? String {
                self.firstName = v
            }
        }
        
        if aDecoder.containsValue(forKey: lastNameKey) {
            if let v = aDecoder.decodeObject(forKey: lastNameKey) as? String {
                self.lastName = v
            }
        }
        
        if aDecoder.containsValue(forKey: logonTokenKey) {
            if let v = aDecoder.decodeObject(forKey: logonTokenKey) as? String {
                self.logonToken = v
            }
        }
        
        if aDecoder.containsValue(forKey: activatedKey) {
            self.activated = aDecoder.decodeBool(forKey: activatedKey)
        }
        
        if aDecoder.containsValue(forKey: usingTouchIdKey) {
            self.usingTouchId = aDecoder.decodeBool(forKey: usingTouchIdKey)
        }
        
        if aDecoder.containsValue(forKey: passCodeKey) {
            if let v = aDecoder.decodeObject(forKey: passCodeKey) as? String {
                self.passCode = v
            }
        }
        
        if aDecoder.containsValue(forKey: localUserOnlyKey) {
            self.localUserOnly = aDecoder.decodeBool(forKey: localUserOnlyKey)
        }
    }
    
    open func isUsingPasscode() -> Bool{
        return self.passCode.count > 0
    }
    
    open func isLoggedOn() -> Bool {
        return
            self.logonToken.count > 0 ||
                    self.localUserOnly
    }
    
    open func isRegisteredButNotActivated() -> Bool {
        return
            self.userName.count > 0 &&
                !self.activated
    }
    
    open func isRegisteredAndActivated() -> Bool {
        return
            self.userName.count > 0 &&
            !self.isRegisteredButNotActivated()
    }
    
    open func hasCreatedPasscode() -> Bool {
        return
            self.passCode.count > 0 ||
            self.usingTouchId
    }
    
    public class var supportsSecureCoding : Bool {
        return true
    }
}
