//
//  DrawingWrapper.swift
//  TestDrawing
//
//  Created by Andrzej Czarkowski on 05/11/2014.
//  Copyright (c) 2014 Bitmelter Ltd. All rights reserved.
//

import Foundation
import UIKit

public class DrawingWrapper {
    var drawHistory : Array<DrawnElement>
    var index: Int
    var currentIndex: Int
    public let minIndex = 1000000
    
    init(){
        self.drawHistory = Array<DrawnElement>()
        self.index = minIndex;
        self.currentIndex = minIndex
    }
    
    public func addFreeFormShape(
        points: Array<CGPoint>,
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
    
    public func reset(){
        self.drawHistory.removeAll(keepCapacity: false);
    }
    
    public func hasDrawings() -> Bool{
        return self.drawHistory.count > 0
    }
    
    public func getNextIndex() -> Int{
        let ret = self.index
        self.currentIndex = ret
        self.index++
        return ret;
    }
    
    public func getLastElement() -> DrawnElement?{
        if self.hasDrawings() {
            return self.drawHistory.last;
        }
        return nil;
    }
    
    public func redrowElement(drawnElement: DrawnElement){
        let drawnElementsInHistory = self.drawHistory.filter{ $0 == drawnElement }
        
        for drawnElementInHistory in drawnElementsInHistory {
            var possibleIndex = self.drawHistory.find{ $0 == drawnElementInHistory }
            if let index = possibleIndex {
                self.drawHistory.removeAtIndex(index)
            }
        }
    }
    
    public func removeLast() -> DrawnElement?{
        if self.hasDrawings() {
            let l = self.drawHistory.last;
            self.drawHistory.removeLast()
            return l;
        }
        return nil;
    }
    
    public func drawingBelowDrawing(drawnElement: DrawnElement) -> DrawnElement? {
        var lastElementWithLowerIndex: DrawnElement?
        debugPrintln(drawnElement)
        
        for i in self.drawHistory {
            var isDeleted = i.deleted
            if !isDeleted {
                //check whether we have the same one as i but marked as deleted
                isDeleted = _isAlsoMarkedAsDeleted(i)
            }
            
            debugPrintln(i)
            debugPrintln(lastElementWithLowerIndex)
            if !isDeleted && i.index >  drawnElement.index {
                break
            }
            if !isDeleted && i.index < drawnElement.index {
                lastElementWithLowerIndex = i
            }
        }
        
        return lastElementWithLowerIndex
    }
    
    public func touch(point: CGPoint, distance: CGFloat) -> DrawnElement?{
        var touched: DrawnElement?
        
        for drawnElement in drawHistory {
            if drawnElement.touched(point, distance: distance) {
                touched = drawnElement
                break
            }
        }
        
        return touched
    }
    
    public func deleteDrawnElement(drawnElement: DrawnElement){
        var deletedElement : DrawnElement?
        if drawnElement.elementType == DrawnElementType.FreeForm {
            deletedElement = FreeFormShape(drawnElement: drawnElement)
        }
        
        if let d = deletedElement {
            d.markAsDeleted()
            self.drawHistory.append(d)
        }
    }
    
    private func _isAlsoMarkedAsDeleted(drawnElement: DrawnElement) -> Bool {
        //TODO:Finish this
        for otherDrawnElement in drawHistory {
            if isEqualOtherDrawnElement(drawnElement, otherDrawnElement, true) {
                return true
            }
        }
        return false
    }
}
