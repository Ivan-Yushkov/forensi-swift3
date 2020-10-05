//
//  MiscHelpers.swift
//  BitmelterEntryForm
//
//  Created by Andrzej Czarkowski on 07/06/2015.
//  Copyright (c) 2015 Bitmelter Ltd. All rights reserved.
//

import Foundation

open class MiscHelpers {
    open class func DebugLogNSURL() -> URL? {
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if documents.count > 0 {
            let document = documents[0]
            let u = URL(fileURLWithPath: document).appendingPathComponent("debug.log")
                return u
        }
        return .none
    }
    
    open class func ContentOfFileWithName(_ fileName: String, type:String) -> String? {
        guard let path = Bundle.main.path(forResource: fileName, ofType: type) else {
            return nil
        }
        
        do {
            let content = try String(contentsOfFile:path, encoding: String.Encoding.utf8)
            return content
        } catch _ as NSError {
            return nil
        }
    }
    
    open class func GetAllEntryFormsForDebug() -> [(postData:String, jsonSave:String)] {
        var ret = [(postData:String, jsonSave:String)]()
        let entryFormRepository = ForensiDocEntryFormRepository()
        let allEntryFormSpecs = entryFormRepository.LoadJSONFormSpecs()
        for spec in allEntryFormSpecs {
            let ef = EntryForm(jsonSpec: spec, doNotCheckForHiddenFields: true)
            let savedForms = entryFormRepository.LoadSavedFormForFormId(ef.FormId)
            for savedForm in savedForms {
                let postDataEncrypted = EncryptJsonForSubmit.Encrypt(savedForm)
                let jsonSave = savedForm.toJSON()
                if let jsonSaveString = jsonSave.rawString(String.Encoding.utf8, options:
                    JSONSerialization.WritingOptions.prettyPrinted) {
                    ret.append((postData: postDataEncrypted, jsonSave: jsonSaveString))
                }
            }
        }
        return ret
    }
    
    open class func GetFieldsForJSON(_ fields: [Any], useReportDictionary: Bool) -> [AnyObject] {
        var ret = [AnyObject]()
        
        for field in fields {
            if field is JSONConvertible {
                let j = field as! JSONConvertible
                if useReportDictionary {
                    ret.append(j.toReportDictionary() as AnyObject)
                } else {
                    ret.append(j.toDictionary() as AnyObject)
                }
            } else if let f = field as? [String: AnyObject] {
                ret.append(f as AnyObject)
            }
        }
        
        return ret
    }
    
    //TODO:Does not extract fields properly from function() { var dd = {field_id}
    open class func ExtractFieldsFromFormula(_ formula: String) -> [String] {
        var ret: [String] = [String]()
        
        let allowerCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_0123456789";
        var isOpened = false;
        
        var field = ""
        
        for c in formula {
            
            if c == "{"{
                
                if(isOpened && field.count > 0) {
                    field = ""
                }
                isOpened = true;
            }
            
            if c == "}" && isOpened {
                isOpened = false;
                if field.count > 0 {
                    ret.append(field)
                    field = ""
                }
            }
            
            if isOpened && c != "{" && allowerCharacters.range(of: String(c)) == nil {
                isOpened = false
                field = ""
            }
            
            
            
            if isOpened && allowerCharacters.range(of: String(c)) != nil {
                field = field + String(c);
            }
        }
        
        return ret;
    }
    
    
    
    open class func CalculateExpression(_ allFields: inout [String:Any?], fieldId: String, value: Any?, formula: String) -> Bool {
        
        let f = FormatFormula(&allFields, fieldId: fieldId, value: value, formula: formula)
        
        let allFieldsCnt = allFields.count
        let calculate = f.cnt == allFieldsCnt
        
        if calculate {
            let predicate = NSPredicate(format: f.calculateFormula)
            let result = predicate.evaluate(with: "") as Bool
            return result
        }
        return false
    }
    
