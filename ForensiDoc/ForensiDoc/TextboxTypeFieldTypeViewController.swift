//
//  TextboxTypeFieldTypeViewController.swift
//  ForensiDoc
//
//  Created by Andrzej Czarkowski on 16/06/2015.
//  Copyright (c) 2015 Bitmelter Ltd. All rights reserved.
//

import Foundation

//MARK: fix2020
class TextboxTypeFieldTypeViewController: BaseViewController, UITextFieldDelegate {
    @IBOutlet var fieldTitle: UILabel!
    @IBOutlet var textField: UITextField!
    var _characterSet:CharacterSet?
    var _allowedCharactersErrorMessage = ""
    
    var _entryField: Any?
    func setEntryField<T: EntryFormFieldContainer>(_ entryField: T) {
        _entryField = entryField
    }
    
    internal var AllowEmptyData = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let doneButton: UIBarButtonItem? = ViewsHelpers.GetDoneButton(#selector(TextboxTypeFieldTypeViewController.doneEditingAndReturn), target: self)
        
        if let ef = _entryField {
            if let f = MiscHelpers.CastEntryFormField(ef, Int.self) {
                self.title = f.title
                if f.allowedCharacters.count > 0 {
                    self._characterSet = CharacterSet(charactersIn: f.allowedCharacters)
                }
                self._allowedCharactersErrorMessage = f.allowedCharactersErrorMessage
                if f.placeHolder.count > 0 {
                    self.textField.placeholder = f.placeHolder
                }
                self.textField.keyboardType = UIKeyboardType.numberPad
                self.textField.text = f.nonFormattedSelectedValue()
                self.checkIfCanAttachPhotos(f.attachmentsSpec, addAttachmentAction: EntryFormAttachmentAddAction(action: self.addAttachment),entryFormField: f, doneButton: doneButton, attachmentsHeightConstraint: self.attachmentsSelectorViewHeightConstraint,numberOfAttachments: f.attachments.count)
            } else if let f = MiscHelpers.CastEntryFormField(ef, Float.self) {
                self.title = f.title
                if f.allowedCharacters.count > 0 {
                    self._characterSet = CharacterSet(charactersIn: f.allowedCharacters)
                }
                self._allowedCharactersErrorMessage = f.allowedCharactersErrorMessage
                if f.placeHolder.count > 0 {
                    self.textField.placeholder = f.placeHolder
                }
                self.textField.keyboardType = UIKeyboardType.numberPad
                self.textField.text = f.nonFormattedSelectedValue()
                self.checkIfCanAttachPhotos(f.attachmentsSpec, addAttachmentAction: EntryFormAttachmentAddAction(action: self.addAttachment),entryFormField: f, doneButton: doneButton, attachmentsHeightConstraint: self.attachmentsSelectorViewHeightConstraint,numberOfAttachments: f.attachments.count)
            } else if let f = MiscHelpers.CastEntryFormField(ef, Double.self) {
                self.title = f.title
                if f.allowedCharacters.count > 0 {
                    self._characterSet = CharacterSet(charactersIn: f.allowedCharacters)
                }
                self._allowedCharactersErrorMessage = f.allowedCharactersErrorMessage
                if f.placeHolder.count > 0 {
                    self.textField.placeholder = f.placeHolder
                }
                self.textField.keyboardType = UIKeyboardType.numberPad
                self.textField.text = f.nonFormattedSelectedValue()
                self.checkIfCanAttachPhotos(f.attachmentsSpec, addAttachmentAction: EntryFormAttachmentAddAction(action: self.addAttachment),entryFormField: f, doneButton: doneButton, attachmentsHeightConstraint: self.attachmentsSelectorViewHeightConstraint,numberOfAttachments: f.attachments.count)
            } else if let f = MiscHelpers.CastEntryFormField(ef, String.self) {
                self.title = f.title
                if f.allowedCharacters.count > 0 {
                    self._characterSet = CharacterSet(charactersIn: f.allowedCharacters)
                }
                self._allowedCharactersErrorMessage = f.allowedCharactersErrorMessage
                if f.placeHolder.count > 0 {
                    self.textField.placeholder = f.placeHolder
                }
                self.textField.keyboardType = UIKeyboardType.default
                self.textField.text = f.nonFormattedSelectedValue()
                self.checkIfCanAttachPhotos(f.attachmentsSpec, addAttachmentAction: EntryFormAttachmentAddAction(action: self.addAttachment),entryFormField: f, doneButton: doneButton, attachmentsHeightConstraint: self.attachmentsSelectorViewHeightConstraint,numberOfAttachments: f.attachments.count)
            }
            
            
            
            // Would be nice to add this from fucking interface builder
            self.textField.layer.borderWidth = 1.0
            self.textField.layer.borderColor = UIColor(red:0.866, green:0.866, blue:0.866, alpha:1).cgColor
            
            self.textField.backgroundColor = UIColor(red:0.99, green:0.99, blue:0.99, alpha:1)
            
            // And this is fucking horrible
            
            let paddingView = UIView.init(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
            
            self.textField.leftView = paddingView;
            self.textField.leftViewMode = UITextField.ViewMode.always
            
            self.textField.becomeFirstResponder()
        }
    }
    
    func addAttachment(_ attachment: EntryFormAttachment, attachmentsViewer: AttachmentsSelectorView?) {
       _ = ViewsHelpers.HandleAttachments(_entryField, attachment: attachment, attachmentsViewer: attachmentsViewer)
    }
    
    internal func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let cs = self._characterSet {
            let characters = Array(string)
            for c in characters {
                let range = String(c).rangeOfCharacter(from: cs)
                if range == .none {
                    if self._allowedCharactersErrorMessage.count > 0 {
                        AlertHelper.DisplayAlert(self, title: NSLocalizedString("Invalid character", comment: "Title of the dialog when invalid character pressed."), messages: [self._allowedCharactersErrorMessage], callback: .none)
                    }
                    return false
                }
            }
            return true
        }
        return true
    }
    
