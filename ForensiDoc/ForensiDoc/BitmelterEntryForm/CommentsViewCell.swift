//
//  CommentsViewCell.swift
//  ForensiDoc

import Foundation

public protocol CommentsFieldHasChangedDelegate {
    func commentsHaveChnaged(_ newComments: String)
}

open class CommentsViewCell: UITableViewCell, UITextViewDelegate {
    @IBOutlet var commentsTextView: UITextView!
    open var delegate: CommentsFieldHasChangedDelegate? = .none
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        self.commentsTextView.layer.borderWidth = 1.0
        self.commentsTextView.layer.borderColor = UIColor(red:0.866, green:0.866, blue:0.866, alpha:1).cgColor
        
        self.commentsTextView.backgroundColor = UIColor(red:0.99, green:0.99, blue:0.99, alpha:1)
        
        // And this is fucking horrible
        
        self.commentsTextView.textContainerInset = UIEdgeInsets.init(top: 15, left: 10, bottom: 0, right: 0)
    }
    
    open func textViewDidChange(_ textView: UITextView) {
        self.delegate?.commentsHaveChnaged(textView.text)
    }
}
