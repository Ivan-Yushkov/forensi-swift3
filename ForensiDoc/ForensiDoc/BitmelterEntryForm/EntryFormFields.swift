//
//  EntryFormFields.swift
//  BitmelterEntryForm

import Foundation
import JavaScriptCore
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


open class RadioEntryField<TBaseType: Equatable> : EntryFormBaseFieldType<TBaseType> {
    public required init() {
        super.init()
        self.fieldType = .Radio
    }
    
    open override func selectValue(_ value: (TBaseType,String)) {
        self.selectedValues?.removeAll(keepingCapacity: true)
        self.selectedValues?.append(value)
        self.eventManager?.trigger(self.id, information: value.0)
    }
    
    override open func type() -> String {
        return EntryFormFieldType.Radio.rawValue
    }
    
    open override func nonFormattedSelectedValue() -> String {
        var d: String = ""
        if let sv = self.selectedValues {
            let c = sv.count - 1
            for idx in 0..<sv.count {
                d += sv[idx].1
                if idx != c {
                    d += ", "
                }
            }
        }
        return d
    }
}

open class RadioWithOtherEntryField<TBaseType: Equatable> : RadioEntryField<TBaseType> {
    var _otherValue: (TBaseType, String)? = .none
    
    public required init() {
        super.init()
        self.fieldType = .RadioWithOther
    }
    
    override open func type() -> String {
        return EntryFormFieldType.RadioWithOther.rawValue
    }
    
    override open func populateRemainingValues(_ json: JSON) {
        let otherValueTitle = json["othervalue_title"].stringValue
        let otherValueValue = json["othervalue_value"].stringValue
        if let v = convertToValue(otherValueValue, title: otherValueTitle) {
            _otherValue = v
        }
        super.populateRemainingValues(json)
    }
    
    override open func selectValue(_ value: (TBaseType, String)) {
        super.selectValue(value)
        if !self.isKnownValue(value) {
            if let ov = _otherValue {
                let idx = self.indexOfValue(ov)
                if idx > -1 {
                    self.values.remove(at: idx)
                }
            }
            _otherValue = value
            self.values.append(value)
        }
    }
    
    open var addedOtherValue: Bool {
        get{
            if (_otherValue != nil) {
                return true
            }
            return false
        }
    }
    
    override open func toDictionary() -> [String : AnyObject] {
        var d = super.toDictionary()
        if let ov = _otherValue {
            d["othervalue_title"] = ov.1 as AnyObject
            if let v = ov.0 as? Int {
                d["othervalue_value"] = v as AnyObject
            } else if let v = ov.0 as? Float {
                d["othervalue_value"] = v as AnyObject
            } else if let v = ov.0 as? String {
                d["othervalue_value"] = v as AnyObject
            } else if let v = ov.0 as? NSString {
                d["othervalue_value"] = v
            }
        }
        
        return d
    }
}

open class CheckboxEntryField<TBaseType: Equatable> : EntryFormBaseFieldType<TBaseType> {
    public required init() {
        super.init()
        self.fieldType = .Checkbox
    }
    
    override open func type() -> String {
        return EntryFormFieldType.Checkbox.rawValue
    }
    
    open override func selectValue(_ value: (TBaseType, String)) {
        if self.isValueSelected(value) {
            self.unselectValue(value)
        }
        self.selectedValues?.append(value)
    }
    
    open override func nonFormattedSelectedValue() -> String {
        var d: String = ""
        
        if let sv = self.selectedValues {
            let c = sv.count - 1
            for idx in 0..<sv.count {
                d += sv[idx].1
                if idx != c {
                    d += ", "
                }
            }
        }
        return d
    }
}

open class CheckboxWithOtherEntryField<TBaseType: Equatable> : CheckboxEntryField<TBaseType> {
    var _otherValue: (TBaseType, String)? = .none
    
    public required init() {
        super.init()
        self.fieldType = .CheckboxWithOther
    }
    
    override open func type() -> String {
        return EntryFormFieldType.CheckboxWithOther.rawValue
    }
    
    override open func populateRemainingValues(_ json: JSON) {
        let otherValueTitle = json["othervalue_title"].stringValue
        let otherValueValue = json["othervalue_value"].stringValue
        if let v = convertToValue(otherValueValue, title: otherValueTitle) {
            _otherValue = v
        }
        super.populateRemainingValues(json)
    }
    
    override open func selectValue(_ value: (TBaseType, String)) {
        super.selectValue(value)
        if !self.isKnownValue(value) {
            if let ov = _otherValue {
                let idx = self.indexOfValue(ov)
                if idx > -1 {
                    self.values.remove(at: idx)
                }
            }
            _otherValue = value
            self.values.append(value)
        }
    }
    
