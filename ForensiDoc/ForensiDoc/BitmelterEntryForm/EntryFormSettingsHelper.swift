//
//  EntryFormSettingsHelper.swift
//  BitmelterEntryForm

import Foundation

open class EntryFormSettingsHelper {
    open class func IsGroupHidden(_ entryFormId: Int, groupName: String) -> Bool {
        let formKey = MakeGroupSettingsKey(entryFormId)
        let userDefaults = UserDefaults.standard
        if let existingSettings = userDefaults.object(forKey: formKey) as? [String: Bool] {
            if existingSettings.index(forKey: groupName) != nil {
                if let v = existingSettings[groupName] {
                    return v
                }
            }
        }
        return false
    }
    
    open class func SetGroupHidden(_ entryFormId: Int, groupName: String, value: Bool) {
        let formKey = MakeGroupSettingsKey(entryFormId)
        let userDefaults = UserDefaults.standard
        var newSettings: [String: Bool]? = .none
        if let existingSettings = userDefaults.object(forKey: formKey) as? [String: Bool] {
            newSettings = existingSettings
        } else {
            newSettings = [String: Bool]()
        }
        
        if var s = newSettings {
            s[groupName] = value
            userDefaults.set(s, forKey: formKey)
            userDefaults.synchronize()
        }
    }
    
    open class func SaveEntryFormSettings<T>(_ entryFormId: Int, key: String, value:[(T, String)]) {
        let formKey = MakeFormSettingsKey(entryFormId)
        let userDefaults = UserDefaults.standard
        var newSettings: [String: AnyObject]? = .none
        if let existingSettings = userDefaults.object(forKey: formKey) as? [String: AnyObject] {
            newSettings = existingSettings
        } else {
            newSettings = [String: AnyObject]()
        }
        
        if var s = newSettings {
            let reformated = ReformatData(value)
            s[key] = reformated as AnyObject
            userDefaults.set(s, forKey: formKey)
            userDefaults.synchronize()
        }
    }
    
    open class func GetEntryFormSettingValue<T>(_ entryFormId: Int, key: String, _: T.Type) -> T? {
        if let efs = GetEntryFormSetting(entryFormId, key: key, String.self) {
            var stringValue: String = ""
            for s in efs {
                if stringValue.count > 0 {
                    stringValue += "\n"
                }
                stringValue = stringValue + s.0
            }
            if let sRet = stringValue as? T {
                return sRet
            }
        } else if let efs = GetEntryFormSetting(entryFormId, key: key, Int.self) {
            for s in efs {
                if let sRet = s.0 as? T {
                    return sRet
                }
            }
        } else if let efs = GetEntryFormSetting(entryFormId, key: key, Double.self) {
            for s in efs {
                if let sRet = s.0 as? T {
                    return sRet
                }
            }
            
        } else if let efs = GetEntryFormSetting(entryFormId, key: key, Float.self) {
            for s in efs {
                if let sRet = s.0 as? T {
                    return sRet
                }
            }
        }
        
        return .none
    }
    
    open class func GetEntryFormSetting<T>(_ entryFormId: Int, key: String, _: T.Type) -> [(T, String)]? {
        let formKey = MakeFormSettingsKey(entryFormId)
        let userDefaults = UserDefaults.standard
        if let existingSettings = userDefaults.object(forKey: formKey) as? [String: AnyObject] {
            if existingSettings.index(forKey: key) != nil {
                if let rawValue = existingSettings[key] as? String {
                    if let dataFromString = rawValue.data(using: String.Encoding.utf8, allowLossyConversion: false) {
                        var ret = [(T, String)]()
                        let json = JSON(data: dataFromString)
                        for arrayValue in json.arrayValue {
                            let title = arrayValue["title"].stringValue
                            if T.self is Int.Type {
                                let value = arrayValue["value"].intValue
                                if let v = value as? T {
                                    ret.append((v, title))
                                }
                            } else if T.self is Double.Type {
                                let value = arrayValue["value"].doubleValue
                                if let v = value as? T {
                                    ret.append((v, title))
                                }
                            } else if T.self is Float.Type {
                                let value = arrayValue["value"].floatValue
                                if let v = value as? T {
                                    ret.append((v, title))
                                }
                            } else if T.self is String.Type {
                                let value = arrayValue["value"].stringValue
                                if let v = value as? T {
                                    ret.append((v, title))
                                }
                            } else if T.self is NSString.Type {
                                let value = arrayValue["value"].intValue
                                if let v = value as? T {
                                    ret.append((v, title))
                                }
                            }
                        }
                        
                        return ret
                    }
                }
            }
        }
        return .none
    }
    
    fileprivate class func MakeFormSettingsKey(_ entryFormId: Int) -> String {
        return "\(entryFormId)_formSettings"
    }
    
    fileprivate class func MakeGroupSettingsKey(_ entryFormId: Int) -> String {
        return "\(entryFormId)_groupSettings"
    }
    
    fileprivate class func ReformatData<T>(_ data:[(T, String)]) -> String {
        var forJson = [[String: AnyObject]]()
        for d in data {
            var dict = [String: AnyObject]()
            dict["title"] = d.1 as AnyObject
            if let v = d.0 as? Int {
                dict["value"] = v as AnyObject
            } else if let v = d.0 as? Float {
                dict["value"] = v as AnyObject
            } else if let v = d.0 as? Double {
                dict["value"] = v as AnyObject
            } else if let v = d.0 as? NSString {
                dict["value"] = v
            } else if let v = d.0 as? String {
                dict["value"] = v as AnyObject
            }
            forJson.append(dict)
        }
        
        let json = JSON(forJson)
        
        if let ret = json.rawString(String.Encoding.utf8, options:
            JSONSerialization.WritingOptions.prettyPrinted) {
                return ret
        }
        
        return ""
    }
}
