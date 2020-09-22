//
//  NewEntryFormViewController.swift
//  ForensiDoc
//
//  Created by Andrzej Czarkowski on 10/06/2015.
//  Copyright (c) 2015 Bitmelter Ltd. All rights reserved.
//

import Foundation

class NewEntryFormViewController: BaseViewController, EntryFormAddNewFactoryProtocol, EntryFormFieldDoneEditing {
    fileprivate var _factory: EntryFormAddNewFactory? = .none
    fileprivate var _addAttachmentsButton: UIBarButtonItem? = .none
    
    
    @IBOutlet var mainTbl: UITableView!
    
    var _subGroup: EntryFormGroup?
    var subGroup: EntryFormGroup? {
        get {
            return _subGroup
        }
        set {
            _subGroup = newValue
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let sb = _subGroup {
            self.title = sb.title
        }
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let ef = self.entryForm {
            self.saveForm(ef)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if ((self.navigationController?.viewControllers.contains(self)) == nil) {
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    dynamic func entryFormAttachmentAdded(_ notification: Notification) {
        if let f = _factory {
            f.shouldRefresh()
        }
    }
    
    func handleEditedForm<T: EntryFormFieldContainer>(_ entryForm: EntryForm, entryFormField: T) {
        if let f = _factory {
            f.shouldRefresh()
        }
    }
    
    func shouldAskForTitle() -> Bool {
        return false
    }
    
    func allowEmptyData()-> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let svc = self.splitViewController {
            svc.preferredDisplayMode = .allVisible
        }
        
        if let ef = self.entryForm {
            NotificationCenter.default.addObserver(self, selector: #selector(NewEntryFormViewController.entryFormAttachmentAdded(_:)), name:NSNotification.Name(rawValue: EntryForm.ATTACHMENT_ADDED_NOTIFICATION), object: nil)
            _factory = EntryFormAddNewFactory(entryForm: ef, subGroup: subGroup, tableView: self.mainTbl, delegate: self)
            self.mainTbl.dataSource = _factory
            self.mainTbl.delegate = _factory
            if let vc = self.navigationController?.viewControllers, vc.count >= 2 {
                if ef.canAddAttachments() {
                    let previous = vc[vc.count - 2]
                    if !(previous is NewEntryFormViewController) {
                        _addAttachmentsButton = UIBarButtonItem(image: UIImage(named: "Btn-Attachment"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(NewEntryFormViewController.addAttachmentsButtonTapped(_:)))
                        self.attachmentsSpec = ef.AttachmentsSpec
                        self.navigationItem.setRightBarButton(_addAttachmentsButton, animated: true)
                    }
                }
            }
        }
    }
    
    @IBAction internal func addAttachmentsButtonTapped(_ sender: AnyObject) {
        if let ef = self.entryForm {
            self.addAttachmentAction = EntryFormAttachmentAddAction(action: self.addAttachment)
            if let alert = ViewsHelpers.CreateAttachmentsPopup(ef.AttachmentsSpec,
                audioAction: self.addAudio,
                imagePhotoAction: self.imagePhotoAction,
                imageSavePhotoAction: self.savedImagePhotoAction,
                videoAction: self.addVideo,
                drawingAction: self.addDrawing,
                savedVideoAction: self.videoSavedVideoAction)
            {
                if ViewsHelpers.IsiPad() {
                    if let addAttchmentsButton = _addAttachmentsButton {
                        alert.popoverPresentationController?.barButtonItem = addAttchmentsButton
                    } else {
                        alert.popoverPresentationController?.sourceView = self.view
                        alert.popoverPresentationController?.sourceRect = self.view.frame
                    }
                }
                self.present(alert, animated: true, completion: .none)
            }
        }
    }
    
    func addAttachment(_ attachment: EntryFormAttachment, attachmentsViewer: AttachmentsSelectorView?) {
        if let ef = self.entryForm {
            ef.addAttachment(attachment)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let f = _factory {
            f.shouldRefresh()
        }
    }
    
    fileprivate func saveForm(_ entryForm: EntryForm) {
        let repo = ForensiDocEntryFormRepository()
        repo.SaveEntryForm(entryForm)
    }
    
    func getTableView(_ entryFormField: Any) -> UITableViewCell? {
        return .none
    }
    
    func viewSubGroupForEntryFormGroup(_ entryForm: EntryForm, entryFormGroup: EntryFormGroup) {
        let newEntryForm: NewEntryFormViewController = NewEntryFormViewController(nibName:"NewEntryFormView", bundle:nil)
        newEntryForm.entryForm = entryForm
        newEntryForm.subGroup = entryFormGroup
        
        DispatchQueue.main.async(execute: {
            self.navigationController?.pushViewController(newEntryForm, animated: true)
        })
        
    }
    
    func informAboutCalculatedField(_ message: String) {
        AlertHelper.DisplayAlert(self, title: NSLocalizedString("Info", comment: "Title on dialog when displaying info about calculated field"), messages: [message], callback: .none)
    }
    
    func viewFormField(_ entryForm: EntryForm, formField: Any) {
        if let f = MiscHelpers.CastEntryFormField(formField, Int.self) {
            ViewsHelpers.HandleFormField(self, entryForm: entryForm, entryFormBaseFieldType: f, doneEditing: self)
        } else if let f = MiscHelpers.CastEntryFormField(formField, String.self) {
            ViewsHelpers.HandleFormField(self, entryForm: entryForm, entryFormBaseFieldType: f, doneEditing: self)
        } else if let f = MiscHelpers.CastEntryFormField(formField, Float.self) {
            ViewsHelpers.HandleFormField(self, entryForm: entryForm, entryFormBaseFieldType: f, doneEditing: self)
        } else if let f = MiscHelpers.CastEntryFormField(formField, Double.self) {
            ViewsHelpers.HandleFormField(self, entryForm: entryForm, entryFormBaseFieldType: f, doneEditing: self)
        } else if formField is EntryFormMultipleEntry {
            let multipleEntryField = formField as! EntryFormMultipleEntry
            handleMultipleEntry(entryForm, multipleEntryField: multipleEntryField)
        }
    }
    
    func viewDrawableFormField(_ entryForm: EntryForm, entryFormDrawable: EntryFormDrawable) {
        let def : DrawableEntryFormViewController = DrawableEntryFormViewController(nibName:"DrawableEntryFormView", bundle: nil)
        
        def.entryForm = entryForm
        def.entryFormDrawable = entryFormDrawable
        
        if let svc = self.splitViewController
        {
            def.modalPresentationStyle = .fullScreen
            svc.present(def, animated: true, completion: { () -> Void in })
        }
    }
    
    func viewAttachmentsForEntryForm(_ entryForm: EntryForm) {
        let attachmentsViewController = AttachmentsViewerViewController(nibName:"AttachmentsViewerView", bundle: nil)
        attachmentsViewController.attachments = entryForm.Attachments
        attachmentsViewController.AttachmentDeleted = {(deletedAttachment) -> Void in
            entryForm.DeleteAttachment(deletedAttachment)
        }
        DispatchQueue.main.async(execute: {
            if let svc = self.splitViewController {
                if ViewsHelpers.IsiPad() {
                    svc.showDetailViewController(UINavigationController(rootViewController: attachmentsViewController), sender: self)
                } else {
                    svc.showDetailViewController(attachmentsViewController, sender: self)
                }
            } else {
                self.navigationController?.pushViewController(attachmentsViewController, animated: true)
            }
        })
    }
    
    func handleMultipleEntry(_ entryForm: EntryForm, multipleEntryField: EntryFormMultipleEntry) {
        let multipleEntry = MultipleEntryViewController(nibName: "MultipleEntryView", bundle: nil)
        multipleEntry.entryForm = entryForm
        multipleEntry.setEntryField(multipleEntryField)
        self.navigationController?.pushViewController(multipleEntry, animated: true)
    }
}
