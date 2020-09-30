//
//  EntryFormMultipleEntry.swift
//  BitmelterEntryForm

import Foundation

open class EntryFormMultipleEntry: JSONConvertible, Validable {
    open var attachmentsSpec: EntryFormAttachmentSpec?
    open var fields: [Any] = []
    open var title: String = ""
    fileprivate var _id: String = ""
    open var required: Bool = false
    open var baseType: EntryFormFieldBaseType?
    open var fieldType: EntryFormFieldType?
    
    
    fileprivate init() {
    }
    
    public init(jsonSpec: JSON, eventManager: EventManager, entryForm: EntryForm, checkHiddenGroups: Bool) {
        title = jsonSpec["title"].stringValue
        _id = jsonSpec["id"].stringValue
        
        let eType = jsonSpec["entry_type"].stringValue
        if let fType = EntryFormFieldType(rawValue: eType) {
            self.fieldType = fType
        }
        
        let fieldBaseType = jsonSpec["basetype"].stringValue
        if let fBaseType = EntryFormFieldBaseType(rawValue: fieldBaseType) {
            self.baseType = fBaseType
        }
        required = jsonSpec["required"].boolValue
        for field in jsonSpec["fields"].arrayValue {
            if let formField = field.ExtractFormField(eventManager, entryForm: entryForm, checkHiddenGroups: checkHiddenGroups) {
                fields.append(formField)
            }
        }
        
        let fieldAllowedAttachmentsSpec = jsonSpec["allowed_attachments"]
        self.attachmentsSpec = EntryForm.LoadEntryFormAttachmentSpec(fieldAllowedAttachmentsSpec, eventManager: eventManager)
    }
    
    open func deleteEntryForm<T>(_ entryFormBaseFieldType: EntryFormBaseFieldType<T>) -> Bool{
        var idx = -1
        for fld in fields {
            idx = idx + 1
            if let f = MiscHelpers.CastEntryFormField(fld, T.self) {
                if f.id == entryFormBaseFieldType.id {
                    break
                }
            }
        }
        
        if idx >= -1 {
            for att in entryFormBaseFieldType.attachments {
                entryFormBaseFieldType.deleteAttachment(att)
            }
            fields.remove(at: idx)
            return true
        }
        
        return false
    }
    
    open func toReportJSON() -> JSON {
        let json: JSON = JSON(toReportDictionary())
        return json
    }
    
    open func toJSON() -> JSON {
        let json: JSON = JSON(toDictionary())
        return json
    }
    
    open func toDictionary() -> [String : AnyObject] {
        var ret = [String: AnyObject]()
        ret["title"] = self.title as AnyObject
        ret["type"] = "MultipleEntry" as AnyObject //This is special type
        ret["id"] = self._id as AnyObject
        if let fType = self.fieldType {
            ret["entry_type"] = fType.rawValue as AnyObject
        }
        if let baseType = self.baseType {
            ret["basetype"] = baseType.rawValue as AnyObject
        }
        
        if let attSpec = self.attachmentsSpec {
            ret["allowed_attachments"] = attSpec.toDictionary() as AnyObject
        } else {
            ret["allowed_attachments"] = EntryFormAttachmentSpec().toDictionary() as AnyObject
        }
        
        ret["required"] = self.required as AnyObject
        
        ret["fields"] = MiscHelpers.GetFieldsForJSON(self.fields, useReportDictionary: false) as AnyObject
        
        return ret
    }
    
    open func toReportDictionary() -> [String : AnyObject] {
        var ret = [String: AnyObject]()
        
        var valueDictionary = [String: AnyObject]()
        var values = [AnyObject]()
        
        var cnt = 1
        for field in MiscHelpers.GetFieldsForJSON(self.fields, useReportDictionary: true) {
            if let f = field as? [String:AnyObject] {
                if let _ = f.index(forKey: "value") {
                    if let arr = f["value"] as? [AnyObject] {
                        for el in arr {
                            if var elDict = el as? [String: AnyObject] {
                                elDict["value_number"] = cnt as AnyObject
                                values.append(elDict as AnyObject)
                            }
                        }
                    }
                }
            }
            cnt += 1
        }
        
        valueDictionary["value"] = values as AnyObject
        
        ret[self._id] = valueDictionary as AnyObject
        
        return ret
    }
    
    open func isValidObject() -> Bool {
        //TODO:Finish this bit
        return true
    }
    
    open func allRequiredAreValid() -> Bool {
        return true
    }

}
