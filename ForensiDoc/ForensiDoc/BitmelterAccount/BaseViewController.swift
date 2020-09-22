//
//  BaseViewController.swift
//  ForensiDoc

import UIKit
import AVFoundation

open class BaseViewController : UIViewController, UINavigationControllerDelegate, AttachmentsSelectorViewDelegate {
    fileprivate var startedFromBackground: Bool = false
    
    @IBOutlet var attachmentsSelectorView: AttachmentsSelectorView?
    @IBOutlet var attachmentsSelectorViewHeightConstraint: NSLayoutConstraint?
    
    override public init(nibName: String?, bundle: Bundle?) {
        var newNibName = nibName
        if let bundleToUse = bundle != nil ? bundle : Bundle.main {
            if (UI_USER_INTERFACE_IDIOM() == .pad) {
                newNibName = (nibName)! + "_iPad"
            }
            
            if let nibLocation = bundleToUse.path(forResource: newNibName, ofType: "nib") {
                if !FileManager.default.fileExists(atPath: nibLocation) {
                    newNibName = nibName
                }
            } else {
                newNibName = nibName
            }
        }
        super.init(nibName: newNibName, bundle: bundle)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var viewType: ViewType {
        get {
            return .baseView
        }
    }
    
    open func HandlesDetailViewController() -> Bool {
        return false
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if let svc = self.splitViewController {
            svc.preferredDisplayMode = .allVisible
        }
        
        self.edgesForExtendedLayout = UIRectEdge()
        
        self.navigationController?.navigationBar.backgroundColor = UIColor(red:0.971, green:0.971, blue:0.971, alpha:1)
        if let asv = self.attachmentsSelectorView {
            asv.delegate = self
        }
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    open func didBecomeActive() {
        if self.startedFromBackground {
            let dataHelper = DataManager.sharedInstance.helperData()
            if dataHelper.hasAccountActivationCode() {
                if self.viewType != .passcodeView && self.viewType != .activateAccountView {
                    let activateAccountView: ActivateAccountViewController? = nil
                    self.navigateToView(activateAccountView)
                }
            } else if dataHelper.hasResetPasswordCode() {
                if self.viewType != .passcodeView && self.viewType != .resetPasswordView {
                    let resetPasswordView: PasswordResetViewController? = nil
                    self.navigateToView(resetPasswordView)
                }
            }
            self.startedFromBackground = false
        }
    }
    
    open func setStartedFromBackground() {
        self.startedFromBackground = true
    }
    
    open func navigateToView<T: UIViewController>(_ type: T?){
        
        let name: String = NSStringFromClass(T.self)
        let range = name.range(of: ".", options: .backwards)
        var viewName:String?
        if let range = range {
            viewName = name.substring(from: range.upperBound)
        } else {
            viewName = name
        }
        
        let controllerRange = viewName?.range(of: "Controller", options: .backwards)
        if let controllerRange = controllerRange {
            viewName = viewName?.substring(to: controllerRange.lowerBound)
        }
        
        let newView = T(nibName: viewName, bundle: nil)
        DispatchQueue.main.async(execute: {
            self.navigationController?.pushViewController(newView, animated: true)
            return
        })
    }
    
    func goBack() {
        DispatchQueue.main.async(execute: {
            self.navigationController?.popViewController(animated: true)
            return
        })
    }
    
    func processBaseResponse<T: BaseResponseable>(_ response: Result<T>, successfullCallback: (_ value: T) -> ()){
        switch (response) {
        case let .error(error):
            if error.code != NSURLErrorCancelled {
                self.displayErrorAlert(error)
            }
        case let .value(b):
            let baseResponse = b.value
            if baseResponse.error {
                self.displayErrorAlert(baseResponse)
            } else {
                successfullCallback(baseResponse)
            }
        }
    }
    
    func displayConfirmationAlert(_ message: String){
        displayAlert(kInfoTitle, messages: [message], callback: nil)
    }
    
    func displayConfirmationAlert(_ message: String, callback: EmptyOptionalClosure){
        displayAlert(kInfoTitle, messages: [message], callback: callback)
    }
    
    func displayErrorAlert(_ baseResponse: BaseResponseable){
        displayAlert(kErrorTitle, messages: [baseResponse.message], callback: nil)
    }
    
    func displayErrorAlert(_ error: NSError?){
        if let e = error {
            displayAlert(kErrorTitle, messages: [e.description], callback: nil)
        } else {
            displayAlert(kErrorTitle, messages: [kUnknownErrorHasOccurred], callback: nil)
        }
    }
    
    func displayErrorAlert(_ messages: [String], callback: EmptyOptionalClosure){
        displayAlert(kErrorTitle, messages: messages, callback: callback)
    }
    
    func displayErrorAlert(_ title: String, messages: [String]){
        displayAlert(title, messages: messages, callback: nil)
    }
    
    func displayAlert(_ title: String, messages: [String], callback: EmptyOptionalClosure){
        AlertHelper.DisplayAlert(self, title: title, messages: messages, callback: callback)
    }
    
    func goToLoginView(){
        //TODO:
        /*
        let appDelegate = self.getAppDelegate()
        appDelegate.switchToWelcomeNavigationController(true)
        */
    }
}
