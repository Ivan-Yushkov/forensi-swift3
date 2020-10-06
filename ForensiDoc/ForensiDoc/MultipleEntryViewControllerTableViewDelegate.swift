//
//  MultipleEntryViewControllerTableViewDelegate.swift
//  ForensiDoc
//
//  Created by Andrzej Czarkowski on 31/01/2016.
//  Copyright © 2016 Bitmelter Ltd. All rights reserved.
//

import Foundation


extension MultipleEntryViewController: UITableViewDelegate {
    internal func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath){
        handleMultipleEntryData(indexPath)
    }
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        handleMultipleEntryData(indexPath)
    }
    
    func handleMultipleEntryData(_ indexPath: IndexPath) {
        if let ef = self._entryField {
            let field = ef.fields[indexPath.row]
            if let f = MiscHelpers.CastEntryFormField(field, String.self) {
                HandleCell(f)
            } else if let f = MiscHelpers.CastEntryFormField(field, Int.self) {
                HandleCell(f)
            } else if let f = MiscHelpers.CastEntryFormField(field, Float.self) {
                HandleCell(f)
            } else if let f = MiscHelpers.CastEntryFormField(field, Double.self) {
                HandleCell(f)
            }
        }
    }
    
    internal func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    internal func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            if let ef = self._entryField {
                var deleted = false
                let field = ef.fields[indexPath.row]
                if let f = MiscHelpers.CastEntryFormField(field, String.self) {
                    deleted = HandleDeletion(f)
                } else if let f = MiscHelpers.CastEntryFormField(field, Int.self) {
                    deleted = HandleDeletion(f)
                } else if let f = MiscHelpers.CastEntryFormField(field, Float.self) {
                    deleted = HandleDeletion(f)
                } else if let f = MiscHelpers.CastEntryFormField(field, Double.self) {
                    deleted = HandleDeletion(f)
                }
                
                if deleted {
                    tableView.beginUpdates()
                    tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
                    tableView.endUpdates()
                } else {
                    //TODO:Popup error message
                }
            }
        }
    }
    
    func HandleDeletion<T>(_ entryFormBaseFieldType: EntryFormBaseFieldType<T>) -> Bool{
        if let ef = self._entryField {
            return ef.deleteEntryForm(entryFormBaseFieldType)
        }
        return false
    }
    
    func HandleCell<T>(_ entryFormBaseFieldType: EntryFormBaseFieldType<T>){
        if entryFormBaseFieldType.attachments.count > 0 {
            let attachmentsViewController = AttachmentsViewerViewController(nibName:"AttachmentsViewerView", bundle: nil)
            attachmentsViewController.attachments = entryFormBaseFieldType.attachments
            attachmentsViewController.AttachmentDeleted = {(deletedAttachment) -> Void in
                entryFormBaseFieldType.deleteAttachment(deletedAttachment)
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
    }
}
