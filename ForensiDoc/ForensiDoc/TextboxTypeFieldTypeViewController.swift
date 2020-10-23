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
    
    // let pickerTextField = PickerTextField()
    var pickerViewInt: UIPickerView!
    var pickerViewDouble: UIPickerView!
    var pickerDataInt: [Int] = []
    var pickerDataDouble: [Int] = Array(0...9)
    var valueType: String = ""
    var numberOfComponents: Int = 1
    
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
                
                //titles which call picker view
                if title != nil, title! == "Systolic Blood Pressure" || title! == "Diastolic Blood Pressure" {
                    setupPickerData(withRangeIn: 0...250)
                    valueType = "mm Hg"
                    if title! == "Systolic Blood Pressure" {
                        setupPickerView(withDefaultRow: 120)
                    }
                    if title! == "Diastolic Blood Pressure" {
                        setupPickerView(withDefaultRow: 80)
                    }
                    
                    if f.allowedCharacters.count > 0 {
                        self._characterSet = CharacterSet(charactersIn: f.allowedCharacters)
                    }
                    
                    self._allowedCharactersErrorMessage = f.allowedCharactersErrorMessage
                    if f.placeHolder.count > 0 {
                        self.textField.placeholder = f.placeHolder
                    }
                    
                    // self.textField.keyboardType = .numberPad
                    textField.text = f.nonFormattedSelectedValue()
                    self.checkIfCanAttachPhotos(f.attachmentsSpec, addAttachmentAction: EntryFormAttachmentAddAction(action: self.addAttachment),entryFormField: f, doneButton: doneButton, attachmentsHeightConstraint: self.attachmentsSelectorViewHeightConstraint,numberOfAttachments: f.attachments.count)
                    
                } else {
                    //other titles call textField with numberpad
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
                }
            } else
            //float type of textField
            if let f = MiscHelpers.CastEntryFormField(ef, Float.self) {
                self.title = f.title
                
                //titles which call picker view
                if title != nil, title!.contains("Blood Glucose") {
                    valueType = "mmol/L"
                    numberOfComponents = 2
                    setupPickerData(withRangeIn: 0...35)
                    setupPickerView(withDefaultRow: 6)
                    
                    if f.allowedCharacters.count > 0 {
                        self._characterSet = CharacterSet(charactersIn: f.allowedCharacters)
                    }
                    self._allowedCharactersErrorMessage = f.allowedCharactersErrorMessage
                    if f.placeHolder.count > 0 {
                        self.textField.placeholder = f.placeHolder
                    }
                    //self.textField.keyboardType = UIKeyboardType.numberPad
                    self.textField.text = f.nonFormattedSelectedValue()
                    self.checkIfCanAttachPhotos(f.attachmentsSpec, addAttachmentAction: EntryFormAttachmentAddAction(action: self.addAttachment),entryFormField: f, doneButton: doneButton, attachmentsHeightConstraint: self.attachmentsSelectorViewHeightConstraint,numberOfAttachments: f.attachments.count)
                    
                } else {
                    //titles which call textField
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
                }
            } else
            if let f = MiscHelpers.CastEntryFormField(ef, Double.self) {
                self.title = f.title
                
                if title != nil, title!.contains("Temperature") {
                    valueType = "C˚"
                    numberOfComponents = 2
                    setupPickerData(withRangeIn: 34...40)
                    setupPickerView(withDefaultRow: 3)
                    if f.allowedCharacters.count > 0 {
                        self._characterSet = CharacterSet(charactersIn: f.allowedCharacters)
                    }
                    self._allowedCharactersErrorMessage = f.allowedCharactersErrorMessage
                    if f.placeHolder.count > 0 {
                        self.textField.placeholder = f.placeHolder
                    }
                    //self.textField.keyboardType = UIKeyboardType.numberPad
                    self.textField.text = f.nonFormattedSelectedValue()
                    self.checkIfCanAttachPhotos(f.attachmentsSpec, addAttachmentAction: EntryFormAttachmentAddAction(action: self.addAttachment),entryFormField: f, doneButton: doneButton, attachmentsHeightConstraint: self.attachmentsSelectorViewHeightConstraint,numberOfAttachments: f.attachments.count)
                } else {
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
                }
            } else
            if let f = MiscHelpers.CastEntryFormField(ef, String.self) {
                self.title = f.title
                
                if title != nil, title!.contains("Respiratory") {
                    print(title!)
                    if title!.contains("Respiratory") {
                        setupPickerData(withRangeIn: 1...40)
                        setupPickerView(withDefaultRow: 15)                        
                        valueType = ""
                    }
                }
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
            self.textField.leftViewMode = .always
            
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
        if pickerViewInt != nil {
        let selectedFirstRow = pickerViewInt.selectedRow(inComponent: 0)
        var selectedSecondRow: Int = 0
        var text: String = ""
        text = (pickerDataInt.count > 0) ? "\(pickerDataInt[selectedFirstRow])" : ""
        if numberOfComponents == 2, pickerDataDouble.count > 0 {
            selectedSecondRow = pickerViewInt.selectedRow(inComponent: 1)
            text = text + ".\(pickerDataDouble[selectedSecondRow])"
        }
        
        textField.text = text
    }
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
extension TextboxTypeFieldTypeViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        numberOfComponents
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if component == 1 { return pickerDataDouble.count
        } else {
         return pickerDataInt.count }
    }
    
    private func setupPickerData(withRangeIn range: ClosedRange<Int>) {
        //validate(in: range)
        pickerDataInt = Array(range)
    }
    
    //   private func validate<R>(in range: R) where R: RangeExpression {//, R.Bound == Int {
    //        let r = R.Bound.self
    //        if r is Int.Type {
    //            print("!!!!!!!!!!!!!!!!!")
    //        }
    //    }
    //
    //    func setupPickerDataGeneric<T: Comparable>(withRangeIn range: ClosedRange<T>) {
    //
    //    }
    
    private func setupPickerView(withDefaultRow value: Int) {
        pickerViewInt = UIPickerView()
        pickerViewInt.delegate = self
        pickerViewInt.dataSource = self
        pickerViewInt.selectRow(value, inComponent: 0, animated: false)
        let selectedFirstRow = pickerViewInt.selectedRow(inComponent: 0)
        if numberOfComponents == 2 {
            pickerViewInt.selectRow(0, inComponent: 1, animated: false)
            let selectedSecondRow = pickerViewInt.selectedRow(inComponent: 1)
            textField.text = "\(pickerDataInt[selectedFirstRow]).\(pickerDataDouble[selectedSecondRow])"
        } else {
            textField.text = "\(pickerDataInt[selectedFirstRow]) \(valueType)"
        }
        
        let toolBar = UIToolbar(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 44.0)))
        let button = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.doneEditingAndReturn))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([space, button], animated: true)
        
        textField.inputAccessoryView = toolBar
        textField.inputView = pickerViewInt
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 1 {
         return "\(pickerDataDouble[row])"
        } else {
        return "\(pickerDataInt[row]) \(valueType)"
        }
    }
    
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if numberOfComponents == 2 {
        if component == 0 {
        let selectedSecondRow = pickerViewInt.selectedRow(inComponent: 1)
        textField.text = "\(pickerDataInt[row]).\(pickerDataDouble[selectedSecondRow])"
        } else {
            let selectedFirstRow = pickerViewInt.selectedRow(inComponent: 0)
            textField.text = "\(pickerDataInt[selectedFirstRow]).\(pickerDataDouble[row])"
        }
        } else {
        
            textField.text = "\(pickerDataInt[row])"
        }
        //  }
    }
    
}
