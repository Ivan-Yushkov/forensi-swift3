//
//  DrawingShapes.swift
//  TestDrawing

import Foundation
import UIKit

open class DrawShape : DrawnElement {
    var _points = Array<CGPoint>();
    open var points : Array<CGPoint> {
        get {
            return _points;
        }
    }
    
    let _elementType: DrawnElementType
    open var elementType : DrawnElementType {
        get{
            return _elementType
        }
    }
    
    let _brush : CGFloat;
    open var brush: CGFloat {
        get{
            return _brush;
        }
    }
    
    let _opacity : CGFloat;
    open var opacity: CGFloat {
        get{
            return _opacity;
        }
    }
    
    let _red: CGFloat;
    open var red: CGFloat {
        get{
            return _red;
        }
    }
    
    let _green: CGFloat;
    open var green: CGFloat {
        get{
            return _green;
        }
    }
    
    let _blue: CGFloat;
    open var blue: CGFloat {
        get{
            return _blue;
        }
    }
    
    let _index: Int
    open var index: Int {
        get{
            return _index;
        }
    }
    
    var _deleted: Bool
    open var deleted: Bool {
        get{
            return _deleted
        }
    }
    
    init(jsonSpec: JSON) {
        if let pts = jsonSpec["points"].array {
            for point in pts {
                let x = CGFloat(point["x"].floatValue)
                let y = CGFloat(point["y"].floatValue)
                let cgPt = CGPoint(x: x, y: y)
                _points.append(cgPt)
            }
        }
        
        if let det = DrawnElementType(rawValue: jsonSpec["element_type"].intValue) {
            _elementType = det
        } else {
            _elementType = DrawnElementType.nothing
        }
        
        _brush = CGFloat(jsonSpec["brush"].floatValue)
        _opacity = CGFloat(jsonSpec["opacity"].floatValue)
        _red = CGFloat(jsonSpec["red"].floatValue)
        _green = CGFloat(jsonSpec["green"].floatValue)
        _blue = CGFloat(jsonSpec["blue"].floatValue)
        _index = jsonSpec["index"].intValue
        _deleted = jsonSpec["deleted"].boolValue
    }
    
    init(points : Array<CGPoint>, brush: CGFloat, opacity: CGFloat, red: CGFloat, green: CGFloat, blue: CGFloat, index: Int){
        _points = points;
        _brush = brush;
        _opacity = opacity;
        _red = red;
        _green = green;
        _blue = blue;
        _index = index;
        _deleted = false
        _elementType = DrawnElementType.nothing
    }
    
    init(drawnElement: DrawnElement){
        _brush = drawnElement.brush
        _opacity = drawnElement.opacity
        _red = drawnElement.red
        _green = drawnElement.green
        _blue = drawnElement.blue
        _index = drawnElement.index
        _deleted = false
        _elementType = drawnElement.elementType
        for point in drawnElement.points {
            self._points.append(point)
        }
    }
    
    open func markAsDeleted() {
        _deleted = true
    }
    
    open func draw(_ imageView: UIImageView) {
        if self.elementType == DrawnElementType.freeForm{
            if self is FreeFormShape {
                let freeFormShape = self as! FreeFormShape
                freeFormShape.draw(imageView)
            }
        }
    }
    
    open func kind() -> String {
        return NSStringFromClass(type(of: self)).components(separatedBy: ".").last!
    }
    
    open func touched(_ point: CGPoint, distance: CGFloat) -> Bool {
        var t: Bool = false
        for p  in _points {
            let xDist = (p.x - point.x)
            let yDist = (p.y - point.y)
            let d = sqrt((xDist * xDist) + (yDist * yDist))
            
            if d < distance {
                t = true
                break
            }
        }
        return t
    }
    
    open func equals(_ otherDrawnElement: DrawnElement) -> Bool {
        if self.points.count != otherDrawnElement.points.count {
            return false
        }
        
        var lArray = Array<CGPoint>(self.points)
        var rArray = Array<CGPoint>(otherDrawnElement.points)
        lArray.sort { (lP: CGPoint, rP: CGPoint) -> Bool in
            return
                lP.x == rP.x &&
                    lP.y == rP.y
        }
        
        rArray.sort { (lP: CGPoint, rP: CGPoint) -> Bool in
            return
                lP.x == rP.x &&
                    lP.y == rP.y
        }
        
        for (index, element) in lArray.enumerated() {
            let r = rArray[index]
            if element != r {
                return false
            }
        }
        
        let ret =
            self.elementType == otherDrawnElement.elementType &&
            self.brush == otherDrawnElement.brush &&
            self.opacity == otherDrawnElement.opacity &&
            self.red == otherDrawnElement.red &&
            self.green == otherDrawnElement.green &&
            self.blue == otherDrawnElement.blue &&
            self.index == otherDrawnElement.index &&
            self.deleted == otherDrawnElement.deleted
        
        return ret
    }
    
