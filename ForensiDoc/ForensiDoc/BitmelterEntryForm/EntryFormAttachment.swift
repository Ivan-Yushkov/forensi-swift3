//
//  EntryFormAttachment.swift
//  BitmelterEntryForm

import Foundation

public enum EntryFormAttachmentType : Int {
    case unknown = 0
    case image = 1
    case video = 2
    case audio = 3
    case drawing = 4
}

open class EntryFormAttachmentAddAction: NSObject {
    fileprivate var action: ((_ attachment: EntryFormAttachment, _ attachmentsViewer: AttachmentsSelectorView?) -> Void)
    
    public init(action: @escaping ((_ attachment: EntryFormAttachment, _ attachmentsViewer: AttachmentsSelectorView?) -> Void)) {
        self.action = action
    }
    
    open var AddAttachmentAction: ((_ attachment: EntryFormAttachment, _ attachmentsViewer: AttachmentsSelectorView?) -> Void) {
        get{
            return action
        }
    }
}


open class EntryFormAttachment: JSONConvertible {
    fileprivate var entryForm: EntryForm
    fileprivate var timeStamp: Double = 0
    open var AttachmentType: EntryFormAttachmentType
    open var SavedAsFileName: String = ""
    open var Name: String = ""
    
    public init(spec: JSON, entryForm: EntryForm) {
        self.entryForm = entryForm
        if let at = EntryFormAttachmentType(rawValue: spec["attachment_type"].intValue) {
            self.AttachmentType = at
        } else {
            self.AttachmentType = .unknown
        }
        self.SavedAsFileName = spec["saved_as_filename"].stringValue
        self.timeStamp = spec["timestamp"].doubleValue
        self.Name = spec["name"].stringValue
    }
    
    public init(attachmentType: EntryFormAttachmentType, entryForm: EntryForm) {
        self.entryForm = entryForm
        self.AttachmentType = attachmentType
        self.SavedAsFileName = self.makeFileName()
    }
    
    public init(attachmentType: EntryFormAttachmentType, image: UIImage, entryForm: EntryForm) {
        self.entryForm = entryForm
        self.AttachmentType = attachmentType
        self.SavedAsFileName = self.makeFileName()
        try? UIImageJPEGRepresentation(image,1.0)?.write(to: self.NSURLFile, options: [.atomic])
    }
    
    public init(image: UIImage, entryForm: EntryForm){
        self.entryForm = entryForm
        self.AttachmentType = .image
        self.SavedAsFileName = self.makeFileName()
        try? UIImageJPEGRepresentation(image,1.0)?.write(to: self.NSURLFile, options: [.atomic])
    }
    
    open var NSURLFile: URL {
        get {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            //TODO:This can fail as we unwrap explicitly
            let fileURL = documentsURL.URLByAppendingPathComponent(self.entryForm.SavedInFolder, isDirectory: true).URLByAppendingPathComponent(self.SavedAsFileName)
            return fileURL
        }
    }
    
    fileprivate func makeFileName() -> String {
        let format = DateFormatter()
        format.dateFormat="yyyy-MM-dd-HH-mm-ss"
        self.timeStamp = Date().timeIntervalSince1970

        if self.AttachmentType == .audio {
            let currentFileName = "recording-\(format.string(from: Date())).m4a"
            return currentFileName
        } else if self.AttachmentType == .drawing {
            let currentFileName = "drawing-\(format.string(from: Date())).jpeg"
            return currentFileName
        } else if self.AttachmentType == .image {
            let currentFileName = "image-\(format.string(from: Date())).jpeg"
            return currentFileName
        } else if self.AttachmentType == .video {
            let currentFileName = "video-\(format.string(from: Date())).m4v"
            return currentFileName
        }
        return "\(UUID().uuidString).efatt"
    }
    
    open func clear() {
        let defaultManager = FileManager.default
        let absoluteString = self.NSURLFile.absoluteString
            if defaultManager.fileExists(atPath: absoluteString) {
                do {
                    try defaultManager.removeItem(atPath: absoluteString)
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
    }
    
    open func ToBase64() -> String {
        //TODO:Add functionality to turn it into base64
        //let imgBase64 = ai.stringValue
        //if let data = NSData(base64EncodedString: imgBase64, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters) {
        //    if let i = UIImage(data: data) {
        //        f.addPicture(i)
        //    }
        //}

        return ""
    }
    
    open func toReportJSON() -> JSON {
        return toJSON()
    }
    
    open func toJSON() -> JSON {
        let json = JSON(toDictionary())
        
        return json
    }
    
    open func toReportDictionary() -> [String : AnyObject] {
        var ret = [String: AnyObject]()
        if let fileName = self.NSURLFile.lastPathComponent {
            ret["filename"] = fileName
        } else {
            ret["filename"] = "" as AnyObject
        }
        
        ret["name"] = self.Name as AnyObject
        
        ret["value"] = "" as AnyObject
        if self.AttachmentType == .image || self.AttachmentType == .drawing {
            if let data = try? Data(contentsOf: self.NSURLFile) {
                if let img = UIImage(data: data) {
                    let newImg = ImageUtilities.ImageWithImage(img, scaledToMaxWidth: ImageUtilities.DEFAULT_WIDTH, maxHeight: ImageUtilities.DEFAULT_HEIGHT)
                    if let imgData = UIImageJPEGRepresentation(newImg, 0.8) {
                        let base64 = imgData.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
                        ret["value"] = base64
                    }
                }
            } else {
                ret["value"] = "" as AnyObject
            }
        }
        
        var timeStampDic = [String: AnyObject]()
        timeStampDic["value"] = self.timeStamp as AnyObject
        timeStampDic["type"] = "datetime" as AnyObject
        
        ret["timestamp"] = timeStampDic as AnyObject
        
        return ret
    }
    
    open func toDictionary() -> [String : AnyObject] {
        var ret: [String: AnyObject] = [String: AnyObject]()
        ret["attachment_type"] = self.AttachmentType.rawValue as AnyObject
        ret["saved_as_filename"] = self.SavedAsFileName as AnyObject
        ret["timestamp"] = self.timeStamp as AnyObject
        ret["name"] = self.Name as AnyObject
        
        return ret
    }

}

extension EntryFormAttachment {
    public class func CreateForAudio(_ entryForm: EntryForm) -> EntryFormAttachment {
        let ret = EntryFormAttachment(attachmentType: EntryFormAttachmentType.audio, entryForm: entryForm)
        
        return ret
    }
    
    public class func CreateForVideo(_ entryForm: EntryForm) -> EntryFormAttachment {
        let ret = EntryFormAttachment(attachmentType: EntryFormAttachmentType.video, entryForm: entryForm)
        
        return ret
    }
    
    public class func CreateForDrawing(_ entryForm: EntryForm) -> EntryFormAttachment {
        let ret = EntryFormAttachment(attachmentType: EntryFormAttachmentType.drawing, entryForm: entryForm)
        
        return ret
    }
}
