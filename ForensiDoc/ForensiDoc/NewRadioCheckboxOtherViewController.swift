//
//  NewRadioCheckboxOtherViewController.swift
//  ForensiDoc
//
//  Created by Andrzej Czarkowski on 24/06/2015.
//  Copyright (c) 2015 Bitmelter Ltd. All rights reserved.
//

import Foundation

class NewRadioCheckboxOtherViewController: BaseViewController, UITextFieldDelegate {
    @IBOutlet var otherValue: UITextField!
    
    var _entryField: Any?
    func setEntryField<T: EntryFormFieldContainer>(_ entryField: T) {
        _entryField = entryField
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let ef = _entryField {
            var addDone = false
            if let f = MiscHelpers.CastEntryFormField(ef, Int.self) {
                self.title = f.title
                self.otherValue.keyboardType = UIKeyboardType.numberPad
                addDone = true
            } else if let f = MiscHelpers.CastEntryFormField(ef, Float.self) {
                self.title = f.title
                self.otherValue.keyboardType = UIKeyboardType.decimalPad
                addDone = true
            } else if let f = MiscHelpers.CastEntryFormField(ef, Double.self) {
                self.title = f.title
                self.otherValue.keyboardType = UIKeyboardType.decimalPad
                addDone = true
            } else if let f = MiscHelpers.CastEntryFormField(ef, String.self) {
                self.title = f.title
                self.otherValue.keyboardType = UIKeyboardType.default
            }
            if addDone {
                addDoneButton()
            } else {
                self.otherValue.returnKeyType = UIReturnKeyType.done
            }
            self.otherValue.becomeFirstResponder()
        }
    }
    
    func addDoneButton() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(NewRadioCheckboxOtherViewController.endEditing(_:)))
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        self.otherValue.inputAccessoryView = keyboardToolbar
    }
    
    func endEditing(_ sender: AnyObject) {
        textFieldShouldReturn(self.otherValue)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let ef = _entryField, let textField = textField.text {
            var addedOtherValue = false
            if let f = MiscHelpers.CastEntryFormField(ef, Int.self) {
                if let v = Int(textField) {
                    f.selectValue((v, textField))
                    addedOtherValue = true
                }
            } else if let f = MiscHelpers.CastEntryFormField(ef, Float.self) {
                if let v = textField.toFloat() {
                    f.selectValue((v, textField))
                    addedOtherValue = true
                }
            } else if let f = MiscHelpers.CastEntryFormField(ef, Double.self) {
                if let v = textField.toDouble() {
                    f.selectValue((v, textField))
                    addedOtherValue = true
                }
            } else if let f = MiscHelpers.CastEntryFormField(ef, String.self) {
                f.selectValue((textField, textField))
                addedOtherValue = true
            }
            if addedOtherValue {
                DispatchQueue.main.async(execute: {
                    self.navigationController?.popViewController(animated: true)
                })
            } else {
                //popup error message
            }
            
        }
        return false
    }
}

