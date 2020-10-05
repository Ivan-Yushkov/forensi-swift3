//
//  EntryFormBaseField.swift
//  BitmelterEntryForm

import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


public enum EntryFormFieldType : String {
    case Radio = "Radio"
    case RadioWithOther = "RadioWithOther"
    case Checkbox = "Checkbox"
    case CheckboxWithOther = "CheckboxWithOther"
    case Textbox = "Textbox"
    case Multiline = "Multiline"
    case Date = "Date"
    case Time = "Time"
    case DateAndTime = "DateAndTime"
    case Calculated = "Calculated"
    case Location = "Location"
}

public enum EntryFormFieldBaseType : String {
    case Int = "Int"
    case Float = "Float"
    case Double = "Double"
    case String = "String"
}

public protocol EntryFormFieldContainer {
    associatedtype T: Equatable
    init()
    var id: String { get }
    var title: String { get }
    var placeHolder: String { get }
    var required: Bool { get }
    var forMultifield: Bool { get }
    var attachmentsSpec: EntryFormAttachmentSpec { get }
    var attachments: [EntryFormAttachment] { get }
    var fieldType: EntryFormFieldType? { get }
    var resultDisplay: String { get }
    var resultFormat: String { get }
    var allowedCharacters: String { get }
    var allowedCharactersErrorMessage: String { get }
    var resultDisplayShouldBeJSEvaluated: Bool { get }
    var displayLabel: String { get }
    var baseType: EntryFormFieldBaseType? { get }
    var selectedValues: Array<(T,String)>? { get }
    var isValid: Bool { get }
    var fieldComments: EntryFormFieldComments? { get set }
    var eventManager: EventManager? { get set }
    var values: [(T,String)] { get set }
    func addFieldComments(_ value: String)
    func nonFormattedSelectedValue() -> String
    
    func addValue<T>(_ value: T, title: String) -> Bool
    func addAttachment(_ attachment: EntryFormAttachment)
    func deleteAttachment(_ attachment: EntryFormAttachment)
    func clearAttachments()
    func clearValues()
    func selectValue(_ value: (T,String))
    func unselectValue(_ value: (T, String))
    func convertToValue(_ anyObject: Any, title: String) -> (T, String)?
    func populateRemainingValues(_ json: JSON)
    func formatValueDataForReportJSON(_ dictionary: inout [String : AnyObject], valueKeyField: String)
}

public extension EntryFormFieldContainer {
    public func formatWithResultDisplay(_ value: String) -> String {
        var newValue = value
        if self.resultFormat.count > 0 {
            //This means the field is numeric
            if self.baseType == .Int {
                if let v = value.toInt() {
                    newValue = String(v.format(self.resultFormat))
                }
            } else if self.baseType == .Float {
                if let v = value.toFloat() {
                    newValue = String(v.format(self.resultFormat))
                }
                
            } else if self.baseType == .Double {
                if let v = value.toDouble() {
                    newValue = String(v.format(self.resultFormat))
                }
            }
        }
        if self.resultDisplay.count > 0 {
                return self.resultDisplay.replacingOccurrences(of: "{result}", with: newValue)
        }
        return value
    }
}

public protocol Validable {
    func isValidObject() -> Bool
}

public protocol Requirable {
    var required: Bool { get }
}

public protocol EntryFormFieldDoneEditing {
    func handleEditedForm<T: EntryFormFieldContainer>(_ entryForm: EntryForm, entryFormField: T)
    func shouldAskForTitle() -> Bool
    func allowEmptyData()-> Bool
}

open class EntryFormFieldDoneEditingWrapper: NSObject {
    open var EntryFormFieldDoneEditingDelegate: EntryFormFieldDoneEditing?
    
    public init(entryFormFieldDoneEditingDelegate: EntryFormFieldDoneEditing?) {
        self.EntryFormFieldDoneEditingDelegate = entryFormFieldDoneEditingDelegate
    }
}

