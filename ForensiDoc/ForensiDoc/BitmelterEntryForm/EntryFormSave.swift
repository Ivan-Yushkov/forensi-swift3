//
//  EntryFormSave.swift
//  BitmelterEntryForm

import Foundation

open class EntryFormSave: NSObject, NSSecureCoding {
    fileprivate let jsonDataKey = "jsonDataKey"
    
    fileprivate var _ef: EntryForm?
    fileprivate var _saveTitle: String = ""
    
    public init(entryForm: EntryForm) {
        _ef = entryForm
    }
    
    open var ef: EntryForm? {
        get {
            return self._ef
        }
    }
    
    open func encode(with aCoder: NSCoder) {
        if let ef = _ef {
            let rawJson = ef.toJSON().rawString(.utf8, options: .prettyPrinted)
           // let rawJson = ef.toJSON().rawString(.utf8)
            aCoder.encode(rawJson, forKey: jsonDataKey)
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        if aDecoder.containsValue(forKey: jsonDataKey) {
            if let v = aDecoder.decodeObject(forKey: jsonDataKey) as? String {
                self._ef = EntryForm(jsonSpec: v, doNotCheckForHiddenFields: false)
            }
        }
    }
    
    public static var supportsSecureCoding : Bool {
        return true
    }
}
