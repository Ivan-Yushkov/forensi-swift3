//
//  ViewController.swift
//  TestDrawing
//
//  Created by Andrzej Czarkowski on 20/10/2014.
//  Copyright (c) 2014 Bitmelter Ltd. All rights reserved.
//

import UIKit

enum DrawMode{
    case Erasor
    case Drawing
}

class ViewController: UIViewController {
    
    let kBlackColorButton = 0;
    let kGreyColorButton = 1;
    let kRedColorButton = 2;
    let kBlueColorButton = 3;
    

    @IBOutlet var mainImage: UIImageView!
    @IBOutlet var tempDrawImage: UIImageView!
    
    var lastPoint : CGPoint!;
    var red: CGFloat;
    var green: CGFloat;
    var blue: CGFloat;
    var mouseSwiped: Bool;
    var brush: CGFloat = 2;
    var opacity: CGFloat = 1.0;
    var lastDrawPoints : Array<CGPoint>;
    let drawingWrapper : DrawingWrapper;
    var drawMode: DrawMode
    
    required init(coder aDecoder: NSCoder) {
        red = 0.0/255.0;
        green = 0.0/255.0;
        blue = 0.0/255.0;
        mouseSwiped = false;
        lastDrawPoints = Array<CGPoint>();
        drawingWrapper = DrawingWrapper();
        drawMode = DrawMode.Drawing
        super.init(coder: aDecoder);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func colorButtonPressed(sender: AnyObject){
        drawMode = DrawMode.Drawing
        var uiBarButton = sender as? UIBarButtonItem;
        
        if let barButton = uiBarButton{
            if barButton.tag == kBlackColorButton{
                red = 0.0/255.0;
                green = 0.0/255.0;
                blue = 0.0/255.0;
            }else if barButton.tag == kGreyColorButton{
                red = 84.0/255.0;
                green = 84.0/255.0;
                blue = 84.0/255.0;
            }else if barButton.tag == kRedColorButton{
                red = 255.0/255.0;
                green = 0.0/255.0;
                blue = 0.0/255.0;
            }else if barButton.tag == kBlueColorButton{
                red = 0.0/255.0;
                green = 0.0/255.0;
                blue = 255.0/255.0;
            }
        }
    }
    
    @IBAction func eraseButtonPressed(sender: AnyObject){
        if drawMode == DrawMode.Drawing {
            drawMode = DrawMode.Erasor
        }else{
            drawMode = DrawMode.Drawing
        }
    }
    
    @IBAction func resetButtonPressed(sender: AnyObject){
        mainImage.image = nil;
        for drawnElement in drawingWrapper.drawHistory {
            self.removeDrawnElement(drawnElement)
        }
        drawingWrapper.reset();
    }
    
    @IBAction func removeLastDrawnElement(sender: AnyObject){
        if drawingWrapper.hasDrawings() {
            if let last = drawingWrapper.getLastElement() {
                if last.deleted {
                    drawingWrapper.redrowElement(last)
                    redrawDrawnElement(last)
                }else{
                    drawingWrapper.removeLast()
                    removeDrawnElement(last)
                }
            }
        }
    }
    
    //MARK:Capturing touches
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        var touch = touches.first as? UITouch
        lastPoint = touch?.locationInView(tempDrawImage)
        
        if drawMode == DrawMode.Drawing {
            lastDrawPoints.removeAll(keepCapacity: false)
            mouseSwiped = false
            lastDrawPoints.append(lastPoint)
        }

    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        if drawMode == DrawMode.Drawing {
            mouseSwiped = true;
            
            var touch = touches.first as? UITouch;
            
            if let t = touch{
                var currentPoint = t.locationInView(tempDrawImage);
                
                UIGraphicsBeginImageContext(tempDrawImage.frame.size);
                
                tempDrawImage.image?.drawInRect(CGRectMake(0, 0, tempDrawImage.frame.size.width, tempDrawImage.frame.size.height));
                
                CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
                CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
                CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
                CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush );
                CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, 1.0);
                CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
                
                CGContextStrokePath(UIGraphicsGetCurrentContext());
                self.tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext();
                self.tempDrawImage.alpha = opacity;
                UIGraphicsEndImageContext();
                lastPoint = currentPoint;
                lastDrawPoints.append(lastPoint);
            }
        }else{
            var touch = touches.first as? UITouch;
            if let t = touch{
                lastPoint = t.locationInView(tempDrawImage);
            }
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if drawMode == DrawMode.Drawing{
            if(!mouseSwiped) {
                UIGraphicsBeginImageContext(tempDrawImage.frame.size);
                self.tempDrawImage.image?.drawInRect(CGRectMake(0, 0, tempDrawImage.frame.size.width, tempDrawImage.frame.size.height));
                CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
                CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush);
                CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, opacity);
                CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
                CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
                CGContextStrokePath(UIGraphicsGetCurrentContext());
                CGContextFlush(UIGraphicsGetCurrentContext());
                self.tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            
            var mainImageSize = self.mainImage.frame.size;
            
            var newLayer = UIImageView(frame: tempDrawImage.frame);
            newLayer.tag = drawingWrapper.getNextIndex()
            
            UIGraphicsBeginImageContext(newLayer.frame.size);
            
            newLayer.image?.drawInRect(CGRectMake(0, 0, newLayer.frame.size.width, newLayer.frame.size.height),blendMode: kCGBlendModeNormal, alpha: 1.0);
            
            self.tempDrawImage.image?.drawInRect(CGRectMake(0, 0, tempDrawImage.frame.size.width, tempDrawImage.frame.size.height), blendMode: kCGBlendModeNormal, alpha: opacity);
            newLayer.image = UIGraphicsGetImageFromCurrentImageContext();
            self.tempDrawImage.image = nil;
            UIGraphicsEndImageContext();
            
            self.view.insertSubview(newLayer, belowSubview: self.tempDrawImage);
            
            drawingWrapper.addFreeFormShape(lastDrawPoints, brush: brush, opacity: opacity, red: red, green: green, blue: blue)
        }else{
            if let touched = drawingWrapper.touch(lastPoint, distance: 20) {
                drawingWrapper.deleteDrawnElement(touched)
                removeDrawnElement(touched)
            }
        }
    }
    
    private func removeDrawnElement(drawnElement: DrawnElement){
        let e = self.view.subviews.filter{ ($0 as? UIImageView)?.tag == drawnElement.index }
        for imageView in e {
            var d = imageView as? UIImageView
            if let image = d {
                image.removeFromSuperview()
            }
        }
    }
    
    private func redrawDrawnElement(drawnElement: DrawnElement){
        var newLayer = UIImageView(frame: tempDrawImage.frame);
        newLayer.tag = drawnElement.index
        drawnElement.draw(newLayer)
        
        debugPrintln(drawnElement)
        
        var drawingBelowDrawing = drawingWrapper.drawingBelowDrawing(drawnElement)
        
        debugPrintln(drawingBelowDrawing)
        
        if let belowDrawing = drawingBelowDrawing {
            let e = self.view.subviews.filter{ ($0 as? UIImageView)?.tag == belowDrawing.index }
            if e.count == 1 {
                var layer = e[0] as? UIImageView
                if let l = layer {
                    self.view.insertSubview(newLayer, aboveSubview: l)
                }
            }
        } else {
            self.view.insertSubview(newLayer, aboveSubview: self.mainImage)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

