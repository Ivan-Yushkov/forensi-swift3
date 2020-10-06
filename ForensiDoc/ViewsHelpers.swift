//
//  ViewsHelpers.swift
//  ForensiDoc
//
//  Created by Andrzej Czarkowski on 04/01/2016.
//  Copyright © 2016 Bitmelter Ltd. All rights reserved.
//

import Foundation

open class ViewsHelpers {
    
    open class func IsiPad() -> Bool {
        return (UI_USER_INTERFACE_IDIOM() == .pad)
    }
    
    open class func EnsureCommentField(_ commentsView: UIView, textView: UITextView, fieldComment: EntryFormFieldComments?, commentsHeightConstraint: NSLayoutConstraint?) {
        if let comment = fieldComment {
            commentsView.isHidden = false
            textView.text = comment.value
            FormatTextView(textView, makeFirstResponder: false)
        } else {
            commentsView.isHidden = true
        }
        
        if let height = commentsHeightConstraint {
            if commentsView.isHidden {
                height.constant = 0.0
            } else {
                height.constant = 130.0
            }
        }
    }
    
    open class func HandleAttachments(_ entryField: Any?, attachment: EntryFormAttachment, attachmentsViewer: AttachmentsSelectorView?) -> Bool {
        var ret = false
        if let ef = entryField {
            var numberOfAttachments = 0
            if let f = MiscHelpers.CastEntryFormField(ef, Int.self) {
                ret = true
                f.addAttachment(attachment)
                numberOfAttachments = f.attachments.count
            } else if let f = MiscHelpers.CastEntryFormField(ef, Float.self) {
                ret = true
                f.addAttachment(attachment)
                numberOfAttachments = f.attachments.count
            } else if let f = MiscHelpers.CastEntryFormField(ef, Double.self) {
                ret = true
                f.addAttachment(attachment)
                numberOfAttachments = f.attachments.count
            } else if let f = MiscHelpers.CastEntryFormField(ef, String.self) {
                ret = true
                f.addAttachment(attachment)
                numberOfAttachments = f.attachments.count
            }
            
            if let aViewer = attachmentsViewer {
                aViewer.setNumberOfAttachments(numberOfAttachments)
            }
        }
        return ret
    }
    
    open class func FormatTextView(_ textView: UITextView, makeFirstResponder: Bool) {
        textView.returnKeyType = UIReturnKeyType.next
        // Would be nice to add this from fucking interface builder
        
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor(red:0.866, green:0.866, blue:0.866, alpha:1).cgColor
        
        textView.backgroundColor = UIColor(red:0.99, green:0.99, blue:0.99, alpha:1)
        
        // And this is fucking horrible
        
        textView.textContainerInset = UIEdgeInsets.init(top: 15, left: 10, bottom: 0, right: 0)
        
        if makeFirstResponder {
            textView.becomeFirstResponder()
        }
    }
    
