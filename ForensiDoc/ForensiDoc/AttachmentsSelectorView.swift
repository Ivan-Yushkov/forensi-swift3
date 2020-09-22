//
//  AttachmentsSelectorView.swift
//  ForensiDoc

import UIKit

protocol AttachmentsSelectorViewDelegate: class {
    func addNewAttachmentTapped()
}

open class AttachmentsSelectorView: UIView {

    @IBOutlet var view: UIView!
    
    @IBOutlet var lblNumberOfAttachments: UILabel!
    var delegate: AttachmentsSelectorViewDelegate?

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        if let nibsView = Bundle.main.loadNibNamed("AttachmentsSelectorView", owner: self, options: nil) as? [UIView] {
            let nibRoot = nibsView[0]
            self.addSubview(nibRoot)
            nibRoot.frame = self.bounds
        }
    }
    
    @IBAction func addAttachmentsBtnTapped(_ sender: AnyObject) {
        self.delegate?.addNewAttachmentTapped()
    }
    
    open func setNumberOfAttachments(_ numberOfAttachments: Int) {
        self.lblNumberOfAttachments.text = "\(numberOfAttachments)"
    }
}