open class EntryFormFieldWrapper: NSObject {
    fileprivate var _entryFormField: Any?
    public init(entryFormField: Any?) {
        self._entryFormField = entryFormField
    }
    
    open var EntryFormField: Any? {
        get{
            return _entryFormField
        }
    }
}

open class EntryFormBaseFieldType<TBaseType: Equatable>: EntryFormFieldContainer, JSONConvertible, Validable, Requirable {
    open var id: String = ""
    open var title: String = ""
    open var placeHolder: String = ""
    open var required: Bool = false
    open var resultDisplay: String = ""
    open var forMultifield: Bool = false
    open var allowedCharacters: String = ""
    open var allowedCharactersErrorMessage: String = ""
    open var resultDisplayShouldBeJSEvaluated: Bool = false
    open var resultFormat: String = ""
    open var displayLabel: String = ""
    open var attachmentsSpec = EntryFormAttachmentSpec()
    open var attachments: [EntryFormAttachment]
    open var fieldType: EntryFormFieldType?
    open var baseType: EntryFormFieldBaseType?
    open var selectedValues: Array<(TBaseType, String)>?
    open var isValid: Bool {
        get {
            if required {
                return selectedValues?.count > 0
            }
            return true
        }
    }
    
    fileprivate var _fieldComments: EntryFormFieldComments?
    open var fieldComments: EntryFormFieldComments? {
        get {
            return self._fieldComments
        }
        set(value){
            self._fieldComments = value
        }
    }
    
    //TODO:We need to check all possible combinations
    open func isValidObject() -> Bool {
        return self.isValid
    }
    
    public required init(){
        _values = Array<(TBaseType,String)>()
        selectedValues = Array<(TBaseType,String)>()
        attachments = [EntryFormAttachment]()
    }
    
    fileprivate var _values: Array<(TBaseType,String)>
    open var values: Array<(TBaseType,String)> {
        get {
            return _values
        }
        set{
            _values = newValue
        }
    }
    fileprivate var _eventManager: EventManager?
    open var eventManager: EventManager? {
        get {
            return _eventManager
        }
        set {
            _eventManager = newValue
        }
    }
    
    open func addAttachment(_ attachment: EntryFormAttachment) {
        self.attachments.append(attachment)
    }
    
    open func deleteAttachment(_ attachment: EntryFormAttachment) {
        if let idx = self.attachments.index(where: {$0.SavedAsFileName == attachment.SavedAsFileName}) {
            attachment.clear()
            self.attachments.remove(at: idx)
        }
    }
    
    open func clearAttachments() {
        for attachment in self.attachments {
            attachment.clear()
        }
        self.attachments.removeAll()
    }
    
    open func clearValues() {
        self.values.removeAll(keepingCapacity: true)
        self.selectedValues?.removeAll(keepingCapacity: true)
        self.eventManager?.trigger(self.id, information: .none)
    }
    
    open func isKnownValue(_ value: (TBaseType,String)) -> Bool {
        for i in 0..<self.values.count {
            let v = self.values[i]
            if v.0 == value.0 {
                return true
            }
        }
        return false
    }
    
    open func indexOfValue(_ value: (TBaseType,String)) -> Int {
        for (index, v) in self.values.enumerated() {
            if v.0 == value.0 {
                return index
            }
        }
        return -1
    }
    
    open func displaySelectedValue() -> String {
        return self.formatWithResultDisplay(self.nonFormattedSelectedValue())
    }
    
    open func nonFormattedSelectedValue() -> String {
        return ""
    }
    
    open func formatValueDataForReportJSON(_ dictionary: inout [String : AnyObject], valueKeyField: String) {
        
    }
    
    open func selectValue(_ value: (TBaseType,String)) {
        
    }
    
    open func type() -> String {
        return "Unknown"
    }
    
    open func populateRemainingValues(_ json: JSON) {
        for field in json["selected_values"].arrayValue {
            let title = field["title"].stringValue
            let value = field["value"].stringValue
            if let v = convertToValue(value, title: title) {
                selectValue(v)
            }
        }
    }
    