    open func equalsOpositeOfOwnDeleted(_ otherDrawnElement: DrawnElement) -> Bool {
        return isEqualOtherDrawnElement(self, rhs: otherDrawnElement, opositeDeleted: true)
    }
    
    open var debugDescription: String {
        get{
            return "_brush = \(_brush) _opacity = \(_opacity) _red = \(_red) _green = \(_green) _blue = \(_blue) _index = \(_index) _elementType = \(_elementType)"
        }
    }
    
    open func toReportJSON() -> JSON {
        return toJSON()
    }
    
    open func toJSON() -> JSON {
        let json: JSON = JSON(toDictionary())
        return json
    }
    
    open func toReportDictionary() -> [String : AnyObject] {
        return [String: AnyObject]()
    }
    
    open func toDictionary() -> [String : AnyObject] {
        var ret = [String: AnyObject]()
        
        var pts = [AnyObject]()
        for pt in self.points {
            var cgPoint = [String: AnyObject]()
            cgPoint["x"] = pt.x as AnyObject
            cgPoint["y"] = pt.y as AnyObject
            pts.append(cgPoint as AnyObject)
        }
        
        ret["points"] = pts as AnyObject
        ret["element_type"] = self.elementType.rawValue as AnyObject
        ret["brush"] = self.brush as AnyObject
        ret["opacity"] = self.opacity as AnyObject
        ret["red"] = self.red as AnyObject
        ret["green"] = self.green as AnyObject
        ret["blue"] = self.blue as AnyObject
        ret["index"] = self.index as AnyObject
        ret["deleted"] = self.deleted as AnyObject
        
        let k = self.kind()
        
        ret["kind"] = k as AnyObject
        
        return ret
    }

}

open class FreeFormShape : DrawShape {
    override open var elementType : DrawnElementType {
        get{
            return DrawnElementType.freeForm
        }
    }
    
    override init(jsonSpec: JSON) {
        super.init(jsonSpec: jsonSpec)
    }
    
    override init(points: Array<CGPoint>, brush: CGFloat, opacity: CGFloat, red: CGFloat, green: CGFloat, blue: CGFloat, index: Int) {
        super.init(points: points, brush: brush, opacity: opacity, red: red, green: green, blue: blue, index: index)
    }
    
    override init(drawnElement: DrawnElement) {
        super.init(drawnElement: drawnElement)
    }
    
    override open func draw(_ imageView: UIImageView) {
        if self.points.count == 1{
            UIGraphicsBeginImageContext(imageView.frame.size);
            //TODO: Lots of explicit unwrapping
            imageView.image?.draw(in: CGRect(x: 0, y: 0, width: imageView.frame.size.width, height: imageView.frame.size.height));
            UIGraphicsGetCurrentContext()!.setLineCap(CGLineCap.round);
            UIGraphicsGetCurrentContext()!.setLineWidth(brush);
            UIGraphicsGetCurrentContext()!.setStrokeColor(red: self.red, green: self.green, blue: self.blue, alpha: _opacity);
            UIGraphicsGetCurrentContext()!.move(to: CGPoint(x: self.points[0].x, y: self.points[0].y));
            UIGraphicsGetCurrentContext()!.addLine(to: CGPoint(x: self.points[0].x, y: self.points[0].y));
            UIGraphicsGetCurrentContext()!.strokePath();
            UIGraphicsGetCurrentContext()!.flush();
            imageView.image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();

        }else if self.points.count > 1{
            UIGraphicsBeginImageContext(imageView.frame.size);
            imageView.image?.draw(in: CGRect(x: 0, y: 0, width: imageView.frame.size.width, height: imageView.frame.size.height));
            
            for index in 1 ..< self.points.count{
                let firstPoint = self.points[index-1];
                let secondPoint = self.points[index];
                //TODO:Lots of explicit unwrapping
                UIGraphicsGetCurrentContext()!.move(to: CGPoint(x: firstPoint.x, y: firstPoint.y));
                UIGraphicsGetCurrentContext()!.addLine(to: CGPoint(x: secondPoint.x, y: secondPoint.y));
                UIGraphicsGetCurrentContext()!.setLineCap(CGLineCap.round);
                UIGraphicsGetCurrentContext()!.setLineWidth(brush );
                UIGraphicsGetCurrentContext()!.setStrokeColor(red: red, green: green, blue: blue, alpha: 1.0);
                UIGraphicsGetCurrentContext()!.setBlendMode(CGBlendMode.normal);
                UIGraphicsGetCurrentContext()!.strokePath();
            }
            
            imageView.image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
    }
}

class ArrowShape : DrawShape {
    
    override init(jsonSpec: JSON) {
        super.init(jsonSpec: jsonSpec)
    }
    
    override var elementType : DrawnElementType {
        get{
            return DrawnElementType.arrow
        }
    }
    
    override func draw(_ imageView: UIImageView) {
        
    }
}


