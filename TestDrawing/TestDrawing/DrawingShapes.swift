//
//  DrawingShapes.swift
//  TestDrawing
//
//  Created by Andrzej Czarkowski on 22/10/2014.
//  Copyright (c) 2014 Bitmelter Ltd. All rights reserved.
//

import Foundation
import UIKit

public class DrawShape : DrawnElement {
    var _points = Array<CGPoint>();
    public var points : Array<CGPoint> {
        get {
            return _points;
        }
    }
    
    let _elementType: DrawnElementType
    public var elementType : DrawnElementType {
        get{
            return _elementType
        }
    }
    
    let _brush : CGFloat;
    public var brush: CGFloat {
        get{
            return _brush;
        }
    }
    
    let _opacity : CGFloat;
    public var opacity: CGFloat {
        get{
            return _opacity;
        }
    }
    
    let _red: CGFloat;
    public var red: CGFloat {
        get{
            return _red;
        }
    }
    
    let _green: CGFloat;
    public var green: CGFloat {
        get{
            return _green;
        }
    }
    
    let _blue: CGFloat;
    public var blue: CGFloat {
        get{
            return _blue;
        }
    }
    
    let _index: Int
    public var index: Int {
        get{
            return _index;
        }
    }
    
    var _deleted: Bool
    public var deleted: Bool {
        get{
            return _deleted
        }
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
        _elementType = DrawnElementType.Nothing
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
    
    public func markAsDeleted() {
        _deleted = true
    }
    
    public func draw(imageView: UIImageView) {
        if self.elementType == DrawnElementType.FreeForm{
            var freeFormShape = self as! FreeFormShape
            freeFormShape.draw(imageView)
        }
    }
    
    public func touched(point: CGPoint, distance: CGFloat) -> Bool {
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
    
    public func equals(otherDrawnElement: DrawnElement) -> Bool {
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
        
        for (index, element) in enumerate(lArray) {
            let r = rArray[index]
            if element != r {
                return false
            }
        }
        
        var ret =
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
    
    public func equalsOpositeOfOwnDeleted(otherDrawnElement: DrawnElement) -> Bool {
        return isEqualOtherDrawnElement(self, otherDrawnElement, true)
    }
    
    public var debugDescription: String {
        get{
            return "_brush = \(_brush) _opacity = \(_opacity) _red = \(_red) _green = \(_green) _blue = \(_blue) _index = \(_index) _elementType = \(_elementType)"
        }
    }
}

public class FreeFormShape : DrawShape {
    override public var elementType : DrawnElementType {
        get{
            return DrawnElementType.FreeForm
        }
    }
    
    override init(points: Array<CGPoint>, brush: CGFloat, opacity: CGFloat, red: CGFloat, green: CGFloat, blue: CGFloat, index: Int) {
        super.init(points: points, brush: brush, opacity: opacity, red: red, green: green, blue: blue, index: index)
    }
    
    override init(drawnElement: DrawnElement) {
        super.init(drawnElement: drawnElement)
    }
    
    override public func draw(imageView: UIImageView) {
        if self.points.count == 1{
            UIGraphicsBeginImageContext(imageView.frame.size);
            imageView.image?.drawInRect(CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height));
            CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
            CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush);
            CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), self.red, self.green, self.blue, _opacity);
            CGContextMoveToPoint(UIGraphicsGetCurrentContext(), self.points[0].x, self.points[0].y);
            CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), self.points[0].x, self.points[0].y);
            CGContextStrokePath(UIGraphicsGetCurrentContext());
            CGContextFlush(UIGraphicsGetCurrentContext());
            imageView.image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();

        }else if self.points.count > 1{
            UIGraphicsBeginImageContext(imageView.frame.size);
            imageView.image?.drawInRect(CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height));
            
            for var index = 1; index < self.points.count; ++index{
                let firstPoint = self.points[index-1];
                let secondPoint = self.points[index];
                
                CGContextMoveToPoint(UIGraphicsGetCurrentContext(), firstPoint.x, firstPoint.y);
                CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), secondPoint.x, secondPoint.y);
                CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
                CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush );
                CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, 1.0);
                CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
                CGContextStrokePath(UIGraphicsGetCurrentContext());
            }
            
            imageView.image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
    }
}

class ArrowShape : DrawShape {
    override var elementType : DrawnElementType {
        get{
            return DrawnElementType.Arrow
        }
    }
    
    override func draw(imageView: UIImageView) {
        
    }
}