    open func unselectValue(_ value: (TBaseType, String)) {
        var foundIdx: Int?
        if let sv = self.selectedValues {
            for i in 0..<sv.count {
                let e = sv[i]
                if e.0 == value.0 {
                    foundIdx = i
                    break
                }
            }
        }
        if let idx = foundIdx {
            self.selectedValues?.remove(at: idx)
        }
    }
    
    open func convertToValue(_ anyObject: Any, title: String) -> (TBaseType, String)? {
        if let s = anyObject as? Int {
            if TBaseType.self is Int.Type {
                if let v = s as? TBaseType {
                    return (v,title)
                }
            }
        } else if let s = anyObject as? Float {
            if TBaseType.self is Float.Type {
                if let v = s as? TBaseType {
                    return (v,title)
                }
            }
        } else if let s = anyObject as? Double {
            if TBaseType.self is Double.Type {
                if let v = s as? TBaseType {
                    return (v,title)
                }
            }
        } else if let s = anyObject as? String {
            if let v = Int(s) as? TBaseType {
                return (v,title)
            } else if let v = s.toDouble() as? TBaseType {
                return (v,title)
            } else if let v = s.toFloat() as? TBaseType {
                return (v,title)
            } else if let v = s as? TBaseType {
                return (v,title)
            }
        } else if let s = anyObject as? NSString {
            if let v = s.toInt() as? TBaseType {
                return (v,title)
            } else if let v = s.toDouble() as? TBaseType {
                return (v,title)
            } else if let v = s.toFloat() as? TBaseType {
                return (v,title)
            } else if let v = s as? TBaseType {
                return (v,title)
            }
        }
        
        return .none
    }
    
    open func isValueSelected(_ value: (TBaseType, String)) -> Bool {
        if let sv = self.selectedValues {
            for i in 0..<sv.count {
                let e = sv[i]
                if e.0 == value.0 {
                    return true
                }
            }
        }
        return false
    }
    
    open func addFieldComments(_ value: String) {
        self.fieldComments?.value = value
    }

   
    open func addValue<V>(_ value: V, title: String) -> Bool{
        if let v = convertToValue(value, title: title) {
            _values.append(v)
            return true
        }
        return false
    }
    
//    open func addValue<V>(_ value: V, title: String) -> Bool{
//        if let v = convertToValue(value, title: title) {
//            _values.append(v)
//            return true
//        }
//        return false
//    }
    
    open func toReportJSON() -> JSON {
        return toJSON()
    }
    
    open func toJSON() -> JSON {
        let json = JSON(toDictionary())
        
        return json
    }
    
    open func toReportDictionary() -> [String : AnyObject] {
        var ret = [String: AnyObject]()
        
        if self.forMultifield {
            //This means is part of multifield
            var values = [AnyObject]()
            
            if self.attachments.count > 0 {
                for att in self.attachments {
                    var attDict = att.toReportDictionary()
                    attDict["name"] = self.displaySelectedValue() as AnyObject
                    values.append(attDict as AnyObject)
                }
            } else {
                var attDict = [String: AnyObject]()
                attDict["name"] = self.displaySelectedValue() as AnyObject
                attDict["filename"] = "" as AnyObject
                attDict["value"] = "" as AnyObject
                var timeStampDict = [String: AnyObject]()
                timeStampDict["value"] = 0.0 as AnyObject
                timeStampDict["type"] = "datetime" as AnyObject
                
                self.formatValueDataForReportJSON(&attDict, valueKeyField: "name")
                values.append(attDict as AnyObject)
            }
            ret["value"] = values as AnyObject
        } else {
            var valueDictionary = [String: AnyObject]()
            if let fType = self.fieldType {
                switch fType {
                case
                .Calculated,
                .Checkbox,
                .CheckboxWithOther,
                .Location,
                .Multiline,
                .Radio,
                .RadioWithOther,
                .Textbox:
                    valueDictionary["type"] = "string" as AnyObject
                    
                case
                .Date:
                    valueDictionary["type"] = "date" as AnyObject
                case
                .DateAndTime:
                    valueDictionary["type"] = "datetime" as AnyObject
                case
                .Time:
                    valueDictionary["type"] = "time" as AnyObject
                }
            }
            valueDictionary["value"] = self.displaySelectedValue() as AnyObject
            valueDictionary["comment"] = self.fieldComments?.value as AnyObject
            
            self.formatValueDataForReportJSON(&valueDictionary, valueKeyField: "value")
            
            ret[self.id] = valueDictionary as AnyObject
            
            var attachments = [[String: AnyObject]]()
            for attachment in self.attachments {
                attachments.append(attachment.toReportDictionary())
            }
            
            ret["attachments"] = attachments as AnyObject
        }
        
        return ret
    }
    
