//
//  AttachmentsViewController.swift
//  ForensiDoc

import Foundation
import UIKit
import AVKit
import AVFoundation

open class AttachmentsViewerViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    fileprivate var _cellIdentifier = MiscHelpers.RandomStringWithLength(10)
    open var attachments: [EntryFormAttachment] = []
    fileprivate var _attachmentDeleted: ((EntryFormAttachment) -> Void)?
    
    @IBOutlet var attachmentsTable: UITableView!
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Attachments", comment: "Title of attachments viewer view")
        let nib = UINib(nibName: "AttachmentsViewerCellView", bundle: Bundle.main)
        attachmentsTable.register(nib, forCellReuseIdentifier: _cellIdentifier)
    }
    
    open var AttachmentDeleted: ((EntryFormAttachment) -> Void)? {
        get {
            return _attachmentDeleted
        }
        set(value) {
            _attachmentDeleted = value
        }
    }
    
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attachments.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let attachment = attachments[indexPath.row]
        
        var c: AttachmentsViewerCellView? = .none
        
        if let cDeque = tableView.dequeueReusableCell(withIdentifier: _cellIdentifier) as? AttachmentsViewerCellView {
            c = cDeque
        }
        
        c?.contentView.isUserInteractionEnabled = true
        
        if let ret = c {
            switch attachment.AttachmentType {
            case .audio:
                c?.setAsAudioWithName(attachment.Name)
                break
            case .drawing:
                c?.setAsDrawingWithName(attachment.Name)
                break
            case .image:
                c?.setAsImageWithName(attachment.Name)
                break
            case .video:
                c?.setAsVideoWithName(attachment.Name)
                break
            default:
                break
            }
            
            ret.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            
            return ret
        }
        
        return UITableViewCell()
    }
    
    open func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath){
        viewAttachmentForIndexPath(indexPath)
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        viewAttachmentForIndexPath(indexPath)
    }

    
    open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0;
    }
    
    open func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            let attachment = attachments[indexPath.row]
            if let idx = self.attachments.firstIndex(where: {$0.SavedAsFileName == attachment.SavedAsFileName}) {
                self.AttachmentDeleted?(attachment)
                self.attachments.remove(at: idx)
                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
                tableView.endUpdates()
            }
        }
    }
    
    func viewAttachmentForIndexPath(_ indexPath: IndexPath) {
        let attachment = attachments[indexPath.row]
        if attachment.AttachmentType == .audio {
            
            let player = AVPlayer(url: attachment.NSURLFile as URL)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                if let validPlayer = playerViewController.player {
                    validPlayer.play()
                }
            }
        } else if attachment.AttachmentType == .video
        {
            let player = AVPlayer(url: attachment.NSURLFile as URL)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                if let validPlayer = playerViewController.player {
                    validPlayer.play()
                }
            }
        } else if attachment.AttachmentType == .drawing || attachment.AttachmentType == .image {
            let imageAndDrawingViewController: ImageAndDrawingViewerViewController = ImageAndDrawingViewerViewController(nibName:"ImageAndDrawingViewerView", bundle:nil)
            imageAndDrawingViewController.ImageUrl = attachment.NSURLFile
            imageAndDrawingViewController.ImageDrawingTitle = attachment.Name
            
            DispatchQueue.main.async(execute: {
                self.present(imageAndDrawingViewController, animated: true, completion: .none)
            })

        }
    }

}
