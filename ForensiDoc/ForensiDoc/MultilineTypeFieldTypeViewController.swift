//
//  MultilineTypeFieldTypeViewController.swift
//  ForensiDoc
//
//  Created by Andrzej Czarkowski on 16/06/2015.
//  Copyright (c) 2015 Bitmelter Ltd. All rights reserved.
//

import Foundation


class MultilineTypeFieldTypeViewController: BaseViewController, UITextViewDelegate {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var textView: UITextView!
    var _characterSet:CharacterSet?
    var _allowedCharactersErrorMessage = ""
    
    var _entryField: Any?
    func setEntryField<T: EntryFormFieldContainer>(_ entryField: T) {
        _entryField = entryField
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let doneButton: UIBarButtonItem? = ViewsHelpers.GetDoneButton(#selector(MultilineTypeFieldTypeViewController.endEditing(_:)), target: self)
        
        if let ef = _entryField {
            var addNextKey = true
            if let f = MiscHelpers.CastEntryFormField(ef, Int.self) {
                self.title = f.title
                if f.allowedCharacters.characters.count > 0 {
                    self._characterSet = CharacterSet(charactersIn: f.allowedCharacters)
                }
                self._allowedCharactersErrorMessage = f.allowedCharactersErrorMessage
                self.textView.keyboardType = UIKeyboardType.numberPad
                setTextValue(f)
                self.checkIfCanAttachPhotos(f.attachmentsSpec, addAttachmentAction: EntryFormAttachmentAddAction(action: self.addAttachment),entryFormField: f, doneButton: doneButton, attachmentsHeightConstraint: self.attachmentsSelectorViewHeightConstraint,numberOfAttachments: f.attachments.count)
            } else if let f = MiscHelpers.CastEntryFormField(ef, Float.self) {
                self.title = f.title
                if f.allowedCharacters.characters.count > 0 {
                    self._characterSet = CharacterSet(charactersIn: f.allowedCharacters)
                }
                self._allowedCharactersErrorMessage = f.allowedCharactersErrorMessage
                self.textView.keyboardType = UIKeyboardType.decimalPad
                setTextValue(f)
                self.checkIfCanAttachPhotos(f.attachmentsSpec, addAttachmentAction: EntryFormAttachmentAddAction(action: self.addAttachment),entryFormField: f, doneButton: doneButton, attachmentsHeightConstraint: self.attachmentsSelectorViewHeightConstraint,numberOfAttachments: f.attachments.count)
            } else if let f = MiscHelpers.CastEntryFormField(ef, Double.self) {
                self.title = f.title
                if f.allowedCharacters.characters.count > 0 {
                    self._characterSet = CharacterSet(charactersIn: f.allowedCharacters)
                }
                self._allowedCharactersErrorMessage = f.allowedCharactersErrorMessage
                self.textView.keyboardType = UIKeyboardType.decimalPad
                setTextValue(f)
                self.checkIfCanAttachPhotos(f.attachmentsSpec, addAttachmentAction: EntryFormAttachmentAddAction(action: self.addAttachment),entryFormField: f, doneButton: doneButton, attachmentsHeightConstraint: self.attachmentsSelectorViewHeightConstraint,numberOfAttachments: f.attachments.count)
            } else if let f = MiscHelpers.CastEntryFormField(ef, String.self) {
                self.title = f.title
                if f.allowedCharacters.characters.count > 0 {
                    self._characterSet = CharacterSet(charactersIn: f.allowedCharacters)
                }
                self._allowedCharactersErrorMessage = f.allowedCharactersErrorMessage
                self.textView.keyboardType = UIKeyboardType.default
                setTextValue(f)
                self.checkIfCanAttachPhotos(f.attachmentsSpec, addAttachmentAction: EntryFormAttachmentAddAction(action: self.addAttachment),entryFormField: f, doneButton: doneButton, attachmentsHeightConstraint: self.attachmentsSelectorViewHeightConstraint,numberOfAttachments: f.attachments.count)
                addNextKey = false
            }
            
            
            addDoneButton(addNextKey)
            
            self.automaticallyAdjustsScrollViewInsets = false
            ViewsHelpers.FormatTextView(self.textView, makeFirstResponder: true)
        }
    }
    
    func UIColorFromRGB(_ rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func addAttachment(_ attachment: EntryFormAttachment, attachmentsViewer: AttachmentsSelectorView?) {
        ViewsHelpers.HandleAttachments(_entryField, attachment: attachment, attachmentsViewer: attachmentsViewer)
    }
    
    func addDoneButton(_ addNextKey: Bool) {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
            target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done,
            target: self, action: #selector(MultilineTypeFieldTypeViewController.endEditing(_:)))
        if addNextKey {
            let nextBarButton = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.plain, target: nil, action: #selector(MultilineTypeFieldTypeViewController.nextLine(_:)))
            keyboardToolbar.items = [nextBarButton, flexBarButton, doneBarButton]
        } else {
            keyboardToolbar.items = [flexBarButton, doneBarButton]
        }
        
        self.textView.inputAccessoryView = keyboardToolbar
    }
    
    func endEditing(_ sender: AnyObject) {
        if let doneEditingWrapper = self.doneEditing, self.textView.text.characters.count == 0 {
            if let allowEmptyData = doneEditingWrapper.EntryFormFieldDoneEditingDelegate?.allowEmptyData(), allowEmptyData == false {
                AlertHelper.DisplayAlert(self, title: NSLocalizedString("Error", comment: "Error title dialog when entered empty data"), messages: [NSLocalizedString("You cannot leave that field empty if you want to save it.", comment: "Error message on error dialog when entered no data.")], callback: .none)
                return
            }
        }
        
        let addedValue = processTextViewToEntryField(self.textView)
        if addedValue {
            if let doneEditingWrapper = self.doneEditing {
                if let ef = self._entryField, let eForm = self.entryForm {
                    if let f = MiscHelpers.CastEntryFormField(ef, Int.self) {
                        doneEditingWrapper.EntryFormFieldDoneEditingDelegate?.handleEditedForm(eForm, entryFormField: f)
                    } else if let f = MiscHelpers.CastEntryFormField(ef, String.self) {
                        doneEditingWrapper.EntryFormFieldDoneEditingDelegate?.handleEditedForm(eForm, entryFormField: f)
                    } else if let f = MiscHelpers.CastEntryFormField(ef, Double.self) {
                        doneEditingWrapper.EntryFormFieldDoneEditingDelegate?.handleEditedForm(eForm, entryFormField: f)
                    } else if let f = MiscHelpers.CastEntryFormField(ef, Float.self) {
                        doneEditingWrapper.EntryFormFieldDoneEditingDelegate?.handleEditedForm(eForm, entryFormField: f)
                    }
                }
            }
            if ViewsHelpers.IsiPad() {
                if let svc = self.splitViewController {
                    svc.showDetailViewController(self.GetEmptyViewForDetailView(), sender: self)
                }
            } else {
                DispatchQueue.main.async(execute: {
                    self.navigationController?.popViewController(animated: true)
                })
            }
        } else {
            //popup error message
        }
    }
    
    func nextLine(_ sender: AnyObject) {
        self.textView.text = self.textView.text + "\n"
    }
    
    func textViewDidChange(_ textView: UITextView) {
        processTextViewToEntryField(textView)
    }
    
    internal func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let cs = self._characterSet {
            let characters = Array(text.characters)
            for c in characters {
                let range = String(c).rangeOfCharacter(from: cs)
                if range == .none {
                    if self._allowedCharactersErrorMessage.characters.count > 0 {
                        AlertHelper.DisplayAlert(self, title: NSLocalizedString("Invalid character", comment: "Title of the dialog when invalid character pressed."), messages: [self._allowedCharactersErrorMessage], callback: .none)
                    }
                    return false
                }
            }
            return true
        }
        return true
    }
    
    func processTextViewToEntryField(_ textView: UITextView) -> Bool {
        var addedValue = false
        if let ef = _entryField {
            if let f = MiscHelpers.CastEntryFormField(ef, Int.self) {
                addedValue = addValue(f, textView: textView)
            } else if let f = MiscHelpers.CastEntryFormField(ef, String.self) {
                addedValue = addValue(f, textView: textView)
            } else if let f = MiscHelpers.CastEntryFormField(ef, Float.self) {
                addedValue = addValue(f, textView: textView)
            } else if let f = MiscHelpers.CastEntryFormField(ef, Double.self) {
                addedValue = addValue(f, textView: textView)
            }
        }
        return addedValue
    }
    
    func addValue<T>(_ formField: EntryFormBaseFieldType<T>, textView: UITextView) -> Bool {
        
        formField.values.removeAll(keepingCapacity: true)
        
        let lines = textView.text.components(separatedBy: "\n")

        for line in lines {
            let added = formField.addValue(line, title: line)
            if !added {
                return false
            }
        }
        
        return true
    }

    func setTextValue<T>(_ formField: EntryFormBaseFieldType<T>) {
        var a: [String] = []
        for el in formField.values {
            a.append(el.1)
        }
        self.textView.text = a.joined(separator: "\n")
    }
}