    open func toDictionary() -> [String : AnyObject] {
        var ret = [String: AnyObject]()
        
        ret["id"] = self.id as AnyObject
        ret["title"] = self.title as AnyObject
        ret["placeholder"] = self.placeHolder as AnyObject
        ret["display_label"] = self.displayLabel as AnyObject
        ret["type"] = self.type() as AnyObject
        ret["required"] = self.required as AnyObject
        ret["result_format"] = self.resultFormat as AnyObject
        ret["allowimages"] = self.attachmentsSpec.toDictionary() as AnyObject
        ret["comment"] = self.fieldComments?.toDictionary() as AnyObject
        ret["display_value"] = self.displaySelectedValue() as AnyObject
        ret["allowed_characters"] = self.allowedCharacters as AnyObject
        ret["allowed_characters_error_message"] = self.allowedCharactersErrorMessage as AnyObject
        ret["for_multifield"] = self.forMultifield as AnyObject
        ret["result_display"] = self.resultDisplay as AnyObject
        ret["result_display_should_be_js_evaluated"] = self.resultDisplayShouldBeJSEvaluated as AnyObject
        ret["allowed_attachments"] = self.attachmentsSpec.toDictionary() as AnyObject
        var baseType = ""
        if TBaseType.self is Float.Type {
            baseType = "Float"
        } else if TBaseType.self is Int.Type {
            baseType = "Int"
        } else if (TBaseType.self is String.Type || TBaseType.self is NSString.Type) {
            baseType = "String"
        } else if TBaseType.self is Double.Type {
            baseType = "Double"
        }
        
        ret["basetype"] = baseType as AnyObject
        
        var attachments = [[String: AnyObject]]()
        for attachment in self.attachments {
            attachments.append(attachment.toDictionary())
        }
        
        ret["attachments"] = attachments as AnyObject
        
        var vls = Array<[String: AnyObject]>()
        for val in self.values {
            var d = [String: AnyObject]()
            d["title"] = val.1 as AnyObject
            if let v = val.0 as? Int {
                d["value"] = v as AnyObject
            } else if let v = val.0 as? Float {
                d["value"] = v as AnyObject
            } else if let v = val.0 as? String {
                d["value"] = v as AnyObject
            } else if let v = val.0 as? NSString {
                d["value"] = v
            } else if let v = val.0 as? Double {
                d["value"] = v as AnyObject
            }
            vls.append(d)
        }
        if vls.count > 0 {
            ret["values"] = vls as AnyObject
        }
        
        if let sv = self.selectedValues {
            var svls = Array<[String: AnyObject]>()
            for val in sv {
                var d = [String: AnyObject]()
                d["title"] = val.1 as AnyObject
                if let v = val.0 as? Int {
                    d["value"] = v as AnyObject
                } else if let v = val.0 as? Float {
                    d["value"] = v as AnyObject
                } else if let v = val.0 as? Double {
                    d["value"] = v as AnyObject
                } else if let v = val.0 as? String {
                    d["value"] = v as AnyObject
                } else if let v = val.0 as? NSString {
                    d["value"] = v
                }
                svls.append(d)
            }
            if svls.count > 0 {
                ret["selected_values"] = svls as AnyObject
            }
        }
        
        return ret
    }
}
