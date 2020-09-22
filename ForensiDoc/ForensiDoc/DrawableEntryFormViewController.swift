//
//  DrawableEntryFormViewController.swift
//  ForensiDoc

import Foundation

//TODO:Allow picture annotation
//TODO:Store time when images taken
//TODO:Common settings then incorporated into report

//TODO:Settings based on spec of the report
//If one report show straight away settings of that report
//If more than one report display reports and then settings

//TODO:Remove Save button and save every time when you go back
//Report generation would check if report is valid

//TODO:Plus button to add attachments per report
//Drawings, Pics, Audio, Video



open class DrawableEntryFormViewController: DrawingViewController
{
    @IBOutlet var drawingToolbar: UIToolbar!
    @IBOutlet var customNavigationBar: UINavigationBar!
    
    var selectBackgroundImageBtn:UIBarButtonItem?
    var drawingViewTitle: String = ""
    var loadedOnlyOnce = false
    
    var _entryForm: EntryForm?
    var entryForm: EntryForm? {
        get{
            return _entryForm
        }
        set {
            _entryForm = newValue
        }
    }
    
    var _entryFormDrawable: EntryFormDrawable?
    var entryFormDrawable: EntryFormDrawable? {
        get {
            return _entryFormDrawable
        }
        set {
            _entryFormDrawable = newValue
        }
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        setupScreen()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        if let efd = _entryFormDrawable {
            self.selectBackgroundImageBtn?.isEnabled = efd.backgroundImages.count > 0
        }
        
        super.viewWillAppear(animated)
    }
    
    @IBAction func selectBackgroundImage(_ sender: AnyObject) {
        if let efd = _entryFormDrawable, efd.backgroundImages.count > 0 {
            let backgroundImgSelector = UIAlertController(title: .none, message: .none, preferredStyle: UIAlertControllerStyle.actionSheet)
            
            for backgroundImg in efd.backgroundImages {
                if backgroundImg.CanDisplay {
                    let action = UIAlertAction(title: backgroundImg.title, style: UIAlertActionStyle.destructive, handler: { (alertAction) -> Void in
                        
                        if let pathUrl = Bundle.main.url(forResource: backgroundImg.imageName, withExtension: .none) {
                            if let data = try? Data(contentsOf: pathUrl) {
                                if let img = UIImage(data: data) {
                                    self.mainImage.image = img
                                }
                            }
                        }
                    })
                    backgroundImgSelector.addAction(action)
                }
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: .none)
            
            backgroundImgSelector.addAction(cancelAction)
            
            if ViewsHelpers.IsiPad() {
                if let backgroundImg = self.selectBackgroundImageBtn {
                    backgroundImgSelector.popoverPresentationController?.barButtonItem = backgroundImg
                } else {
                    backgroundImgSelector.popoverPresentationController?.sourceView = self.view
                    backgroundImgSelector.popoverPresentationController?.sourceRect = self.view.frame
                }
            }
            self.present(backgroundImgSelector, animated: true, completion: .none)
        }
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let efd = _entryFormDrawable {
            if !self.drawingWrapper.hasDrawings() {
                efd.updateDrawingWrapper(self.drawingWrapper)
            }
        }
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let efd = self.entryFormDrawable {
            if let finalImage = self.getFinalImage() {
                efd.setFinalImage(finalImage)
            }
            efd.updateDrawHistory(self.drawingWrapper.getDrawHistory())
        }
    }
    
