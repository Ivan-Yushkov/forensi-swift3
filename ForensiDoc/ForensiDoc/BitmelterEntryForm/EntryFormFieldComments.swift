//
//  EntryFormFieldComments.swift
//  ForensiDoc

import Foundation

open class EntryFormFieldComments: JSONConvertible {
    open var isRequired: Bool = false
    open var value: String = ""
    
    public init(spec: JSON) {
        self.isRequired = spec["required"].boolValue
        self.value = spec["value"].stringValue
    }
    
    
    open func toReportJSON() -> JSON {
        return JSON(toReportDictionary())
    }
    
    open func toJSON() -> JSON {
        return JSON(toDictionary())
    }
    
    open func toDictionary() -> [String : AnyObject] {
        var ret = [String: AnyObject]()
        ret["required"] = self.isRequired as AnyObject
        ret["value"] = self.value as AnyObject
        return ret
    }
    
    open func toReportDictionary() -> [String : AnyObject] {
        return toDictionary()
    }
}
