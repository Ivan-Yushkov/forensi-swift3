//
//  DataManager.swift
//  ForensiDoc

import Foundation

open class DataManager {
    fileprivate let userDetailsKey = "user"
    fileprivate let helperDataKey = "helperData"
    
    class open var sharedInstance: DataManager {
        struct Singleton {
            static let instance = DataManager()
        }
        return Singleton.instance
    }
    
    open func user() -> User {
        return getData(userDetailsKey, defValue: User())
    }
    
    func saveUser(_ user: User) {
        saveData(user, key: userDetailsKey)
    }
    
    open func handleOpenUrl(_ url: URL) -> Bool{
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
    
    open func helperData() -> HelperData {
        return getData(helperDataKey, defValue: HelperData())
    }
    
    func saveHelperData(_ helperData: HelperData) {
        saveData(helperData, key: helperDataKey)
    }
    
    fileprivate func getData<T: AnyObject>(_ key: String, defValue: T) -> T {
        let userDefaults = UserDefaults.standard
        let data = userDefaults.object(forKey: key) as? Data
        if let d = data {
            let dataValue = NSKeyedUnarchiver.unarchiveObject(with: d) as? T
            if let v = dataValue {
                return v
            }
        }
        return defValue
    }
    
    fileprivate func saveData<T: AnyObject>(_ data: T, key: String) {
        let userDefaults = UserDefaults.standard
        let data = NSKeyedArchiver.archivedData(withRootObject: data)
        userDefaults.set(data, forKey: key)
        userDefaults.synchronize()
    }
}
