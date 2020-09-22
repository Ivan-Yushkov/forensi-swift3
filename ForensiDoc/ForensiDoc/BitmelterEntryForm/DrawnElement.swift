//
//  DrawnElement.swift
//  TestDrawing

import Foundation
import UIKit
import Swift


public enum DrawnElementType : Int, Equatable{
    case nothing = 1
    case freeForm = 2
    case arrow = 3
    
    public func encode() -> [Int]{
        var ret = Array<Int>()
        switch self {
        case .nothing:
            ret.append(0)
        case .freeForm:
            ret.append(1)
        case .arrow:
            ret.append(2)
        }
        
        return ret
    }
}

public protocol DrawnElement : CustomDebugStringConvertible, JSONConvertible {
    var points : Array<CGPoint> { get }
    var elementType : DrawnElementType { get }
    var brush: CGFloat { get }
    var opacity: CGFloat { get }
    var red: CGFloat { get }
    var green: CGFloat { get }
    var blue: CGFloat { get }
    var index: Int { get }
    var deleted: Bool { get }
    
    func draw(_ imageView: UIImageView)
    func markAsDeleted()
    func touched(_ point: CGPoint, distance: CGFloat) -> Bool
    func equalsOpositeOfOwnDeleted(_ otherDrawnElement: DrawnElement) -> Bool
}

//TODO:Finish this
func isEqualOtherDrawnElement(_ lhs: DrawnElement, rhs: DrawnElement, opositeDeleted: Bool) -> Bool{
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
    
    for (index, element) in lArray.enumerated() {
        let r = rArray[index]
        if element != r {
            return false
        }
    }
    
    let ret =
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
    return isEqualOtherDrawnElement(lhs, rhs: rhs, opositeDeleted: false)
}