    override open func toDictionary() -> [String : AnyObject] {
        var d = super.toDictionary()
        if let ov = _otherValue {
            d["othervalue_title"] = ov.1 as AnyObject
            if let v = ov.0 as? Int {
                d["othervalue_value"] = v as AnyObject
            } else if let v = ov.0 as? Float {
                d["othervalue_value"] = v as AnyObject
            } else if let v = ov.0 as? String {
                d["othervalue_value"] = v as AnyObject
            } else if let v = ov.0 as? NSString {
                d["othervalue_value"] = v
            }
        }
        
        return d
    }
    
    open var addedOtherValue: Bool {
        get{
            if let _ = _otherValue {
                return true
            }
            return false
        }
    }
}

open class TextboxEntryField<TBaseType: Equatable> : EntryFormBaseFieldType<TBaseType> {
    public required init() {
        super.init()
        self.fieldType = .Textbox
    }
    
    override open func type() -> String {
        return EntryFormFieldType.Textbox.rawValue
    }
    
    open override func addValue<V>(_ value: V, title: String) -> Bool {
        self.values.removeAll(keepingCapacity: true)
        return super.addValue(value, title: title)
    }
    
    open override func selectValue(_ value: (TBaseType, String)) {
        self.selectedValues?.removeAll(keepingCapacity: true)
        self.selectedValues?.append(value)
        self.eventManager?.trigger(self.id, information: value.0)
    }
    
    open override func nonFormattedSelectedValue() -> String {
        if let sv = self.selectedValues {
            if sv.count > 0 {
                return sv[0].1
            }
        }
        return ""
    }
    
    open override func displaySelectedValue() -> String {
        let v = self.nonFormattedSelectedValue()
        if v.characters.count > 0 {
            return self.formatWithResultDisplay(v)
        }
        return ""
    }
    
    open override var isValid: Bool {
        get {
            if self.required {
                if self.selectedValues?.count > 0 {
                    if TBaseType.self is Float.Type {
                        if let _ = self.selectedValues![0].0 as? Float {
                            return true
                        }
                    } else if TBaseType.self is Double.Type {
                        if let _ = self.selectedValues![0].0 as? Double {
                            return true
                        }
                    } else if TBaseType.self is Int.Type {
                        if let _ = self.selectedValues![0].0 as? Int {
                            return true
                        }
                    } else if TBaseType.self is String.Type {
                        if let v = self.selectedValues![0].0 as? String {
                            return v.characters.count > 0
                        }
                    }
                }
                return false
            }
            return true
        }
    }
}

open class MultilineEntryField<TBaseType: Equatable> : EntryFormBaseFieldType<TBaseType> {
    public required init() {
        super.init()
        self.fieldType = .Multiline
    }
    
    override open func type() -> String {
        return EntryFormFieldType.Multiline.rawValue
    }
    
    open override func nonFormattedSelectedValue() -> String {
        var a: String = ""
        for i in 0 ..< self.values.count {
            if a.characters.count > 0 {
                a = a + ", "
            }
            let v = self.values[i]
            a = a + v.1
        }
        return a
    }
    
    open override func displaySelectedValue() -> String {
        let v = self.nonFormattedSelectedValue()
        if v.characters.count > 0 {
            return self.formatWithResultDisplay(v)
        }
        return ""
    }
}

open class DateTimeBaseEntryField<TBaseType: Equatable>: EntryFormBaseFieldType<TBaseType> {
    public required init() {
        super.init()
    }
    
    open var dateStyle: DateFormatter.Style {
        get {
            return DateFormatter.Style.medium
        }
    }
    
    open var timeStyle: DateFormatter.Style {
        get {
            return DateFormatter.Style.medium
        }
    }
   //MARK: fix2020
    open override func addValue<V>(_ value: V, title: String) -> Bool {
        self.values.removeAll(keepingCapacity: true)
        let ret = super.addValue(value, title: title)
        self.selectedValues?.removeAll(keepingCapacity: true)
        if let c = self.convertToValue(value, title: self.displaySelectedValue()) {
            self.selectedValues?.append(c)
        }
        return ret
    }
    
    open func getSelectedDate() -> Date? {
        if TBaseType.self is Double.Type {
            if self.values.count > 0 {
                if let v = self.values[0].0 as? Double {
                    let date = Date(timeIntervalSince1970: v)
                    return date
                }
            }
        }
        return .none
    }
    
