//
//  EntryFormDrawable.swift
//  BitmelterEntryForm

import Foundation

open class EntryFormDrawable: JSONConvertible, Validable {
    fileprivate var drawHistory : [DrawnElement] = [DrawnElement]()
    fileprivate var _title: String = ""
    fileprivate var _id: String = ""
    fileprivate var _required: Bool = false
    fileprivate var _finalImageBase64: String = ""
    open var colorSettingsEnabled: Bool = true
    open var eraserEnabled: Bool = true
    open var undoEnabled: Bool = true
    open var resetEnabled: Bool = true
    open let colorSettingsGroup = 1
    open let eraserGroup = 2
    open let undoGroup = 2
    open let backgroundImagesGroup = 3
    open let resetGroup = 4
    open let doneGroup = 4
    open var backgroundImages: [EntryFormImageWithTitle] = [EntryFormImageWithTitle]()
    
    public init(jsonSpec: JSON, eventManager: EventManager?) {
        _title = jsonSpec["title"].stringValue
        _id = jsonSpec["id"].stringValue
        _required = jsonSpec["required"].boolValue
        _finalImageBase64 = jsonSpec["final_image_base64"].stringValue
        if let drawnElements = jsonSpec["drawnElements"].array {
            for drawnElement in drawnElements {
                let kind = drawnElement["kind"].stringValue
                if kind == "DrawShape" {
                    let ds = DrawShape(jsonSpec: drawnElement)
                    drawHistory.append(ds)
                } else if kind == "FreeFormShape" {
                    let ffs = FreeFormShape(jsonSpec: drawnElement)
                    drawHistory.append(ffs)
                } else if kind == "ArrowShape" {
                    let arS = ArrowShape(jsonSpec: drawnElement)
                    drawHistory.append(arS)
                }
            }
        }
        if let backgroundImgs = jsonSpec["backgroundimages"].array {
            for backgroundImg in backgroundImgs {
                let title = backgroundImg["title"].stringValue
                let imgName = backgroundImg["img"].stringValue
                let formula = backgroundImg["formula"].stringValue
                
                if title.characters.count > 0 && imgName.characters.count > 0 {
                    let imgWithTitle = EntryFormImageWithTitle(title: title, imageName: imgName, formula: formula)
                    imgWithTitle.eventManager = eventManager
                    backgroundImages.append(imgWithTitle)
                }
            }
        }
        self.colorSettingsEnabled = jsonSpec["drawing_settings"]["color_settings"].boolValue
        self.eraserEnabled = jsonSpec["drawing_settings"]["eraser"].boolValue
        self.undoEnabled = jsonSpec["drawing_settings"]["undo"].boolValue
        self.resetEnabled = jsonSpec["drawing_settings"]["reset"].boolValue
    }
    
    open var title: String {
        get {
            return _title
        }
    }
    
    open var id: String {
        get {
            return _id
        }
    }
    
    open var required: Bool {
        get {
            return _required
        }
    }
    
    open func setFinalImage(_ image: UIImage) {
        if let imageData = UIImageJPEGRepresentation(image, 1.0) {
            self._finalImageBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
        }
    }

    open func isValidObject() -> Bool {
        return true
    }
    
    open func toReportJSON() -> JSON {
        return toJSON()
    }
    
    open func toJSON() -> JSON {
        let json: JSON = JSON(toDictionary())
        return json
    }
    
    open func toReportDictionary() -> [String : AnyObject] {
        var ret = [String: AnyObject]()
        
        var valueDictionary = [String: AnyObject]()
        var values = [AnyObject]()
        
        var value = [String: AnyObject]()
        
        var timestamp = [String: AnyObject]()
        timestamp["type"] = "datetime" as AnyObject
        timestamp["value"] = 0 as AnyObject //TODO:Add timestamp of when drawing last edited
        
        value["timestamp"] = timestamp as AnyObject
        value["name"] = self.title as AnyObject
        value["value"] = self._finalImageBase64 as AnyObject
        value["value_number"] = 1 as AnyObject //Always 1 as it is individual drawing
        value["filename"] = "drawing-123213-234.jpeg" as AnyObject //TODO:This needs to be added as it is not stored as image
        
        values.append(value as AnyObject)
        
        valueDictionary["value"] = values as AnyObject
        
        ret[self.id] = valueDictionary as AnyObject
        
        return ret
    }
    
    open func toDictionary() -> [String : AnyObject] {
        var ret = [String: AnyObject]()
        
        ret["id"] = self.id as AnyObject
        ret["title"] = self.title as AnyObject
        ret["required"] = self.required as AnyObject
        ret["type"] = "Drawing" as AnyObject
        ret["final_image_base64"] = self._finalImageBase64 as AnyObject
        
        var drawnElements = [AnyObject]()
        
        for drawnElement in self.drawHistory {
            drawnElements.append(drawnElement.toDictionary() as AnyObject)
        }
        
        ret["drawnElements"] = drawnElements as AnyObject
        
        var drawingSettings = [String: AnyObject]()
        drawingSettings["color_settings"] = self.colorSettingsEnabled as AnyObject
        drawingSettings["eraser"] = self.eraserEnabled as AnyObject
        drawingSettings["undo"] = self.undoEnabled as AnyObject
        drawingSettings["reset"] = self.resetEnabled as AnyObject

        
        ret["drawing_settings"] = drawingSettings as AnyObject
        
        return ret
    }
    
    open func updateDrawHistory(_ drawnElements: [DrawnElement]) {
        self.drawHistory.removeAll(keepingCapacity: true)
        for drawnElement in drawnElements {
            self.drawHistory.append(drawnElement)
        }
    }
    
    open func updateDrawingWrapper(_ drawingWrapper: DrawingWrapper) {
        drawingWrapper.updateFromDrawHistory(drawHistory)
    }

}
