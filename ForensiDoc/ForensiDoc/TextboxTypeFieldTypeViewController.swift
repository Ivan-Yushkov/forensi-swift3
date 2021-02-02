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
    
    var pickerViewInt: UIPickerView!
    var pickerViewString: UIPickerView!
        
    var pickerDataInt: [Int] = []
//    var pickerDataDouble: [Int] = Array(0...9)
    var valueType: String = ""
    var decimal: Bool = false
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
                let text = f.nonFormattedSelectedValue()
                textField.text = text
                if f.id.contains("systolic"){
                    valueType = "mm Hg"
                    if text.isEmpty {
                        setupPickerView(withRangeIn: 0...250, withDefaultRow: 120)
                    } else {
                        if let value = Int(text) {
                        setupPickerView(withRangeIn: 0...250, withDefaultRow: value)
                        }
                    }
                }
                if f.id.contains("diastolic") {
                    valueType = "mm Hg"
                    if text.isEmpty {
                        setupPickerView(withRangeIn: 0...250, withDefaultRow: 80)
                    } else {
                        if let value = Int(text) {
                        setupPickerView(withRangeIn: 0...250, withDefaultRow: value)
                        }
                    }
                }
                if f.allowedCharacters.count > 0 {
                    self._characterSet = CharacterSet(charactersIn: f.allowedCharacters)
                }
                self._allowedCharactersErrorMessage = f.allowedCharactersErrorMessage
                if f.placeHolder.count > 0 {
                    self.textField.placeholder = f.placeHolder
                }
                self.textField.keyboardType = .numberPad
                self.checkIfCanAttachPhotos(f.attachmentsSpec, addAttachmentAction: EntryFormAttachmentAddAction(action: self.addAttachment),entryFormField: f, doneButton: doneButton, attachmentsHeightConstraint: self.attachmentsSelectorViewHeightConstraint,numberOfAttachments: f.attachments.count)
                
            } else
            //float type of textField
            if let f = MiscHelpers.CastEntryFormField(ef, Float.self) {
                self.title = f.title
                let text = f.nonFormattedSelectedValue()
                textField.text = text
                
                //titles which call picker view
                if f.id.contains("glucose") {
                    valueType = "mmol/L"
                    numberOfComponents = 1
                    decimal = true
                    setupPickerView(withRangeIn: 0...350, withDefaultRow: 50)
                }
                if f.allowedCharacters.count > 0 {
                    self._characterSet = CharacterSet(charactersIn: f.allowedCharacters)
                }
                self._allowedCharactersErrorMessage = f.allowedCharactersErrorMessage
                if f.placeHolder.count > 0 {
                    self.textField.placeholder = f.placeHolder
                }
                self.textField.keyboardType = UIKeyboardType.numberPad
                self.checkIfCanAttachPhotos(f.attachmentsSpec, addAttachmentAction: EntryFormAttachmentAddAction(action: self.addAttachment),entryFormField: f, doneButton: doneButton, attachmentsHeightConstraint: self.attachmentsSelectorViewHeightConstraint,numberOfAttachments: f.attachments.count)
                
            } else
            if let f = MiscHelpers.CastEntryFormField(ef, Double.self) {
                self.title = f.title
                let text = f.nonFormattedSelectedValue()
                textField.text = text
                
                if f.id.contains("temperature") {
                    valueType = "C˚"
                    numberOfComponents = 1
                    decimal = true
                    setupPickerView(withRangeIn: 340...400, withDefaultRow: 30)
                }
                if f.allowedCharacters.count > 0 {
                    self._characterSet = CharacterSet(charactersIn: f.allowedCharacters)
                }
                self._allowedCharactersErrorMessage = f.allowedCharactersErrorMessage
                if f.placeHolder.count > 0 {
                    self.textField.placeholder = f.placeHolder
                }
                              
                self.checkIfCanAttachPhotos(f.attachmentsSpec, addAttachmentAction: EntryFormAttachmentAddAction(action: self.addAttachment),entryFormField: f, doneButton: doneButton, attachmentsHeightConstraint: self.attachmentsSelectorViewHeightConstraint,numberOfAttachments: f.attachments.count)
                
            } else
            if let f = MiscHelpers.CastEntryFormField(ef, String.self) {
                self.title = f.title
                let text = f.nonFormattedSelectedValue()
                textField.text = text
                
                if f.id.contains("interpreter") || f.id.contains("language") {
                    if text.isEmpty {
                        setupPickerString(selectedRow: nil)
                    } else {
                        if let row = getRowFromString(lang: text) {
                            setupPickerString(selectedRow: row)
                        } else {
                            setupPickerString(selectedRow: nil)
                        }
                    }
                }
                if f.id.contains("respiratory") {
                    if text.isEmpty {
                        setupPickerView(withRangeIn: 1...40, withDefaultRow: 15)
                    } else {
                        if let value = Int(text) {
                            setupPickerView(withRangeIn: 1...40, withDefaultRow: value - 1)
                        }
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
        saveDataFromSignature()
        if pickerViewInt != nil {
            let selectedFirstRow = pickerViewInt.selectedRow(inComponent: 0)
            var text: String = ""
            text = (pickerDataInt.count > 0) ? "\(pickerDataInt[selectedFirstRow])" : ""
            if numberOfComponents == 1, decimal {
                text = "\((Double(pickerDataInt[selectedFirstRow]) * 0.1).roundToDecimal(1))"
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
    
    
    private func saveDataFromSignature() {
        let name = UserDefaults.standard.string(forKey: "name")
        if name != "" {
            var dictionary = [String: String]()
            var array = [dictionary]
            dictionary["signature"] = textField.text
            dictionary["name"] = UserDefaults.standard.string(forKey: "name")
            dictionary["address"] = UserDefaults.standard.string(forKey: "address")
            dictionary["email"] = UserDefaults.standard.string(forKey: "email")
            dictionary["telephone"] = UserDefaults.standard.string(forKey: "telephone")
            dictionary["insurance"] = UserDefaults.standard.string(forKey: "insurance")
            let jsonData = try! JSONSerialization.data(withJSONObject: dictionary, options: [])
            let decoded = try! JSONSerialization.jsonObject(with: jsonData, options: [])
            
            saveArrayToDefaults(dictionary: dictionary)
            //EntryForm.signatureJson.append(decoded)
            deleteValuesFromDefaults()
            
//            if let documentDirectory = FileManager.default.urls(for: .documentDirectory,
//                                                                in: .userDomainMask).first {
//                let pathWithFilename = documentDirectory.appendingPathComponent(".json")
//                do {
//                    try jsonString.write(to: pathWithFilename,
//                                         atomically: true,
//                                         encoding: .utf8)
//                } catch {
//                    // Handle error
//                }
            //print(EntryForm.signatureJson)
            fromDefaultsToJSON()
        }
    }
    
    private func deleteValuesFromDefaults() {
        UserDefaults.standard.set("", forKey: "name")
        UserDefaults.standard.set("", forKey: "address")
        UserDefaults.standard.set("", forKey: "email")
        UserDefaults.standard.set("", forKey: "telephone")
        UserDefaults.standard.set("", forKey: "insurance")
    }
    
    private func saveArrayToDefaults(dictionary: [String: String]) {
        var defaultsArray = UserDefaults.standard.array(forKey: "array") as? [[String: String]]
        defaultsArray?.append(dictionary)
        UserDefaults.standard.set(defaultsArray, forKey: "array")
    }
    
    private func fromDefaultsToJSON() {
        guard let array = UserDefaults.standard.array(forKey: "array") as? [[String: String]] else { return }
        var signatures = [Signature]()
        for dict in array {
            let signature = Signature(dictionary: dict)
            signatures.append(signature)
        }
        let jsonData = try! JSONEncoder().encode(signatures)
        let decodedSignatures = try! JSONSerialization.jsonObject(with: jsonData, options: [])
        print(decodedSignatures)
    }
}
extension TextboxTypeFieldTypeViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        numberOfComponents
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView == pickerViewString {
            return languageArray.count
        } else {
                return pickerDataInt.count }
    }
    
    //    private func setupPickerData(withRangeIn range: ClosedRange<Int>) {
    //        //validate(in: range)
    //        pickerDataInt = Array(range)
    //    }
    
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
    
    private func setupPickerView(withRangeIn range: ClosedRange<Int>, withDefaultRow value: Int) {
        
        pickerDataInt = Array(range)
        pickerViewInt = UIPickerView()
        pickerViewInt.delegate = self
        pickerViewInt.dataSource = self
        pickerViewInt.selectRow(value, inComponent: 0, animated: false)
        
        let selectedRow = pickerViewInt.selectedRow(inComponent: 0)
            if decimal {
                textField.text = "\((Double(pickerDataInt[selectedRow]) * 0.1).roundToDecimal(1))  \(valueType)"
            } else {
                textField.text = "\(pickerDataInt[selectedRow]) \(valueType)"
            }
        
        let toolBar = UIToolbar(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 44.0)))
        let button = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.doneEditingAndReturn))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([space, button], animated: true)
        
        textField.inputAccessoryView = toolBar
        textField.inputView = pickerViewInt
        textField.tintColor = .clear
    }
    
    private func setupPickerString(selectedRow: Int?) {
        
        pickerViewString = UIPickerView()
        pickerViewString.delegate = self
        pickerViewString.dataSource = self
        
        if selectedRow != nil {
            pickerViewString.selectRow(selectedRow!, inComponent: 0, animated: false)
        } else {
            pickerViewString.selectRow(0, inComponent: 0, animated: false)
        }
        
                
        let toolBar = UIToolbar(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 44.0)))
        let button = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.doneEditingAndReturn))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([space, button], animated: true)
        
        textField.inputAccessoryView = toolBar
        textField.inputView = pickerViewString
        textField.tintColor = .clear
    }
    
    private func getRowFromString(lang: String) -> Int? {
        for (idx,text) in languageArray.enumerated() {
            if text == lang {
                return Int(idx)
            }
        }
        return nil
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == pickerViewString {
            return languageArray[row]
        } else {
            if decimal {
                return "\((Double(pickerDataInt[row]) * 0.1).roundToDecimal(1)) \(valueType)"
            }
            return "\(pickerDataInt[row]) \(valueType)"
        }
    }
    
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == pickerViewString {
            textField.text = languageArray[row]
        } else {
            if decimal {
                textField.text = "\((Double(pickerDataInt[row]) * 0.1).roundToDecimal(1)) \(valueType)"
            } else {
                textField.text = "\(pickerDataInt[row]) \(valueType)"
            }
        }
    }
    
}