    override open func isValidObject() -> Bool {
        if self.required {
            if let _ = self.getSelectedDate() {
                return true
            }
            return false
        }
        return true
    }
    
    override open func formatValueDataForReportJSON(_ dictionary: inout [String : AnyObject], valueKeyField: String) {
        if let d = self.getSelectedDate() {
            dictionary[valueKeyField] = d.timeIntervalSince1970 as AnyObject
        }
    }
    
    open func getDatePickerMode() -> UIDatePickerMode? {
        if self.fieldType == .Date {
            return UIDatePickerMode.date
        } else if self.fieldType == .Time {
            return UIDatePickerMode.time
        } else if self.fieldType == .DateAndTime {
            return UIDatePickerMode.dateAndTime
        }
        return .none
    }
    
    open override func nonFormattedSelectedValue() -> String {
        if TBaseType.self is Double.Type {
            if self.values.count > 0 {
                let s = self.values[0]
                if let v = s.0 as? Double {
                    let date = Date(timeIntervalSince1970: v)
                    let formatter = DateFormatter()
                    formatter.dateStyle = self.dateStyle
                    formatter.timeStyle = self.timeStyle
                    formatter.locale = Locale.current
                    let dateString = formatter.string(from: date)
                    return dateString
                }
            }
        }
        return ""
    }
}

open class DateEntryField<TBaseType: Equatable>: DateTimeBaseEntryField<TBaseType> {
    public required init() {
        super.init()
        self.fieldType = .Date
    }
    
    override open var dateStyle: DateFormatter.Style {
        get {
            return DateFormatter.Style.medium
        }
    }
    
    override open var timeStyle: DateFormatter.Style {
        get {
            return DateFormatter.Style.none
        }
    }
    
    override open func type() -> String {
        return EntryFormFieldType.Date.rawValue
    }
}

open class TimeEntryField<TBaseType: Equatable>: DateTimeBaseEntryField<TBaseType> {
    public required init() {
        super.init()
        self.fieldType = .Time
    }
    
    override open var dateStyle: DateFormatter.Style {
        get {
            return DateFormatter.Style.none
        }
    }
    
    override open var timeStyle: DateFormatter.Style {
        get {
            return DateFormatter.Style.medium
        }
    }
    
    override open func type() -> String {
        return EntryFormFieldType.Time.rawValue
    }
}

open class DateAndTimeEntryField<TBaseType: Equatable>: DateTimeBaseEntryField<TBaseType> {
    public required init() {
        super.init()
        self.fieldType = .DateAndTime
    }
    
    override open var dateStyle: DateFormatter.Style {
        get {
            return DateFormatter.Style.medium
        }
    }
    
    override open var timeStyle: DateFormatter.Style {
        get {
            return DateFormatter.Style.medium
        }
    }
    
    override open func type() -> String {
        return EntryFormFieldType.DateAndTime.rawValue
    }
}

open class CalculatedEntryField<TBaseType: Equatable>: EntryFormBaseFieldType<TBaseType> {
    var formula: String = ""
    var allFields:[String:Any?] = [String:Any?]()
    var displayableResult: String = "n/a"
    var canCalculate: Bool = false
    var formulaIsFormatOnly: Bool = false
    
    public required init() {
        super.init()
        self.fieldType = .Calculated
    }
    
    open func CalculationBasedOnMultipleFields() -> Bool {
        return self.allFields.count > 1
    }
    
    open func ExtractRealFieldNames(_ entryForm: EntryForm) -> String {
        let numberOfFields = self.allFields.count
        var ret = ""
        for (idx, field) in self.allFields.enumerated() {
            if idx + 1 == numberOfFields {
                if ret.characters.count > 0 {
                    ret = ret + " and "
                }
            } else {
                if ret.characters.count > 0 {
                    ret = ret + ", "
                }
            }
            if let fld = entryForm.GetField(field.0) {
                if let f = MiscHelpers.CastEntryFormField(fld, Int.self) {
                    ret = ret + f.title
                } else if let f = MiscHelpers.CastEntryFormField(fld, Float.self) {
                    ret = ret + f.title
                } else if let f = MiscHelpers.CastEntryFormField(fld, Double.self) {
                    ret = ret + f.title
                } else if let f = MiscHelpers.CastEntryFormField(fld, String.self) {
                    ret = ret + f.title
                }
            }
            
        }
        
        return ret
    }
    
    open override func nonFormattedSelectedValue() -> String {
        return self.displayableResult
    }
    
