//
//  DateTimeFieldTypeViewController.swift
//  ForensiDoc

import Foundation

class DateTimeFieldTypeViewController: BaseViewController, UITextViewDelegate {
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var commentField: UITextView!
    @IBOutlet var commentsView: UIView!
    @IBOutlet var commentsHeightConstraint: NSLayoutConstraint?
    
    var _entryField: Any?
    func setEntryField<T: EntryFormFieldContainer>(_ entryField: T) {
        _entryField = entryField
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let doneButton: UIBarButtonItem? = ViewsHelpers.GetDoneButton(#selector(DateTimeFieldTypeViewController.HandleEnteredDateAndReturn), target: self)
        
        if let ef = _entryField {
            if let f = MiscHelpers.CastEntryFormField(ef, Double.self) {
                self.checkIfCanAttachPhotos(f.attachmentsSpec, addAttachmentAction: EntryFormAttachmentAddAction(action: self.addAttachment), entryFormField: self._entryField, doneButton: doneButton, attachmentsHeightConstraint: self.attachmentsSelectorViewHeightConstraint,numberOfAttachments: f.attachments.count)
                self.title = f.title
                if let b = f as? DateTimeBaseEntryField<Double> {
                    if let date = b.getSelectedDate() {
                        self.datePicker.date = date
                    }
                    if let pickerMode = b.getDatePickerMode() {
                        self.datePicker.datePickerMode = pickerMode
                    }
                }
                ViewsHelpers.EnsureCommentField(self.commentsView, textView: self.commentField, fieldComment: f.fieldComments, commentsHeightConstraint: self.commentsHeightConstraint)
            }
        }
    }
    //MARK: fix2020
   
    func addAttachment(_ attachment: EntryFormAttachment, attachmentsViewer: AttachmentsSelectorView?) {
        //ViewsHelpers.HandleAttachments(_entryField, attachment: attachment, attachmentsViewer: attachmentsViewer)
        _ = ViewsHelpers.HandleAttachments(_entryField, attachment: attachment, attachmentsViewer: attachmentsViewer)
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
    
    func HandleEnteredDate() {
        if let ef = _entryField, let eForm = self.entryForm {
            if let f = MiscHelpers.CastEntryFormField(ef, Double.self) {
                if let b = f as? DateTimeBaseEntryField<Double> {
                    let timeInterval = self.datePicker.date.timeIntervalSince1970
                    b.addValue(timeInterval, title: "")
                    self.doneEditing?.EntryFormFieldDoneEditingDelegate?.handleEditedForm(eForm, entryFormField: f)
                }
            }
        }
    }
    
    func HandleEnteredDateAndReturn() {
        HandleEnteredDate()
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