    open class func GetDoneButton(_ selector: Selector, target: AnyObject?) -> UIBarButtonItem {
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.save, target: target, action: selector)
        return doneButton
    }

    
    open class func HandleFormField<T>(_ viewController: UIViewController, entryForm: EntryForm, entryFormBaseFieldType: EntryFormBaseFieldType<T>, doneEditing: EntryFormFieldDoneEditing?){
        if let ft = entryFormBaseFieldType.fieldType {
            var view: UIViewController? = .none
            if ft == .Textbox {
                let textBox = TextboxTypeFieldTypeViewController(nibName:"TextboxTypeFieldTypeView", bundle: nil)
                textBox.entryForm = entryForm
                textBox.doneEditing = EntryFormFieldDoneEditingWrapper(entryFormFieldDoneEditingDelegate: doneEditing)
                textBox.setEntryField(entryFormBaseFieldType)
                view = textBox
            } else if ft == .Checkbox || ft == .CheckboxWithOther || ft == .Radio || ft == .RadioWithOther {
                let radioCheckbox = RadioCheckboxTypeFieldTypeViewController(nibName:"RadioCheckboxTypeFieldTypeView", bundle: nil)
                radioCheckbox.entryForm = entryForm
                radioCheckbox.doneEditing = EntryFormFieldDoneEditingWrapper(entryFormFieldDoneEditingDelegate: doneEditing)
                radioCheckbox.setEntryField(entryFormBaseFieldType)
                view = radioCheckbox
            } else if ft == .Multiline {
                let multiLine = MultilineTypeFieldTypeViewController(nibName:"MultilineTypeFieldTypeView",bundle:nil)
                multiLine.entryForm = entryForm
                multiLine.doneEditing = EntryFormFieldDoneEditingWrapper(entryFormFieldDoneEditingDelegate: doneEditing)
                multiLine.setEntryField(entryFormBaseFieldType)
                view = multiLine
            } else if ft == .Date || ft == .Time || ft == .DateAndTime {
                let dateTime = DateTimeFieldTypeViewController(nibName:"DateTimeFieldTypeView", bundle: nil)
                dateTime.entryForm = entryForm
                dateTime.doneEditing = EntryFormFieldDoneEditingWrapper(entryFormFieldDoneEditingDelegate: doneEditing)
                dateTime.setEntryField(entryFormBaseFieldType)
                view = dateTime
            } else if ft == .Location {
                let location = LocationFieldTypeViewController(nibName: "LocationFieldTypeView", bundle: nil)
                location.entryForm = entryForm
                location.doneEditing = EntryFormFieldDoneEditingWrapper(entryFormFieldDoneEditingDelegate: doneEditing)
                location.setEntryField(entryFormBaseFieldType)
                view = location
            }
            if let v = view {
                DispatchQueue.main.async(execute: {
                    if let svc = viewController.splitViewController {
                        if IsiPad() {
                            svc.showDetailViewController(UINavigationController(rootViewController: v), sender: self)
                        } else {
                            svc.showDetailViewController(v, sender: self)
                        }
                    } else {
                        viewController.navigationController?.pushViewController(v, animated: true)
                    }
                })
            }
        }
    }
    
    open class func CreateAttachmentsPopup(_ entryFormAttachmentSpec: EntryFormAttachmentSpec,
        audioAction: @escaping (() -> Void),
        imagePhotoAction:@escaping (() -> Void),
        imageSavePhotoAction:@escaping (() -> Void),
        videoAction: @escaping (() -> Void),
        drawingAction: @escaping (() -> Void),
        savedVideoAction: @escaping (() -> Void)) -> UIAlertController? {
        if !entryFormAttachmentSpec.AllowsAttachments {
            return .none
        }
        
        let alert = UIAlertController(title: .none, message: .none, preferredStyle: UIAlertController.Style.actionSheet)
        
        if entryFormAttachmentSpec.AllowedAudio {
            let action = UIAlertAction(title: NSLocalizedString("Add Audio", comment: "Attachment Add Audio button"), style: UIAlertAction.Style.destructive, handler: { (alertAction) -> Void in
                audioAction()
            })
            alert.addAction(action)
        }
        
        if entryFormAttachmentSpec.AllowedImages {
            let actionPhoto = UIAlertAction(title: NSLocalizedString("Add Photo", comment: "Attachment Add Photo button"), style: UIAlertAction.Style.destructive, handler: { (alertAction) -> Void in
                imagePhotoAction()
            })
            alert.addAction(actionPhoto)
            
            let actionSavedPhoto = UIAlertAction(title: NSLocalizedString("Add Saved Photo", comment: "Attachment Add Saved Photo button"), style: UIAlertAction.Style.destructive, handler: { (alertAction) -> Void in
                imageSavePhotoAction()
            })
            alert.addAction(actionSavedPhoto)
        }
        
        if entryFormAttachmentSpec.AllowedVideo {
            let action = UIAlertAction(title: NSLocalizedString("Add Video", comment: "Attachment Add Video button"), style: UIAlertAction.Style.destructive, handler: { (alertAction) -> Void in
                videoAction()
            })
            alert.addAction(action)
        }
        
        if entryFormAttachmentSpec.AllowedSavedVideo {
            let action = UIAlertAction(title: NSLocalizedString("Add Saved Video", comment: "Attachment Add Saved Video button"), style: UIAlertAction.Style.destructive, handler: { (alertAction) -> Void in
                savedVideoAction()
            })
            alert.addAction(action)
        }
        
        if entryFormAttachmentSpec.AllowedEntryFormDrawingsSpec.Allowed {
            let action = UIAlertAction(title: NSLocalizedString("Add Drawing", comment: "Attachment Add Drawing button"), style: UIAlertAction.Style.destructive, handler: { (alertAction) -> Void in
                drawingAction()
            })
            alert.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Standard Cancel button"), style: UIAlertAction.Style.cancel, handler: .none)
        
        alert.addAction(cancelAction)

        return alert
    }
}