    func setupScreen() {
        var buttons = [UIBarButtonItem]()
        
        var lastGroupSelected = -1
        let btnFlexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        
        if let efd = self.entryFormDrawable {
            self.drawingViewTitle = efd.title
            if efd.colorSettingsEnabled {
                let btnBlackColor = UIBarButtonItem(image: UIImage(named: "Pencil-Black")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal), style: UIBarButtonItemStyle.plain, target: self, action: #selector(DrawingViewController.colorButtonPressed(_:)))
                btnBlackColor.tag = self.kBlackColorButton
                
                let btnGreyColor = UIBarButtonItem(image: UIImage(named: "Pencil-Grey")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal), style: UIBarButtonItemStyle.plain, target: self, action: #selector(DrawingViewController.colorButtonPressed(_:)))
                btnGreyColor.tag = self.kGreyColorButton
                
                
                let btnRedColor = UIBarButtonItem(image: UIImage(named: "Pencil-Red")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal), style: UIBarButtonItemStyle.plain, target: self, action: #selector(DrawingViewController.colorButtonPressed(_:)))
                btnRedColor.tag = self.kRedColorButton
                
                let btnBlueColor = UIBarButtonItem(image: UIImage(named: "Pencil-Blue")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal), style: UIBarButtonItemStyle.plain, target: self, action: #selector(DrawingViewController.colorButtonPressed(_:)))
                btnBlueColor.tag = kBlueColorButton
                
                buttons.append(btnBlackColor)
                buttons.append(btnGreyColor)
                buttons.append(btnRedColor)
                buttons.append(btnBlueColor)
                lastGroupSelected = efd.colorSettingsGroup
            }
            
            if efd.eraserEnabled {
                let btnEraser = UIBarButtonItem(image: UIImage(named: "Eraser")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal), style: UIBarButtonItemStyle.plain, target: self, action: #selector(DrawingViewController.eraseButtonPressed(_:)))
                if lastGroupSelected != efd.eraserGroup {
                    buttons.append(btnFlexibleSpace)
                }
                buttons.append(btnEraser)
                lastGroupSelected = efd.eraserGroup
            }
            
            if efd.undoEnabled {
                let btnRemoveLastDrawnElement = UIBarButtonItem(image: UIImage(named: "Step-Back")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal), style: UIBarButtonItemStyle.plain, target: self, action: #selector(DrawingViewController.removeLastDrawnElement(_:)))
                if lastGroupSelected != efd.undoGroup {
                    buttons.append(btnFlexibleSpace)
                }
                buttons.append(btnRemoveLastDrawnElement)
                lastGroupSelected = efd.undoGroup
            }
            
            if efd.backgroundImages.count > 0 {
                selectBackgroundImageBtn = UIBarButtonItem(image: UIImage(named: "Body-Templates")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal), style: UIBarButtonItemStyle.plain, target: self, action: #selector(DrawableEntryFormViewController.selectBackgroundImage(_:)))
                if lastGroupSelected != efd.backgroundImagesGroup {
                    buttons.append(btnFlexibleSpace)
                }
                buttons.append(selectBackgroundImageBtn!)
                lastGroupSelected = efd.backgroundImagesGroup
            }
            
            if efd.resetEnabled {
                let btnResetDrawing = UIBarButtonItem(image: UIImage(named: "Reset-Drawing")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal), style: UIBarButtonItemStyle.plain, target: self, action: #selector(DrawingViewController.resetButtonPressed(_:)))
                if lastGroupSelected != efd.resetGroup {
                    buttons.append(btnFlexibleSpace)
                }
                buttons.append(btnResetDrawing)
                lastGroupSelected = efd.resetGroup
            }
            
            if lastGroupSelected != efd.doneGroup {
                buttons.append(btnFlexibleSpace)
            }
            
            let btnDoneDrawing = UIBarButtonItem(title: NSLocalizedString("Done", comment: "Done Drawing"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(DrawingViewController.doneButtonPressed(_:)))
            
            self.customNavigationBar.topItem?.rightBarButtonItem = btnDoneDrawing
            
            self.drawingToolbar.setItems(buttons, animated: true)
        }
        
        let btnCancelDrawing = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: "Cancel Drawing"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(DrawingViewController.cancleButtonPressed(_:)))
        
        self.customNavigationBar.topItem?.leftBarButtonItem = btnCancelDrawing
        
        if self.drawingViewTitle.characters.count == 0 {
            self.customNavigationBar.topItem?.title = NSLocalizedString("Custom drawing", comment: "Title on drawing view when variable of EntryFormDrawable not set")
        } else {
            self.customNavigationBar.topItem?.title = self.drawingViewTitle
        }
    }
}
