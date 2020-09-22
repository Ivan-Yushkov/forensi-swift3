//
//  DrawnElement.swift
//  TestDrawing
//
//  Created by Andrzej Czarkowski on 22/10/2014.
//  Copyright (c) 2014 Bitmelter Ltd. All rights reserved.
//

import Foundation
import UIKit
import Swift


public enum DrawnElementType : CVarArgType, Equatable{
    case Nothing
    case FreeForm
    case Arrow
    
    public func encode() -> [Word]{
        var ret = Array<Word>()
        switch self {
        case .Nothing:
            ret.append(0)
        case .FreeForm:
            ret.append(1)
        case .Arrow:
            ret.append(2)
        }
        
        return ret
    }
}

public protocol DrawnElement : DebugPrintable {
    var points : Array<CGPoint> { get }
    var elementType : DrawnElementType { get }
    var brush: CGFloat { get }
    var opacity: CGFloat { get }
    var red: CGFloat { get }
    var green: CGFloat { get }
    var blue: CGFloat { get }
    var index: Int { get }
    var deleted: Bool { get }
    
    func draw(imageView: UIImageView)
    func markAsDeleted()
    func touched(point: CGPoint, distance: CGFloat) -> Bool
    func equalsOpositeOfOwnDeleted(otherDrawnElement: DrawnElement) -> Bool
}

//TODO:Finish this
func isEqualOtherDrawnElement(lhs: DrawnElement, rhs: DrawnElement, opositeDeleted: Bool) -> Bool{
    if lhs.points.count != rhs.points.count {
        return false
    }
    
    var lArray = Array<CGPoint>(lhs.points)
    var rArray = Array<CGPoint>(rhs.points)
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
    
    /*
    NSLog("%@", rhs.elementType)
    NSLog("%@", lhs.elementType)
    
    NSLog("%@", lhs.brush)
    //NSLog("%@", rhs.brush)
    NSLog("%@", lhs.opacity)
    //NSLog("%@", rhs.opacity)
    NSLog("%@", lhs.red)
    //NSLog("%@", rhs.red)
    NSLog("%@", lhs.green)
    //NSLog("%@", rhs.green)
    NSLog("%@", lhs.blue)
    //NSLog("%@", rhs.blue)
    NSLog("%@", lhs.index)
    //NSLog("%@", rhs.index)
    NSLog("%@", lhs.deleted)
    //NSLog("%@", rhs.deleted)
    */
    
    var ret =
    lhs.elementType == rhs.elementType &&
        lhs.brush == rhs.brush &&
        lhs.opacity == rhs.opacity &&
        lhs.red == rhs.red &&
        lhs.green == rhs.green &&
        lhs.blue == rhs.blue &&
        lhs.index == rhs.index &&
        lhs.deleted == opositeDeleted ? !rhs.deleted : rhs.deleted
    
    return ret
}

//MARK:Equatable
func == (lhs: DrawnElement, rhs: DrawnElement) -> Bool{
    return isEqualOtherDrawnElement(lhs, rhs, false)
}
