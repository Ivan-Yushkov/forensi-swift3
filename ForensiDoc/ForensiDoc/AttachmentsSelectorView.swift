//
//  AttachmentsSelectorView.swift
//  ForensiDoc

import UIKit

protocol AttachmentsSelectorViewDelegate: class {
    func addNewAttachmentTapped()
}

open class AttachmentsSelectorView: UIView, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var telephoneTextField: UITextField!
    @IBOutlet weak var insuranceTextField: UITextField!
    
    @IBOutlet var view: UIView!
    
    @IBOutlet var lblNumberOfAttachments: UILabel!
    var delegate: AttachmentsSelectorViewDelegate?

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    
       

        if let nibsView = Bundle.main.loadNibNamed("AttachmentsSelectorView", owner: self, options: nil) as? [UIView] {
            let nibRoot = nibsView[0]
            self.addSubview(nibRoot)
            nibRoot.frame = self.bounds
            if UserDefaults.standard.bool(forKey: "isTextfieldNeed") {
                setupTextFields() 
                UserDefaults.standard.set(false, forKey: "isTextfieldNeed")
            }
        }
        
       
       
    }
    
    
    @IBAction func addAttachmentsBtnTapped(_ sender: AnyObject) {
        self.delegate?.addNewAttachmentTapped()
    }
    
    open func setNumberOfAttachments(_ numberOfAttachments: Int) {
        self.lblNumberOfAttachments.text = "\(numberOfAttachments)"
    }
    
    private func setupTextFields() {
        nameTextField.isHidden = false
        nameTextField.delegate = self
        addressTextField.isHidden = false
        addressTextField.delegate = self
        emailTextField.isHidden = false
        emailTextField.delegate = self
        telephoneTextField.isHidden = false
        telephoneTextField.delegate = self
        insuranceTextField.isHidden = false
        insuranceTextField.delegate = self
    }
    
    public func textFieldDidChangeSelection(_ textField: UITextField) {
        switch textField.tag {
        case 0:
            UserDefaults.standard.set(textField.text, forKey: "name")
        case 1:
            UserDefaults.standard.set(textField.text, forKey: "address")
        case 2:
            UserDefaults.standard.set(textField.text, forKey: "email")
        case 3:
            UserDefaults.standard.set(textField.text, forKey: "telephone")
        case 4:
            UserDefaults.standard.set(textField.text, forKey: "insurance")
        default:
            break
        }
    }


    
}