    open class func AddValuesToFormField<T>(_ json: JSON, entryForm:EntryForm, formField: Any, id: String, title: String, required: Bool, allowedAttachmentsSpec: JSON?, attachments: [JSON]?, values: [JSON]?, eventManager: EventManager?, _: T.Type) -> EntryFormBaseFieldType<T>? {
        if let f = formField as? EntryFormBaseFieldType<T> {
            f.eventManager = eventManager
            f.id = id
            f.title = title
            f.required = required
            f.placeHolder = json["placeholder"].stringValue
            f.allowedCharacters = json["allowed_characters"].stringValue
            f.allowedCharactersErrorMessage = json["allowed_characters_error_message"].stringValue
            f.displayLabel = json["display_label"].stringValue
            f.resultDisplay = json["result_display"].stringValue
            f.forMultifield = json["for_multifield"].boolValue
            f.resultFormat = json["result_format"].stringValue
            f.resultDisplayShouldBeJSEvaluated = json["result_display_should_be_js_evaluated"].boolValue
            let commentSpec = json["comment"]
            if commentSpec.type != Type.null {
                f.fieldComments = EntryFormFieldComments(spec: json["comment"])
            }
            let dd = EntryForm.LoadEntryFormAttachmentSpec(allowedAttachmentsSpec, eventManager: eventManager)
            f.attachmentsSpec = dd
            
            //MARK: fix2020
            
            if let v = values {
                for value in v {
                    if let valueTitle = value["title"].string {
                        if let valueValue = value["value"].int, T.self is Int.Type {
                           _ = f.addValue(valueValue, title: valueTitle)
                        }
                        if let valueValue = value["value"].float, T.self is Float.Type {
                            _ = f.addValue(valueValue, title: valueTitle)
                        }
                        if let valueValue = value["value"].string, T.self is String.Type {
                            _ = f.addValue(valueValue, title: valueTitle)
                        }
                        if let valueValue = value["value"].double, T.self is Double.Type {
                            _ = f.addValue(valueValue, title: valueTitle)
                        }
                        
                    }
                    
                    
//                    if let valueTitle = value["title"].string, let valueValue = value["value"].int, T.self is Int.Type {
//                        f.addValue(valueValue, title: valueTitle)
//                    } else if let valueTitle = value["title"].string, let valueValue = value["value"].float, T.self is Float.Type {
//                        f.addValue(valueValue, title: valueTitle)
//                    } else if let valueTitle = value["title"].string, let valueValue = value["value"].string, T.self is String.Type {
//                        f.addValue(valueValue, title: valueTitle)
//                    } else if let valueTitle = value["title"].string, let valueValue = value["value"].double, T.self is Double.Type {
//                        f.addValue(valueValue, title: valueTitle)
//                    }
                }
            }
            if let atts = attachments {
                for attachment in atts {
                    if let entryFormAttachment = EntryForm.LoadEntryFormAttachment(attachment, entryForm: entryForm) {
                        f.addAttachment(entryFormAttachment)
                    }
                }
            }
            f.populateRemainingValues(json)
            return f
        }
        return .none
    }
    
    open class func CreateFormFieldType<T>(_ fieldType: EntryFormFieldType, baseType: T.Type, forMultifield: Bool) -> EntryFormBaseFieldType<T>? {
        var ret: EntryFormBaseFieldType<T>? = .none
        switch fieldType {
        case EntryFormFieldType.Checkbox:
            ret = CheckboxEntryField<T>()
        case EntryFormFieldType.CheckboxWithOther:
            ret = CheckboxWithOtherEntryField<T>()
        case EntryFormFieldType.Multiline:
            ret = MultilineEntryField<T>()
        case EntryFormFieldType.Radio:
            ret = RadioEntryField<T>()
        case EntryFormFieldType.RadioWithOther:
            ret = RadioWithOtherEntryField<T>()
        case EntryFormFieldType.Textbox:
            ret = TextboxEntryField<T>()
        case EntryFormFieldType.Time:
            ret = TimeEntryField<T>()
        case EntryFormFieldType.Date:
            ret = DateEntryField<T>()
        case EntryFormFieldType.DateAndTime:
            ret = DateAndTimeEntryField<T>()
        case EntryFormFieldType.Calculated:
            ret = CalculatedEntryField<T>()
        case EntryFormFieldType.Location:
            ret = LocationEntryField<T>()
        }
        ret?.id = UUID().uuidString
        ret?.forMultifield = forMultifield
        
