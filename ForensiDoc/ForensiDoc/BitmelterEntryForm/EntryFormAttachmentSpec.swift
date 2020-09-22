//
//  EntryFormAttachmentSpec.swift
//  BitmelterEntryForm

import Foundation

open class EntryFormDrawingsSpec: JSONConvertible {
    open var Allowed: Bool = false
    open var BackgroundImages: [EntryFormImageWithTitle] = [EntryFormImageWithTitle]()
    open var colorSettingsEnabled: Bool = true
    open var eraserEnabled: Bool = true
    open var undoEnabled: Bool = true
    open var resetEnabled: Bool = true
    
    public init(){}
    
    public init(spec: JSON, eventManager: EventManager?) {
        self.Allowed = spec["allowed"].boolValue
        if let backgroundImgs = spec["backgroundimages"].array {
            for backgroundImg in backgroundImgs {
                let title = backgroundImg["title"].stringValue
                let imgName = backgroundImg["img"].stringValue
                let formula = backgroundImg["formula"].stringValue
                
                if title.characters.count > 0 && imgName.characters.count > 0 {
                    let imgWithTitle = EntryFormImageWithTitle(title: title, imageName: imgName, formula: formula)
                    imgWithTitle.eventManager = eventManager
                    self.BackgroundImages.append(imgWithTitle)
                }
            }
        }
        self.colorSettingsEnabled = spec["drawing_settings"]["color_settings"].boolValue
        self.eraserEnabled = spec["drawing_settings"]["eraser"].boolValue
        self.undoEnabled = spec["drawing_settings"]["undo"].boolValue
        self.resetEnabled = spec["drawing_settings"]["reset"].boolValue
    }
    
    open func toReportJSON() -> JSON {
        return toJSON()
    }
    
    open func toJSON() -> JSON {
        return JSON(toDictionary())
    }
    
    open func toReportDictionary() -> [String : AnyObject] {
        return [String: AnyObject]()
    }
    
    open func toDictionary() -> [String : AnyObject] {
        var ret = [String : AnyObject]()
        ret["allowed"] = self.Allowed as AnyObject
        
        var backgroundImages = [[String: AnyObject]]()
        for backgroundImage in self.BackgroundImages {
            var d = [String: AnyObject]()
            
            d["title"] = backgroundImage.title as AnyObject
            d["img"] = backgroundImage.imageName as AnyObject
            d["formula"] = backgroundImage.formula as AnyObject
            
            backgroundImages.append(d)
        }
        
        ret["backgroundimages"] = backgroundImages as AnyObject
        
        var drawingSettings = [String: AnyObject]()
        drawingSettings["color_settings"] = self.colorSettingsEnabled as AnyObject
        drawingSettings["eraser"] = self.eraserEnabled as AnyObject
        drawingSettings["undo"] = self.undoEnabled as AnyObject
        drawingSettings["reset"] = self.resetEnabled as AnyObject
        
        ret["drawing_settings"] = drawingSettings as AnyObject
        
        return ret
    }
}

open class EntryFormAttachmentSpec: JSONConvertible {
    open var AllowedImages: Bool = false
    open var AllowedAudio: Bool = false
    open var AllowedVideo: Bool = false
    open var AllowedSavedVideo: Bool = false
    open var AllowedEntryFormDrawingsSpec: EntryFormDrawingsSpec
    
    public init(spec: JSON, eventManager: EventManager?) {
        self.AllowedImages = spec["images"].boolValue
        self.AllowedAudio = spec["audio"].boolValue
        self.AllowedVideo = spec["video"].boolValue
        self.AllowedSavedVideo = spec["saved_video"].boolValue
        self.AllowedEntryFormDrawingsSpec = EntryFormAttachmentSpec.LoadEntryFormDrawingsSpec(spec["drawings"], eventManager: eventManager)
    }
    
    public init() {
        self.AllowedEntryFormDrawingsSpec = EntryFormAttachmentSpec.LoadEntryFormDrawingsSpec(.none, eventManager: .none)
    }
    
    open var AllowsAttachments: Bool {
        get{
            return
                self.AllowedAudio ||
                self.AllowedImages ||
                self.AllowedVideo ||
                self.AllowedEntryFormDrawingsSpec.Allowed ||
                self.AllowedSavedVideo
        }
    }
    
    open func toJSON() -> JSON {
        return JSON(toDictionary())
    }
    
    open func toReportJSON() -> JSON {
        return toJSON()
    }
    
    open func toReportDictionary() -> [String : AnyObject] {
        return [String: AnyObject]()
    }
    
    open func toDictionary() -> [String : AnyObject] {
        var ret = [String : AnyObject]()
        ret["images"] = self.AllowedImages as AnyObject
        ret["audio"] = self.AllowedAudio as AnyObject
        ret["video"] = self.AllowedVideo as AnyObject
        ret["saved_video"] = self.AllowedSavedVideo as AnyObject
        ret["drawings"] = self.AllowedEntryFormDrawingsSpec.toDictionary() as AnyObject
        
        return ret
    }

    
    fileprivate class func LoadEntryFormDrawingsSpec(_ spec: JSON?, eventManager: EventManager?) -> EntryFormDrawingsSpec {
        if let s = spec {
            return EntryFormDrawingsSpec(spec: s, eventManager: eventManager)
        }
        
        return EntryFormDrawingsSpec()
    }
    
}
