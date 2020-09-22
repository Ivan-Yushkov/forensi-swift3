//
//  AttachmentsViewerCellView.swift
//  ForensiDoc

import Foundation

open class AttachmentsViewerCellView: UITableViewCell {
    @IBOutlet var imgAttachmentType: UIImageView!
    @IBOutlet var lblAttachmentName: UILabel!
    
    func setAsAudioWithName(_ name: String) {
        lblAttachmentName.text = name
        imgAttachmentType.image = UIImage(named: "AttTypeAudio")
    }
    
    func setAsImageWithName(_ name: String) {
        lblAttachmentName.text = name
        imgAttachmentType.image = UIImage(named: "AttTypeImage")
    }
    
    func setAsDrawingWithName(_ name: String) {
        lblAttachmentName.text = name
        imgAttachmentType.image = UIImage(named: "AttTypeDrawing")
    }
    
    func setAsVideoWithName(_ name: String) {
        lblAttachmentName.text = name
        imgAttachmentType.image = UIImage(named: "AttTypeVideo")
    }
}
