//
//  DataManager.swift
//  ForensiDoc
//
//  Created by Andrzej Czarkowski on 23/11/2014.
//  Copyright (c) 2014 Bitmelter Ltd. All rights reserved.
//

import Foundation

public class DataManager {
    private let userDetailsKey = "user"
    private let helperDataKey = "helperData"
    
    class public var sharedInstance: DataManager {
        struct Singleton {
            static let instance = DataManager()
        }
        return Singleton.instance
    }
    
    public func user() -> User {
        return getData(userDetailsKey, defValue: User())
    }
    
    func saveUser(user: User) {
        saveData(user, key: userDetailsKey)
    }
    
    public func handleOpenUrl(url: NSURL) -> Bool{
        if processOpenUrl(url, containing: "://activate/", assignTo: { (activationCode) -> Void in
            let user = DataManager.sharedInstance.user()
            if !user.activated {
                DataManager.sharedInstance.helperData().accountActivationCode = activationCode
            }
        }){ }
        else if processOpenUrl(url, containing: "://resetpassword/", assignTo: { (resetPasswordCode) -> Void in
            DataManager.sharedInstance.helperData().resetPasswordCode = resetPasswordCode
        }){ }
        return false
    }
    
    public func helperData() -> HelperData {
        return getData(helperDataKey, defValue: HelperData())
    }
    
    func saveHelperData(helperData: HelperData) {
        saveData(helperData, key: helperDataKey)
    }
    
    private func getData<T: AnyObject>(key: String, defValue: T) -> T {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let data = userDefaults.objectForKey(key) as? NSData
        if let d = data {
            let dataValue = NSKeyedUnarchiver.unarchiveObjectWithData(d) as? T
            if let v = dataValue {
                return v
            }
        }
        return defValue
    }
    
    private func saveData<T: AnyObject>(data: T, key: String) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let data = NSKeyedArchiver.archivedDataWithRootObject(data)
        userDefaults.setObject(data, forKey: key)
        userDefaults.synchronize()
    }
}