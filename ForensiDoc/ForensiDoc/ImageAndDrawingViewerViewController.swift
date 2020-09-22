//
//  ImageAndDrawingViewerViewController.swift
//  ForensiDoc

import Foundation
import UIKit
import AVFoundation

open class ImageAndDrawingViewerViewController: BaseViewController {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var customNavigationBar: UINavigationBar!
    
    open var ImageUrl: URL!
    open var ImageDrawingTitle: String!
    
    override open func viewDidLoad()
    {
        if let data = try? Data(contentsOf: self.ImageUrl)
        {
            imageView.image = UIImage(data: data)
        }
        
        self.customNavigationBar.topItem?.title = self.ImageDrawingTitle
        
        let doneBtn = UIBarButtonItem(title: NSLocalizedString("Done", comment: "Done button on attachments viewer"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(doneTapped(_:)))
        
        self.customNavigationBar.topItem?.rightBarButtonItem = doneBtn
    }
       
    func doneTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: .none)
    }
}
