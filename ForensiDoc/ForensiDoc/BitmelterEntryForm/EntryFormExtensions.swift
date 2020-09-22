//
//  EntryFormExtensions.swift
//  BitmelterEntryForm

import Foundation

extension JSON {
    public func ExtractFormField(_ eventManager: EventManager, entryForm: EntryForm, checkHiddenGroups: Bool) -> Any? {
        let groupField = self["group"].stringValue
        let fieldType = self["type"].stringValue
        if !fieldType.isEmpty && fieldType.caseInsensitiveCompare("MultipleEntry") == .orderedSame {
            let multipleEntryField = EntryFormMultipleEntry(jsonSpec: self, eventManager: eventManager, entryForm: entryForm, checkHiddenGroups: checkHiddenGroups)
            return multipleEntryField
        } else if !groupField.isEmpty {
            let entryFormGroup = EntryFormGroup(jsonSpec: self, eventManager: eventManager, entryForm: entryForm, checkHiddenGroups: checkHiddenGroups)
            if checkHiddenGroups {
                if !EntryFormSettingsHelper.IsGroupHidden(entryForm.FormId, groupName: entryFormGroup.Id) {
                    return entryFormGroup
                } else {
                    return .none
                }
            }
            return entryFormGroup
        } else {
            var f: Any?
            let fieldId = self["id"].stringValue
            let fieldTitle = self["title"].stringValue
            let fieldBaseType = self["basetype"].stringValue
            let fieldRequired = self["required"].boolValue
            let fieldAllowedAttachmentsSpec = self["allowed_attachments"]
            let fieldAttachments = self["attachments"].array
            if let fType = EntryFormFieldType(rawValue: fieldType), let fBaseType = EntryFormFieldBaseType(rawValue: fieldBaseType) {
                switch fBaseType {
                case EntryFormFieldBaseType.Float:
                    f = MiscHelpers.CreateFormFieldType(fType, baseType: Float.self, forMultifield: false)
                case EntryFormFieldBaseType.Int:
                    f = MiscHelpers.CreateFormFieldType(fType, baseType: Int.self, forMultifield: false)
                case EntryFormFieldBaseType.String:
                    f = MiscHelpers.CreateFormFieldType(fType, baseType: String.self, forMultifield: false)
                case EntryFormFieldBaseType.Double:
                    f = MiscHelpers.CreateFormFieldType(fType, baseType: Double.self, forMultifield: false)
                }
            }
            
            if let formField: Any = f {
                if let fWithValues = MiscHelpers.AddValuesToFormField(self, entryForm: entryForm, formField: formField, id: fieldId, title: fieldTitle, required: fieldRequired, allowedAttachmentsSpec: fieldAllowedAttachmentsSpec, attachments: fieldAttachments, values: self["values"].array, eventManager: eventManager, Float.self)
                {
                    return fWithValues
                } else if let fWithValues = MiscHelpers.AddValuesToFormField(self, entryForm: entryForm, formField: formField, id: fieldId, title: fieldTitle, required: fieldRequired, allowedAttachmentsSpec: fieldAllowedAttachmentsSpec, attachments: fieldAttachments, values: self["values"].array, eventManager: eventManager, Int.self)
                {
                    return fWithValues
                } else if let fWithValues = MiscHelpers.AddValuesToFormField(self, entryForm: entryForm, formField: formField, id: fieldId, title: fieldTitle, required: fieldRequired, allowedAttachmentsSpec: fieldAllowedAttachmentsSpec, attachments: fieldAttachments, values: self["values"].array, eventManager: eventManager, String.self)
                {
                    return fWithValues
                } else if let fWithValues = MiscHelpers.AddValuesToFormField(self, entryForm: entryForm, formField: formField, id: fieldId, title: fieldTitle, required: fieldRequired, allowedAttachmentsSpec: fieldAllowedAttachmentsSpec, attachments: fieldAttachments, values: self["values"].array, eventManager: eventManager, Double.self)
                {
                    return fWithValues
                } else {
                    return formField
                }
            }
            
            //Check if fieldType is Drawing
            if fieldType == "Drawing" {
                let drawing = EntryFormDrawable(jsonSpec: self, eventManager: eventManager)
                return drawing
            }
        }
        
        return .none
    }
}