    override open func type() -> String {
        return EntryFormFieldType.Calculated.rawValue
    }
 //MARK: fix2020
    override open func displaySelectedValue() -> String {
        let value = super.displaySelectedValue()
        if self.resultDisplayShouldBeJSEvaluated {
            if self.canCalculate {
                if let context = JSContext() {
                let script = value
              //  context?.evaluateScript(script)
                context.evaluateScript(script)
                let displayResult: JSValue = context.evaluateScript("formatDisplayResult()")
                if let s = displayResult.toString() {
                    if s == "undefined" {
                        return "n/a"
                    }
                    return s
                }
            }
            }
            return "n/a"
        }
        return value
    }
    
    override open func populateRemainingValues(_ json: JSON) {
        self.formula = json["formula"].stringValue
        self.formulaIsFormatOnly = json["formula_is_format_only"].boolValue
        self.displayableResult = json["displayable_result"].stringValue
        self.canCalculate = json["can_calculate"].boolValue
        var loopedOverFields = false
        for af in json["all_fields"].arrayValue {
            loopedOverFields = true
            let field = af["field"].stringValue
            let value = af["value"].object
            self.allFields[field] = value
        }
        
        let extractedFields = MiscHelpers.ExtractFieldsFromFormula(self.formula)
        for extractedField in extractedFields {
            if !loopedOverFields {
                self.allFields[extractedField] = ""
            }
            
            self.eventManager?.listenTo(extractedField, action: { (information: Any?) -> () in
                if self.formulaIsFormatOnly {
                    let f = MiscHelpers.FormatFormula(&self.allFields, fieldId: extractedField, value: information, formula: self.formula)
                    let allFieldsCnt = self.allFields.count
                    let calculate = f.cnt == allFieldsCnt
                    if calculate {
                        self.canCalculate = true
                        self.displayableResult = f.calculateFormula
                    } else {
                        self.canCalculate = false
                        self.displayableResult = NSLocalizedString("n/a", comment: "n/a field")
                    }
                } else {
                    if let result = MiscHelpers.CalculateFormula(&self.allFields, fieldId: extractedField, value: information, formula: self.formula) {
                        self.selectedValues?.removeAll(keepingCapacity: true)
                        self.displayableResult = result.stringValue
                        self.canCalculate = true
                        
                        if let _ = information as? Int {
                            if let c = self.convertToValue(result.intValue, title: result.stringValue) {
                                self.selectedValues?.append(c)
                            }
                        } else if let _ = information as? Float {
                            if let c = self.convertToValue(result.floatValue, title: result.stringValue) {
                                self.selectedValues?.append(c)
                            }
                        } else if let _ = information as? Double {
                            if let c = self.convertToValue(result.doubleValue, title: result.stringValue) {
                                self.selectedValues?.append(c)
                            }
                        }
                    } else {
                        self.canCalculate = false
                        self.displayableResult = NSLocalizedString("n/a", comment: "n/a field")
                    }
                }
            })
        }
        
        super.populateRemainingValues(json)
    }
    
    override open func toDictionary() -> [String : AnyObject] {
        var d = super.toDictionary()
        d["formula"] = self.formula as AnyObject
        d["formula_is_format_only"] = self.formulaIsFormatOnly as AnyObject
        d["displayable_result"] = self.displayableResult as AnyObject
        d["can_calculate"] = self.canCalculate as AnyObject
        
        var af = Array<[String: AnyObject]>()
        for f in self.allFields {
  //          let v = f.value
  //          let k = f.key
            
  //        if f.1 is AnyObject {
 //MARK: fix2020
            if let ao = f.1 as AnyObject? {
                var d = [String: AnyObject]()
                let field = f.0
                let value = ao
                d["field"] = field as AnyObject
                d["value"] = value
                af.append(d)
            }
        }
        
        d["all_fields"] = af as AnyObject
        return d
    }
    
}

open class LocationEntryField<TBaseType: Equatable>: EntryFormBaseFieldType<TBaseType> {
    public required init() {
        super.init()
        self.fieldType = .Location
    }
    
    override open func type() -> String {
        return EntryFormFieldType.Location.rawValue
    }
    
    open override func nonFormattedSelectedValue() -> String {
        var a: String = ""
        for i in 0 ..< self.values.count {
            if a.characters.count > 0 {
                a = a + ", "
            }
            let v = self.values[i]
            a = a + v.1
        }
        return a
    }
    
    open override func displaySelectedValue() -> String {
        let v = self.nonFormattedSelectedValue()
        if v.characters.count > 0 {
            return self.formatWithResultDisplay(v)
        }
        return ""
    }
}
