//
//  AlertHelper.swift
//  ForensiDoc

import Foundation

open class AlertHelper {
    class open func DisplayAlert(_ viewController: UIViewController, title: String, messages: [String], callback: (() -> Void)?) {
        var c = callback
        if c == nil {
            c = { }
        }
        
        AlertHelper.displayDialog(viewController, title: title, messages: messages, callback: c, cancelCallback: nil, onDisplay: nil, buttonTitle: kOK, cancelButtonTitle: kCancel, addSpinner: false)
    }
    
    class open func DisplayProgress(_ viewController: UIViewController, title: String, messages: [String], cancelCallback: (() -> Void)?, onDisplay: ((_ alert: AnyObject) -> Void)?) {
        AlertHelper.displayDialog(viewController, title: title, messages: messages, callback: .none, cancelCallback: cancelCallback, onDisplay:onDisplay, buttonTitle: kCancel, addSpinner: true)
    }
    
    class open func DisplayConfirmationDialog(_ viewController: UIViewController, title: String, messages: [String], okCallback: @escaping (() -> Void), cancelCallback: (() -> Void)?) {
        var c = cancelCallback
        if c == nil {
            c = { }
        }
        AlertHelper.displayDialog(viewController, title: title, messages: messages, callback: okCallback, cancelCallback: c, onDisplay: nil, buttonTitle: kOK, addSpinner: false)
    }
    
    class open func InputDialog(_ viewController: UIViewController, title: String, message: [String], placeholder: String, okCallback: @escaping ((_ data: String?) -> Void), cancelCallback: (() -> Void)?) {
        AlertHelper.InputDialog(viewController, title: title, okButtonTitle: kOK, cancelButtonTitle: kCancel, message: message, placeholder: placeholder, okCallback: okCallback, cancelCallback: cancelCallback)
    }
    
    class open func InputDialog(_ viewController: UIViewController, title: String, okButtonTitle: String, cancelButtonTitle: String, message: [String], placeholder: String, okCallback: @escaping ((_ data: String?) -> Void), cancelCallback: (() -> Void)?) {
        let m = formatMessagesToString(message)
        let alert = UIAlertController(title: title, message: m, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: okButtonTitle, style: UIAlertActionStyle.default) { (alertAction: UIAlertAction) -> Void in
            if let textField = alert.textFields?.first {
                okCallback(textField.text)
            } else {
                okCallback(.none)
            }
            return
            })
        alert.addAction(UIAlertAction(title: cancelButtonTitle, style: UIAlertActionStyle.cancel){ (alertAction: UIAlertAction) -> Void in
            cancelCallback?()
            return
            })
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            if placeholder.characters.count > 0 {
                textField.placeholder = placeholder
            }
            textField.isSecureTextEntry = false
        })
        viewController.present(alert, animated: true, completion: nil)
    }
    
    class open func CloseDialog(_ dialog: AnyObject?, completion: (()->Void)?) {
        DispatchQueue.main.async(execute: {
            if let _: AnyClass = NSClassFromString("UIAlertController") {
                let alertController = dialog as? UIAlertController
                if let aC = alertController {
                    aC.dismiss(animated: true){
                        completion?()
                        return
                    }
                }
            }
        })
    }
    
    fileprivate class func formatMessagesToString(_ messages: [String]) -> String {
        var message:String = ""
        for m in messages {
            if message.characters.count > 0 {
                message += "\n"
            }
            message += m
        }
        return message
    }
    
    fileprivate class func displayDialog(_ viewController: UIViewController, title: String, messages: [String], callback: (() -> Void)?, cancelCallback: (() -> Void)?, onDisplay: ((_ alert: AnyObject) -> Void)?, buttonTitle: String, cancelButtonTitle: String, addSpinner: Bool){
        let message = formatMessagesToString(messages)
        
        DispatchQueue.main.async(execute: {
            var a: AnyObject? = nil
            if let _: AnyClass = NSClassFromString("UIAlertController") {
                let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
                if let okCallback = callback {
                    let ok = UIAlertAction(title: buttonTitle, style: UIAlertActionStyle.default) { (alertAction: UIAlertAction) -> Void in
                        okCallback()
                        return
                    }
                    alert.addAction(ok)
                }
                
                if let cCallback = cancelCallback {
                    let cancel = UIAlertAction(title: cancelButtonTitle, style: UIAlertActionStyle.cancel, handler: { (alertAction: UIAlertAction) -> Void in
                        cCallback()
                    })
                    alert.addAction(cancel)
                }
                
                if addSpinner {
                    let customVC = UIViewController()
                    
                    let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
                    spinner.startAnimating()
                    customVC.view.addSubview(spinner)
                    
                    customVC.view.addConstraint(NSLayoutConstraint(item: spinner, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: customVC.view, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0.0))
                    
                    customVC.view.addConstraint(NSLayoutConstraint(item: spinner, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: customVC.view, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0.0))
                    
                    alert.setValue(customVC, forKey: "contentViewController")
                    
                    /*
                    let spinner = UIActivityIndicatorView(frame: alert.view.bounds)
                    spinner.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
                    spinner.center = CGPointMake(90, alert.view.frame.size.height / 2)
                    spinner.color = UIColor.blackColor()
                    alert.view.addSubview(spinner)
                    spinner.userInteractionEnabled = false
                    spinner.startAnimating()
                    */
                }
                a = alert
                viewController.present(alert, animated: true, completion: nil)
            } else {
                //Fallback to UIAlertView
                /*
                 let alert = UIAlertView(title: title, message: message, cancelButtonTitle: nil, otherButtonTitles: [buttonTitle], onDismiss: { (alertView: UIAlertView!, buttonIndex: Int) -> Void in
                 callback?()
                 return
                 }, onCancel: nil)
                 */
                //TODO:Finish UIActivityIndicatorView
                /*
                 a = alert
                 alert.show()
                 */
            }
            if let d = onDisplay {
                if let alert: AnyObject = a {
                    d(alert)
                }
            }
        })
    }
    
    fileprivate class func displayDialog(_ viewController: UIViewController, title: String, messages: [String], callback: (() -> Void)?, cancelCallback: (() -> Void)?, onDisplay: ((_ alert: AnyObject) -> Void)?, buttonTitle: String, addSpinner: Bool) {
        AlertHelper.displayDialog(viewController, title: title, messages: messages, callback: callback, cancelCallback: cancelCallback, onDisplay: onDisplay, buttonTitle: buttonTitle, cancelButtonTitle: kCancel, addSpinner: addSpinner)
    }
}
