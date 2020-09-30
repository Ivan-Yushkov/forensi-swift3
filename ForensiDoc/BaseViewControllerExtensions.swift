//
//  BaseViewControllerExtensions.swift
//  ForensiDoc

import Foundation

extension BaseViewController: UIImagePickerControllerDelegate, DrawingViewControllerDelegate {
    fileprivate struct AssociatedKeys {
        static var attachmentsSpec = "attachmentsSpec"
        static var imagePicker = "imagePicker"
        static var entryForm = "entryForm"
        static var rightBarButton = "rightBarButton"
        static var addAttachmentAction = "addAttachmentAction"
        static var doneEditing = "doneEditing"
        static var emptyDetailView = "emptyDetailView"
        static var entryFormField = "entryFormField"
        static var entryField = "entryField"
    }
    
    open override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if ViewsHelpers.IsiPad() {
            return [.landscapeLeft,.landscapeRight]
        }
        return [.portrait, .portraitUpsideDown]
    }
    
    open override var shouldAutorotate : Bool {
        return true
    }
    
    fileprivate var entryFormFieldWrapper: EntryFormFieldWrapper? {
        get {
            guard let ret = objc_getAssociatedObject(self, &AssociatedKeys.entryFormField) as? EntryFormFieldWrapper else {
                return .none
            }
            return ret
        }
        set(value){
            objc_setAssociatedObject(self,&AssociatedKeys.entryFormField,value,objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate var emptyDetailView: EmptyDetailViewController? {
        get {
            guard let ret = objc_getAssociatedObject(self, &AssociatedKeys.emptyDetailView) as? EmptyDetailViewController else {
                return .none
            }
            return ret
        }
        set(value){
            objc_setAssociatedObject(self,&AssociatedKeys.emptyDetailView,value,objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var doneEditing: EntryFormFieldDoneEditingWrapper? {
        get {
            guard let action = objc_getAssociatedObject(self, &AssociatedKeys.doneEditing) as? EntryFormFieldDoneEditingWrapper else {
                return .none
            }
            return action
        }
        set(value) {
            objc_setAssociatedObject(self,&AssociatedKeys.doneEditing,value,objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var addAttachmentAction: EntryFormAttachmentAddAction? {
        get {
            guard let action = objc_getAssociatedObject(self, &AssociatedKeys.addAttachmentAction) as? EntryFormAttachmentAddAction else {
                return .none
            }
            return action
        }
        set(value) {
            objc_setAssociatedObject(self,&AssociatedKeys.addAttachmentAction,value,objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func GetEmptyViewForDetailView() -> EmptyDetailViewController {
        if let empty = self.emptyDetailView {
            return empty
        }
        let emptyDetail: EmptyDetailViewController = EmptyDetailViewController(nibName:"EmptyDetailView", bundle:nil)
        self.emptyDetailView = emptyDetail
        return emptyDetail
    }
    
    public var entryForm: EntryForm? {
        get {
            guard let number = objc_getAssociatedObject(self, &AssociatedKeys.entryForm) as? EntryForm else {
                return .none
            }
            return number
        }
        
        set(value) {
            objc_setAssociatedObject(self,&AssociatedKeys.entryForm,value,objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    //this lets us check to see if the item is supposed to be displayed or not
    var imagePicker: UIImagePickerController? {
        get {
            guard let number = objc_getAssociatedObject(self, &AssociatedKeys.imagePicker) as? UIImagePickerController else {
                return .none
            }
            return number
        }
        
        set(value) {
            objc_setAssociatedObject(self,&AssociatedKeys.imagePicker,value,objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var attachmentsSpec: EntryFormAttachmentSpec? {
        get {
            guard let number = objc_getAssociatedObject(self, &AssociatedKeys.attachmentsSpec) as? EntryFormAttachmentSpec else {
                return .none
            }
            return number
        }
        
        set(value) {
            objc_setAssociatedObject(self,&AssociatedKeys.attachmentsSpec,value,objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func checkIfCanAttachPhotos(_ entryFormAttachmentSpec: EntryFormAttachmentSpec, addAttachmentAction: EntryFormAttachmentAddAction?, entryFormField: Any?, doneButton: UIBarButtonItem?, attachmentsHeightConstraint: NSLayoutConstraint?, numberOfAttachments: Int) {
        if entryFormAttachmentSpec.AllowsAttachments {
            self.attachmentsSpec = entryFormAttachmentSpec
            self.addAttachmentAction = addAttachmentAction
            self.entryFormFieldWrapper = EntryFormFieldWrapper(entryFormField: entryFormField)
        }
        if let d = doneButton {
            self.navigationItem.rightBarButtonItem = d
        }
        self.attachmentsSelectorView?.isHidden = !entryFormAttachmentSpec.AllowsAttachments
        self.attachmentsSelectorView?.setNumberOfAttachments(numberOfAttachments)
        if !entryFormAttachmentSpec.AllowsAttachments {
            attachmentsSelectorViewHeightConstraint?.constant = 0.0
        } else {
            attachmentsSelectorViewHeightConstraint?.constant = 45.0
        }
    }
    
    func addNewAttachmentTapped() {
        if let attachmentsSpec = self.attachmentsSpec {
            if let alert = ViewsHelpers.CreateAttachmentsPopup(attachmentsSpec,
                                                               audioAction: self.addAudio,
                                                               imagePhotoAction: self.imagePhotoAction,
                                                               imageSavePhotoAction: self.savedImagePhotoAction,
                                                               videoAction: self.addVideo,
                                                               drawingAction: self.addDrawing,
                                                               savedVideoAction: self.videoSavedVideoAction)
            {
                if ViewsHelpers.IsiPad() {
                    if let asv = self.attachmentsSelectorView {
                        self.view.endEditing(true)
                        alert.popoverPresentationController?.sourceView = asv.view
                        alert.popoverPresentationController?.sourceRect = self.view.frame
                    } else {
                        alert.popoverPresentationController?.sourceView = self.view
                        alert.popoverPresentationController?.sourceRect = self.view.frame
                    }
                }
                self.present(alert, animated: true, completion: .none)
            }
        }
    }
    
    public func addVideo() {
        if let _ = self.entryForm, let effWrapper = self.entryFormFieldWrapper, effWrapper.EntryFormField != nil {
            let videoRecordingForm: VideoRecordingViewController = VideoRecordingViewController(nibName:"VideoRecordingView", bundle:nil)
            videoRecordingForm.entryForm = entryForm
            videoRecordingForm.OnGeneratedVideo = { (generatedVideoAttachment) -> Void in
                if let eff = MiscHelpers.CastEntryFormField(effWrapper.EntryFormField!, String.self) {
                    eff.addAttachment(generatedVideoAttachment)
                } else if let eff = MiscHelpers.CastEntryFormField(effWrapper.EntryFormField!, Int.self) {
                    eff.addAttachment(generatedVideoAttachment)
                } else if let eff = MiscHelpers.CastEntryFormField(effWrapper.EntryFormField!, Float.self) {
                    eff.addAttachment(generatedVideoAttachment)
                } else if let eff = MiscHelpers.CastEntryFormField(effWrapper.EntryFormField!, Double.self) {
                    eff.addAttachment(generatedVideoAttachment)
                }
            }
            DispatchQueue.main.async(execute: {
                self.present(videoRecordingForm, animated: true, completion: .none)
            })
        } else if let ef = self.entryForm {
            let videoRecordingForm: VideoRecordingViewController = VideoRecordingViewController(nibName:"VideoRecordingView", bundle:nil)
            videoRecordingForm.entryForm = entryForm
            videoRecordingForm.OnGeneratedVideo = {(generatedVideoAttachment) -> Void in
                ef.addAttachment(generatedVideoAttachment)
            }
            DispatchQueue.main.async(execute: {
                self.present(videoRecordingForm, animated: true, completion: .none)
            })
        }
    }
    
    public func addAudio() {
        let audioRecordingForm: AudioRecordingViewController = AudioRecordingViewController(nibName:"AudioRecordingView", bundle:nil)
        audioRecordingForm.entryForm = entryForm
        
        DispatchQueue.main.async(execute: {
            self.present(audioRecordingForm, animated: true, completion: .none)
        })
    }
    
    public func addDrawing() {
        if let ef = self.entryForm, let effWrapper = self.entryFormFieldWrapper, effWrapper.EntryFormField != nil {
            //Here adding drawing to a field
            if let eff = MiscHelpers.CastEntryFormField(effWrapper.EntryFormField!, String.self) {
                self.initializeDrawing(ef, entryFormField: eff)
            } else if let eff = MiscHelpers.CastEntryFormField(effWrapper.EntryFormField!, Int.self) {
                self.initializeDrawing(ef, entryFormField: eff)
            } else if let eff = MiscHelpers.CastEntryFormField(effWrapper.EntryFormField!, Float.self) {
                self.initializeDrawing(ef, entryFormField: eff)
            } else if let eff = MiscHelpers.CastEntryFormField(effWrapper.EntryFormField!, Double.self) {
                self.initializeDrawing(ef, entryFormField: eff)
            }
        } else if let ef = self.entryForm {
            //Here adding drawing to the entry form itself
            let empty: Any? = .none
            let emptyFormField = MiscHelpers.CastEntryFormField(empty, Double.self)
            self.initializeDrawing(ef, entryFormField: emptyFormField)
        }
    }
    
    fileprivate func initializeDrawing<T: EntryFormFieldContainer>(_ entryForm: EntryForm, entryFormField: T?) {
        if let eFF = entryFormField {
            if eFF.attachmentsSpec.AllowedEntryFormDrawingsSpec.Allowed {
                var drawingSpec = eFF.attachmentsSpec.AllowedEntryFormDrawingsSpec.toJSON()
                drawingSpec["title"] = JSON(eFF.title)
                drawingSpec["type"] = "Drawing"
                let entryFormDrawable = EntryFormDrawable(jsonSpec: drawingSpec, eventManager: eFF.eventManager)
                self.startDrawing(entryForm, entryFormDrawable: entryFormDrawable)
            }
        } else if entryForm.AttachmentsSpec.AllowedEntryFormDrawingsSpec.Allowed {
            var drawingSpec = entryForm.AttachmentsSpec.AllowedEntryFormDrawingsSpec.toJSON()
            drawingSpec["title"] = JSON(NSLocalizedString("Drawing", comment: "Drawing title when adding drawing as attachment"))
            drawingSpec["type"] = "Drawing"
            let entryFormDrawable = EntryFormDrawable(jsonSpec: drawingSpec, eventManager: entryForm.EventsManager)
            self.startDrawing(entryForm, entryFormDrawable: entryFormDrawable)
        }
    }
    
    fileprivate func startDrawing(_ entryForm: EntryForm, entryFormDrawable: EntryFormDrawable) {
        let def : DrawableEntryFormViewController = DrawableEntryFormViewController(nibName:"DrawableEntryFormView", bundle: nil)
        
        def.entryForm = entryForm
        def.entryFormDrawable = entryFormDrawable
        def.delegate = self
        
        if let svc = self.splitViewController {
            def.modalPresentationStyle = .fullScreen
            svc.present(def, animated: true, completion: { () -> Void in })
        }
    }
    
    public func savedImagePhotoAction() {
        self.startTakeOrAddPhoto(.photoLibrary)
    }
    
    public func imagePhotoAction() {
        self.startTakeOrAddPhoto(.camera)
    }
    
    public func videoSavedVideoAction() {
        self.startTakeOrAddPhoto(.savedPhotosAlbum)
    }
    
    public func drawingDoneWithImage(_ image: UIImage?, name: String) {
        if let img = image {
            if let ef = self.entryForm {
                let attachment = EntryFormAttachment(attachmentType: EntryFormAttachmentType.drawing, image: img, entryForm: ef)
                attachment.Name = name
                if let eFFWrapper = self.entryFormFieldWrapper, eFFWrapper.EntryFormField != nil {
                    if let eff = MiscHelpers.CastEntryFormField(eFFWrapper.EntryFormField!, String.self) {
                        eff.attachments.append(attachment)
                    } else if let eff = MiscHelpers.CastEntryFormField(eFFWrapper.EntryFormField!, Int.self) {
                        eff.attachments.append(attachment)
                    } else if let eff = MiscHelpers.CastEntryFormField(eFFWrapper.EntryFormField!, Float.self) {
                        eff.attachments.append(attachment)
                    } else if let eff = MiscHelpers.CastEntryFormField(eFFWrapper.EntryFormField!, Double.self) {
                        eff.attachments.append(attachment)
                    }
                } else {
                    ef.addAttachment(attachment)
                }
            }
        }
    }
    
    fileprivate func startTakeOrAddPhoto(_ source: UIImagePickerControllerSourceType) {
        if UIImagePickerController.isSourceTypeAvailable(source) {
            if let imgPicker = self.imagePicker {
                presentImagePicker(imgPicker, source: source)
            } else {
                self.imagePicker =  UIImagePickerController()
                if let imgPicker = self.imagePicker {
                    presentImagePicker(imgPicker, source: source)
                }
            }
        }
    }
    
    fileprivate func presentImagePicker(_ imagePicker: UIImagePickerController, source: UIImagePickerControllerSourceType) {
        imagePicker.delegate = self
        imagePicker.sourceType = source
        if source == .savedPhotosAlbum {
            imagePicker.mediaTypes = [kUTTypeMovie as String]
        }
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let imgPicker = self.imagePicker {
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                HandleSaveImg(imgPicker, image: image)
            } else if let mediaType = info[UIImagePickerControllerMediaType] as? String {
                var closePickerWithError = false
                if mediaType == kUTTypeMovie as String || mediaType == kUTTypeVideo as String {
                    if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL {
                        HandleSavedVideo(imgPicker, videoUrl: videoUrl)
                    } else {
                        closePickerWithError = true
                    }
                } else {
                    closePickerWithError = true
                }
                if closePickerWithError {
                    AlertHelper.DisplayAlert(picker, title: NSLocalizedString("Error", comment: "Error dialog title"), messages: [NSLocalizedString("Unable to save video!", comment: "Error message when user is trying to save saved video but we cannot get either video type or url to video")], callback: {() -> Void in
                        picker.dismiss(animated: true, completion: .none)
                    })
                }
            }
        }
    }
    
    fileprivate func HandleSavedVideo(_ picker: UIImagePickerController, videoUrl: URL) {
        AlertHelper.InputDialog(picker, title: NSLocalizedString("Name", comment: "Drawing or attachment title message of dialog to ask for title"), okButtonTitle: kSave, cancelButtonTitle: kDiscard, message: [NSLocalizedString("Please enter name", comment: "Message on attachment title dialog")], placeholder: NSLocalizedString("Name", comment: "Attachment title placeholder on dialog"), okCallback: { (data) -> Void in
            if let name = data {
                if name.characters.count == 0 {
                    AlertHelper.DisplayAlert(picker, title: NSLocalizedString("Error", comment: "Error dialog title"), messages: [NSLocalizedString("Name is required!", comment: "Error message when user does not enter name for photo attachment")], callback: {() -> Void in
                        self.HandleSavedVideo(picker, videoUrl: videoUrl)
                    })
                } else {
                    if let _ = self.attachmentsSpec {
                        if let action = self.addAttachmentAction, let ef = self.entryForm {
                            let attachment = EntryFormAttachment.CreateForVideo(ef)
                            attachment.Name = name
                            //Copy from videoUrl to attachment.NSURLFile
                            do{
                                try FileManager.default.copyItem(at: videoUrl, to: attachment.NSURLFile)
                                action.AddAttachmentAction(attachment, self.attachmentsSelectorView)
                                picker.dismiss(animated: true, completion: .none)
                            }catch{
                                AlertHelper.DisplayAlert(picker, title: NSLocalizedString("Error", comment: "Error dialog title"), messages: [NSLocalizedString("There was an error saving video to app storage!", comment: "Error displayed when there is a problem while saving svaed video to local path form storage")], callback: {() -> Void in
                                    picker.dismiss(animated: true, completion: .none)
                                })
                            }
                        }
                    }
                }
            }}, cancelCallback: {()-> Void in
                picker.dismiss(animated: true, completion: nil)
        })
    }
    
    fileprivate func HandleSaveImg(_ picker: UIImagePickerController, image: UIImage) {
        AlertHelper.InputDialog(picker, title: NSLocalizedString("Name", comment: "Drawing or attachment title message of dialog to ask for title"), okButtonTitle: kSave, cancelButtonTitle: kDiscard, message: [NSLocalizedString("Please enter name", comment: "Message on attachment title dialog")], placeholder: NSLocalizedString("Name", comment: "Attachment title placeholder on dialog"), okCallback: { (data) -> Void in
            if let name = data {
                if name.characters.count == 0 {
                    AlertHelper.DisplayAlert(picker, title: NSLocalizedString("Error", comment: "Error dialog title"), messages: [NSLocalizedString("Name is required!", comment: "Error message when user does not enter name for photo attachment")], callback: {() -> Void in
                        self.HandleSaveImg(picker, image: image)
                    })
                } else {
                    picker.dismiss(animated: true, completion: {()-> Void in
                        if let _ = self.attachmentsSpec {
                            if let action = self.addAttachmentAction, let ef = self.entryForm {
                                let attachment = EntryFormAttachment(image: image, entryForm: ef)
                                attachment.Name = name
                                action.AddAttachmentAction(attachment, self.attachmentsSelectorView)
                            }
                        }
                    })
                }
            }}, cancelCallback: {()-> Void in
                picker.dismiss(animated: true, completion: nil)
        })
    }
}



