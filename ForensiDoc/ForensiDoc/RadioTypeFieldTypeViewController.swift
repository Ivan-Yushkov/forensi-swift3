//
//  RadioTypeFieldTypeViewController.swift
//  ForensiDoc
//
//  Created by Andrzej Czarkowski on 16/06/2015.
//  Copyright (c) 2015 Bitmelter Ltd. All rights reserved.
//

import Foundation


class RadioCheckboxTypeFieldTypeViewController: BaseViewController, EntryFormMultipleChoiceDelegate, UITextViewDelegate {
    fileprivate var _factory: EntryFormMultipleChoiceFactory? = .none
    @IBOutlet var mainTbl: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let ef = self.entryForm, let eField = _entryField {
            _factory = EntryFormMultipleChoiceFactory(tableView: self.mainTbl, entryForm: ef, entryField: eField, delegate: self)
            self.mainTbl.dataSource = _factory
            self.mainTbl.delegate = _factory
            
            let doneButton: UIBarButtonItem? = ViewsHelpers.GetDoneButton(#selector(RadioCheckboxTypeFieldTypeViewController.selectValueAndReturn), target: self)
            
            if let entryField = _entryField {
                if let f = MiscHelpers.CastEntryFormField(entryField, Int.self) {
                    self.title = f.title
                    self.checkIfCanAttachPhotos(f.attachmentsSpec, addAttachmentAction: EntryFormAttachmentAddAction(action: self.addAttachment),entryFormField: f, doneButton: doneButton, attachmentsHeightConstraint: self.attachmentsSelectorViewHeightConstraint,
                        numberOfAttachments: f.attachments.count)
                } else if let f = MiscHelpers.CastEntryFormField(entryField, Float.self) {
                    self.title = f.title
                    self.checkIfCanAttachPhotos(f.attachmentsSpec, addAttachmentAction: EntryFormAttachmentAddAction(action: self.addAttachment),entryFormField: f, doneButton: doneButton, attachmentsHeightConstraint: self.attachmentsSelectorViewHeightConstraint,
                        numberOfAttachments: f.attachments.count)
                } else if let f = MiscHelpers.CastEntryFormField(entryField, Double.self) {
                    self.title = f.title
                    self.checkIfCanAttachPhotos(f.attachmentsSpec, addAttachmentAction: EntryFormAttachmentAddAction(action: self.addAttachment),entryFormField: f, doneButton: doneButton, attachmentsHeightConstraint: self.attachmentsSelectorViewHeightConstraint,
                        numberOfAttachments: f.attachments.count)
                } else if let f = MiscHelpers.CastEntryFormField(entryField, String.self) {
                    self.title = f.title
                    self.checkIfCanAttachPhotos(f.attachmentsSpec, addAttachmentAction: EntryFormAttachmentAddAction(action: self.addAttachment),entryFormField: f, doneButton: doneButton, attachmentsHeightConstraint: self.attachmentsSelectorViewHeightConstraint,numberOfAttachments: f.attachments.count)
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.refreshFactoryData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func addAttachment(_ attachment: EntryFormAttachment, attachmentsViewer: AttachmentsSelectorView?) {
        let shouldRefresh = ViewsHelpers.HandleAttachments(_entryField, attachment: attachment, attachmentsViewer: attachmentsViewer)
        if shouldRefresh {
            self.refreshFactoryData()
        }
    }
    
    var _entryField: Any?
    func setEntryField<T: EntryFormFieldContainer>(_ entryField: T) {
        _entryField = entryField
    }
    
    func enterValueForOther<T>(_ f: EntryFormBaseFieldType<T>) {
        let newValue: NewRadioCheckboxOtherViewController = NewRadioCheckboxOtherViewController(nibName:"NewRadioCheckboxOtherView", bundle: nil)
        newValue.setEntryField(f)
        DispatchQueue.main.async(execute: {
            self.navigationController?.pushViewController(newValue, animated: true)
        })

    }
    
    func valueHasBeenSelected() {
        
    }
    
    @objc func selectValueAndReturn() {
        if let factory = _factory {
            factory.SelectValue()
        }
        if let ef = _entryField, let eForm = self.entryForm {
            if let f = MiscHelpers.CastEntryFormField(ef, Double.self) {
                self.doneEditing?.EntryFormFieldDoneEditingDelegate?.handleEditedForm(eForm, entryFormField: f)
            } else if let f = MiscHelpers.CastEntryFormField(ef, Float.self) {
                self.doneEditing?.EntryFormFieldDoneEditingDelegate?.handleEditedForm(eForm, entryFormField: f)
            } else if let f = MiscHelpers.CastEntryFormField(ef, String.self) {
                self.doneEditing?.EntryFormFieldDoneEditingDelegate?.handleEditedForm(eForm, entryFormField: f)
            } else if let f = MiscHelpers.CastEntryFormField(ef, Int.self) {
                self.doneEditing?.EntryFormFieldDoneEditingDelegate?.handleEditedForm(eForm, entryFormField: f)
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
    
    internal func textViewDidEndEditing(_ textView: UITextView) {
        if let ef = _entryField {
            if let f = MiscHelpers.CastEntryFormField(ef, Double.self) {
                f.addFieldComments(textView.text)
            } else if let f = MiscHelpers.CastEntryFormField(ef, Float.self) {
                f.addFieldComments(textView.text)
            } else if let f = MiscHelpers.CastEntryFormField(ef, String.self) {
                f.addFieldComments(textView.text)
            } else if let f = MiscHelpers.CastEntryFormField(ef, Int.self) {
                f.addFieldComments(textView.text)
            }
        }
    }
    
    fileprivate func refreshFactoryData() {
        if let f = _factory {
            f.shouldRefresh()
        }
    }
}
