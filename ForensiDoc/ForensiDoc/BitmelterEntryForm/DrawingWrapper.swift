//
//  DrawingWrapper.swift
//  TestDrawing

import Foundation
import UIKit

public protocol DrawingWrapperCapable {
    func redrawElement(_ drawnElement: DrawnElement)
}


open class DrawingWrapper {
    var drawHistory : Array<DrawnElement>
    var index: Int
    var currentIndex: Int
    var delegate: DrawingWrapperCapable? = .none
    open let minIndex = 1000000
    
    init(){
        self.drawHistory = Array<DrawnElement>()
        self.index = minIndex;
        self.currentIndex = minIndex
    }
    
    open func setDelegate(_ delegate: DrawingWrapperCapable) {
        self.delegate = delegate
    }
    
    open func addFreeFormShape(
        _ points: Array<CGPoint>,
        brush: CGFloat,
        opacity: CGFloat,
        red: CGFloat,
        green: CGFloat,
        blue: CGFloat){
            let freeFormShape = FreeFormShape(
                points: points,
                brush: brush,
                opacity: opacity,
                red: red,
                green: green,
                blue: blue,
                index:self.currentIndex);
            
            drawHistory.append(freeFormShape)
    }
    
    open func getDrawHistory() -> [DrawnElement] {
        return self.drawHistory
    }
    
    open func reset(){
        self.drawHistory.removeAll(keepingCapacity: false);
    }
    
    open func hasDrawings() -> Bool{
        return self.drawHistory.count > 0
    }
    
    open func getNextIndex() -> Int{
        let ret = self.index
        self.currentIndex = ret
        self.index += 1
        return ret;
    }
    
    open func getLastElement() -> DrawnElement?{
        if self.hasDrawings() {
            return self.drawHistory.last;
        }
        return nil;
    }
    
    open func updateFromDrawHistory(_ drawHistory: [DrawnElement]) {
        self.drawHistory.removeAll(keepingCapacity: true)
        for drawnElement in drawHistory {
            self.drawHistory.append(drawnElement)
            if let d = self.delegate {
                d.redrawElement(drawnElement)
            }
        }
    }
    
    open func redrowElement(_ drawnElement: DrawnElement){
        let drawnElementsInHistory = self.drawHistory.filter{ $0 == drawnElement }
        
        for drawnElementInHistory in drawnElementsInHistory {
            let possibleIndex = self.drawHistory.find{ $0 == drawnElementInHistory }
            if let index = possibleIndex {
                self.drawHistory.remove(at: index)
            }
        }
    }
    
    open func removeLast() -> DrawnElement?{
        if self.hasDrawings() {
            let l = self.drawHistory.last;
            self.drawHistory.removeLast()
            return l;
        }
        return nil;
    }
    
    open func drawingBelowDrawing(_ drawnElement: DrawnElement) -> DrawnElement? {
        var lastElementWithLowerIndex: DrawnElement?
        debugPrint(drawnElement)
        
        for i in self.drawHistory {
            var isDeleted = i.deleted
            if !isDeleted {
                //check whether we have the same one as i but marked as deleted
                isDeleted = _isAlsoMarkedAsDeleted(i)
            }
            
            debugPrint(i)
            debugPrint(lastElementWithLowerIndex as Any)
            if !isDeleted && i.index >  drawnElement.index {
                break
            }
            if !isDeleted && i.index < drawnElement.index {
                lastElementWithLowerIndex = i
            }
        }
        
        return lastElementWithLowerIndex
    }
    
    open func touch(_ point: CGPoint, distance: CGFloat) -> DrawnElement?{
        var touched: DrawnElement?
        
        for drawnElement in drawHistory {
            if drawnElement.touched(point, distance: distance) {
                touched = drawnElement
                break
            }
        }
        
        return touched
    }
    
    open func deleteDrawnElement(_ drawnElement: DrawnElement){
        var deletedElement : DrawnElement?
        if drawnElement.elementType == DrawnElementType.freeForm {
            deletedElement = FreeFormShape(drawnElement: drawnElement)
        }
        
        if let d = deletedElement {
            d.markAsDeleted()
            self.drawHistory.append(d)
        }
    }
    
    fileprivate func _isAlsoMarkedAsDeleted(_ drawnElement: DrawnElement) -> Bool {
        //TODO:Finish this
        for otherDrawnElement in drawHistory {
            if isEqualOtherDrawnElement(drawnElement, rhs: otherDrawnElement, opositeDeleted: true) {
                return true
            }
        }
        return false
    }
}