    @objc func doneEditingAndReturn() {
        if let doneEditingWrapper = self.doneEditing, let textField = self.textField.text, textField.count == 0 {
            if let allowEmptyData = doneEditingWrapper.EntryFormFieldDoneEditingDelegate?.allowEmptyData(), allowEmptyData == false {
                AlertHelper.DisplayAlert(self, title: NSLocalizedString("Error", comment: "Error title dialog when entered empty data"), messages: [NSLocalizedString("You cannot leave that field empty if you want to save it.", comment: "Error message on error dialog when entered no data.")], callback: .none)
                return
            }
        }

        var addedValue = false
        if let ef = _entryField, let textField = self.textField.text {
            let emptyValue = textField.count == 0
            if let f = MiscHelpers.CastEntryFormField(ef, Int.self) {
                addedValue = f.addValue(textField, title: textField)
                if addedValue && f.values.count > 0 {
                    let v = f.values[0]
                    f.selectValue(v)
                } else if emptyValue {
                    f.clearValues()
                }
            } else if let f = MiscHelpers.CastEntryFormField(ef, String.self) {
                addedValue = f.addValue(textField, title: textField)
                if addedValue && f.values.count > 0 {
                    let v = f.values[0]
                    f.selectValue(v)
                } else if emptyValue {
                    f.clearValues()
                }
            } else if let f = MiscHelpers.CastEntryFormField(ef, Float.self) {
                addedValue = f.addValue(textField, title: textField)
                if addedValue && f.values.count > 0 {
                    let v = f.values[0]
                    f.selectValue(v)
                } else if emptyValue {
                    f.clearValues()
                }
            } else if let f = MiscHelpers.CastEntryFormField(ef, Double.self) {
                addedValue = f.addValue(textField, title: textField)
                if addedValue && f.values.count > 0 {
                    let v = f.values[0]
                    f.selectValue(v)
                } else if emptyValue {
                    f.clearValues()
                }
            }
        }
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
        }
        DispatchQueue.main.async(execute: {
            self.navigationController?.popViewController(animated: true)
        })
    }
}
