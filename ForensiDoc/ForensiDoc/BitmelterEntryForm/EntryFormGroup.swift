//
//  EntryFormGroup.swift
//  BitmelterEntryForm

import Foundation

open class EntryFormGroup: JSONConvertible, Validable {
    fileprivate var _id: String = ""
    fileprivate var _fields: [Any] = []
    fileprivate var _title: String = ""
    
    
    fileprivate init() {
    }

    public init(jsonSpec: JSON, eventManager: EventManager, entryForm: EntryForm, checkHiddenGroups: Bool) {
        _title = jsonSpec["group"].stringValue
        _id = jsonSpec["id"].stringValue
        for field in jsonSpec["fields"].arrayValue {
            if let formField = field.ExtractFormField(eventManager, entryForm: entryForm, checkHiddenGroups: checkHiddenGroups) {
                _fields.append(formField)
            }
        }
    }
    
    open var title: String {
        get {
            return _title
        }
    }
    
    open var fields: [Any] {
        get {
            return _fields
        }
    }
    
    open var Id: String {
        get {
            return _id
        }
    }
    
    open func isValidObject() -> Bool {
        for field in self.fields {
            if field is Validable {
                let j = field as! Validable
                if !j.isValidObject() {
                    return false
                }
            }
        }
        return true
    }
    
    open func allRequiredAreValid() -> Bool {
        for field in self.fields {
            if let f = field as? Requirable, f.required {
                if field is Validable {
                    let j = field as! Validable
                    if !j.isValidObject() {
                        return false
                    }
                }
            }

        }
        return true
    }
    
    open func hasRequiredFields() -> Bool {
        for field in self.fields {
            if let f = field as? Requirable, f.required {
                return true
            }
        }
        return false
    }
    
    open func toJSON() -> JSON {
        let json: JSON = JSON(toDictionary())
        return json
    }
    
    open func toReportJSON() -> JSON {
        return toJSON()
    }
    
    open func toDictionary() -> [String : AnyObject] {
        var ret = [String: AnyObject]()
        ret["group"] = self.title as AnyObject
        ret["id"] = self.Id as AnyObject
        
        ret["fields"] = getAllFields() as AnyObject
        
        return ret
    }
    
    open func toReportDictionary() -> [String : AnyObject] {
        var ret = [String: AnyObject]()
        for field in self.fields {
            if field is JSONConvertible {
                let j = field as! JSONConvertible
                for kv in j.toReportDictionary() {
                    ret[kv.0] = kv.1
                }
            }
        }
        return ret
    }
    
    func getAllFields() -> [AnyObject] {
        var fields = [AnyObject]()
        for field in self.fields {
            if field is JSONConvertible {
                let j = field as! JSONConvertible
                fields.append(j.toDictionary() as AnyObject)
            }
        }
        return fields
    }

}
