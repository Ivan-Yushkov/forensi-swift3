//
//  MultipleEntryViewController.swift
//  ForensiDoc
//
//  Created by Andrzej Czarkowski on 29/01/2016.
//  Copyright © 2016 Bitmelter Ltd. All rights reserved.
//

import Foundation

class MultipleEntryViewController: BaseViewController, EntryFormFieldDoneEditing {
    @IBOutlet var entriesTable: UITableView!
    var _textCellIdentifier = MiscHelpers.RandomStringWithLength(10)
    
    var _entryField: EntryFormMultipleEntry?
    func setEntryField(_ entryField: EntryFormMultipleEntry) {
        _entryField = entryField
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "MultipleEntryViewCell", bundle: Bundle.main)
        entriesTable.register(nib, forCellReuseIdentifier: _textCellIdentifier)

        if let ef = self._entryField {
           self.title = ef.title
        }
        let addNewEntryButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(MultipleEntryViewController.addNewEntryButtonTapped(_:)))
        self.navigationItem.setRightBarButton(addNewEntryButton, animated: true)
    }
    
    func addNewEntryButtonTapped(_ sender: AnyObject) {
        if let eField = self._entryField, let ef = self.entryForm {
            if let baseType = eField.baseType, let fieldType = eField.fieldType {
                switch baseType {
                case .Double:
                    if let f = MiscHelpers.CreateFormFieldType(fieldType, baseType: Double.self, forMultifield: true) {
                        if let field = populateFieldsForEntryForm(f, attachmentSpec: eField.attachmentsSpec, Double.self) {
                            ViewsHelpers.HandleFormField(self, entryForm: ef, entryFormBaseFieldType: field, doneEditing: self)
                        }
                    }
                case .Float:
                    if let f = MiscHelpers.CreateFormFieldType(fieldType, baseType: Float.self, forMultifield: true) {
                        if let field = populateFieldsForEntryForm(f, attachmentSpec: eField.attachmentsSpec, Float.self) {
                            ViewsHelpers.HandleFormField(self, entryForm: ef, entryFormBaseFieldType: field, doneEditing: self)
                        }
                    }
                case .Int:
                    if let f = MiscHelpers.CreateFormFieldType(fieldType, baseType: Int.self, forMultifield: true) {
                        if let field = populateFieldsForEntryForm(f, attachmentSpec: eField.attachmentsSpec, Int.self) {
                            ViewsHelpers.HandleFormField(self, entryForm: ef, entryFormBaseFieldType: field, doneEditing: self)
                        }
                    }
                case .String:
                    if let f = MiscHelpers.CreateFormFieldType(fieldType, baseType: String.self, forMultifield: true) {
                        if let field = populateFieldsForEntryForm(f, attachmentSpec: eField.attachmentsSpec, String.self) {
                            ViewsHelpers.HandleFormField(self, entryForm: ef, entryFormBaseFieldType: field, doneEditing: self)
                        }
                    }
                }
            }
        }
    }
    
    func handleEditedForm<T: EntryFormFieldContainer>(_ entryForm: EntryForm, entryFormField: T) {
        if let ef = self._entryField {
            ef.fields.append(entryFormField)
            self.entriesTable.reloadData()
            if ViewsHelpers.IsiPad() {
                if let svc = self.splitViewController {
                    svc.showDetailViewController(self.GetEmptyViewForDetailView(), sender: self)
                }
            }
        }
    }
    
    func shouldAskForTitle() -> Bool {
        return true
    }
    
    func allowEmptyData()-> Bool {
        return false
    }
    
    func populateFieldsForEntryForm<T>(_ formField: Any?, attachmentSpec: EntryFormAttachmentSpec?, _: T.Type) -> EntryFormBaseFieldType<T>? {
        if let f = formField as? EntryFormBaseFieldType<T> {
            if let attSpec = attachmentSpec {
                f.attachmentsSpec = attSpec
            }
            return f
        }
        return .none
    }
}