        if baseType is Int.Type {
            ret?.baseType = EntryFormFieldBaseType(rawValue: EntryFormFieldBaseType.Int.rawValue)
        } else if baseType is Float.Type {
            ret?.baseType = EntryFormFieldBaseType(rawValue: EntryFormFieldBaseType.Float.rawValue)
        } else if baseType is Double.Type {
            ret?.baseType = EntryFormFieldBaseType(rawValue: EntryFormFieldBaseType.Double.rawValue)
        } else if baseType is String.Type {
            ret?.baseType = EntryFormFieldBaseType(rawValue: EntryFormFieldBaseType.String.rawValue)
        }
        
        return ret
    }
    
    
    open class func CalculateFormula(_ allFields: inout [String:Any?], fieldId: String, value: Any?, formula: String) -> NSNumber? {
        
        let f = FormatFormula(&allFields, fieldId: fieldId, value: value, formula: formula)
        
        let allFieldsCnt = allFields.count
        let calculate = f.cnt == allFieldsCnt
        
        var retValue: NSNumber? = .none
//TODO: find solution
        hack_try {
            if calculate {
                let expression = NSExpression(format: f.calculateFormula)
                if let result = expression.expressionValue(with: nil, context: nil) as? NSNumber {
                    if (NSDecimalNumber.notANumber.isEqual(result)) {
                        retValue = .none
                    } else if (result.isEqual(Double.infinity)) {
                        retValue = .none
                    }
                    retValue = result
                }
            }
            }.hack_catch { e in
                retValue = .none
        }
        
        return retValue
    }
    
    open class func FormatFormula(_ allFields: inout [String:Any?], fieldId: String, value: Any?, formula: String) -> (calculateFormula: String ,cnt: Int) {
        if let v = value as? Int {
            allFields[fieldId] = v
        } else if let v = value as? Float {
            allFields[fieldId] = v
        } else if let v = value as? Double {
            allFields[fieldId] = v
        } else if let v = value as? String {
            allFields[fieldId] = v
        } else if let v = value as? NSString {
            allFields[fieldId] = v
        } else if value == nil {
            allFields[fieldId] = nil
        }
        
        var calculateFormula = formula
        var cnt = 0
        for kv in allFields {
            if let v = kv.1 {
                let formulaPattern = "{" + kv.0 + "}"
                if let value = v as? Int {
                    calculateFormula = calculateFormula.replacingOccurrences(of: formulaPattern, with: String(value))
                    cnt += 1
                } else if let value = v as? Float {
                    calculateFormula = calculateFormula.replacingOccurrences(of: formulaPattern, with: String(value))
                    cnt += 1
                } else if let value = v as? Double {
                    calculateFormula = calculateFormula.replacingOccurrences(of: formulaPattern, with: String(value))
                    cnt += 1
                } else if let value = v as? String, value.count > 0 {
                    calculateFormula = calculateFormula.replacingOccurrences(of: formulaPattern, with: String(value))
                    cnt += 1
                } else if let value = v as? NSString, value.length > 0 {
                    calculateFormula = calculateFormula.replacingOccurrences(of: formulaPattern, with: String(value))
                    cnt += 1
                }
            }
        }
        return (calculateFormula, cnt)
    }
    
    open class func RandomStringWithLength (_ len : Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        let randomString : NSMutableString = NSMutableString(capacity: len)
        
        for _ in 0 ..< len {
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.character(at: Int(rand)))
        }
        
        return randomString as String
    }
    
    open class func IsKnownEntryFormField(_ object: Any) -> Bool {
        let ret =
            (object is EntryFormBaseFieldType<String>) ||
                (object is EntryFormBaseFieldType<Double>) ||
                (object is EntryFormBaseFieldType<Int>) ||
                (object is EntryFormBaseFieldType<Float>)
        return ret
    }
    
    open class func IsRadioOrCheckboxWithOther(_ object: Any) -> Bool {
        let ret =
            (object is RadioWithOtherEntryField<String>) ||
                (object is RadioWithOtherEntryField<Double>) ||
                (object is RadioWithOtherEntryField<Int>) ||
                (object is RadioWithOtherEntryField<Float>) ||
                (object is CheckboxWithOtherEntryField<String>) ||
                (object is CheckboxWithOtherEntryField<Double>) ||
                (object is CheckboxWithOtherEntryField<Int>) ||
                (object is CheckboxWithOtherEntryField<Float>)
        
        return ret
    }
    
    open class func HasAddedOtherValue(_ object: Any) -> Bool {
        if let o = object as? RadioWithOtherEntryField<String> {
            return o.addedOtherValue
        } else if let o = object as? RadioWithOtherEntryField<Double> {
            return o.addedOtherValue
        } else if let o = object as? RadioWithOtherEntryField<Int> {
            return o.addedOtherValue
        } else if let o = object as? RadioWithOtherEntryField<Float> {
            return o.addedOtherValue
        } else if let o = object as? CheckboxWithOtherEntryField<String> {
            return o.addedOtherValue
        } else if let o = object as? CheckboxWithOtherEntryField<Double> {
            return o.addedOtherValue
        } else if let o = object as? CheckboxWithOtherEntryField<Int> {
            return o.addedOtherValue
        } else if let o = object as? CheckboxWithOtherEntryField<Float> {
            return o.addedOtherValue
        }
        return false
    }
    
    open class func IsRadio(_ object: Any) -> Bool {
        let ret =
            (object is RadioWithOtherEntryField<String>) ||
                (object is RadioWithOtherEntryField<Double>) ||
                (object is RadioWithOtherEntryField<Int>) ||
                (object is RadioWithOtherEntryField<Float>) ||
                (object is RadioEntryField<String>) ||
                (object is RadioEntryField<Double>) ||
                (object is RadioEntryField<Int>) ||
                (object is RadioEntryField<Float>)
        
        return ret
    }
    
    open class func IsCheckbox(_ object: Any) -> Bool {
        let ret =
            (object is CheckboxWithOtherEntryField<String>) ||
                (object is CheckboxWithOtherEntryField<Double>) ||
                (object is CheckboxWithOtherEntryField<Int>) ||
                (object is CheckboxWithOtherEntryField<Float>) ||
                (object is CheckboxEntryField<String>) ||
                (object is CheckboxEntryField<Double>) ||
                (object is CheckboxEntryField<Int>) ||
                (object is CheckboxEntryField<Float>)
        
        return ret
    }
    
    open class func IsCalculatedField(_ object: Any) -> Bool {
        let ret =
            (object is CalculatedEntryField<Double>) ||
                (object is CalculatedEntryField<Int>) ||
                (object is CalculatedEntryField<Float>) ||
                (object is CalculatedEntryField<String>) ||
                (object is CalculatedEntryField<NSString>)
        return ret
    }
    
    open class func CastEntryFormField<T>(_ formField: Any, _: T.Type) -> EntryFormBaseFieldType<T>?{
        if formField is CheckboxEntryField<T> {
            return formField as! CheckboxEntryField<T>
        } else if formField is CheckboxWithOtherEntryField<T> {
            return formField as! CheckboxWithOtherEntryField<T>
        } else if formField is MultilineEntryField<T> {
            return formField as! MultilineEntryField<T>
        } else if formField is RadioEntryField<T> {
            return formField as! RadioEntryField<T>
        } else if formField is RadioWithOtherEntryField<T> {
            return formField as! RadioWithOtherEntryField<T>
        } else if formField is TextboxEntryField<T> {
            return formField as! TextboxEntryField<T>
        } else if formField is DateEntryField<T> {
            return formField as! DateEntryField<T>
        } else if formField is TimeEntryField<T> {
            return formField as! TimeEntryField<T>
        } else if formField is DateAndTimeEntryField<T> {
            return formField as! DateAndTimeEntryField<T>
        } else if formField is CalculatedEntryField<T> {
            return formField as! CalculatedEntryField<T>
        } else if formField is LocationEntryField<T> {
            return formField as! LocationEntryField<T>
        }
        return .none
    }
}
