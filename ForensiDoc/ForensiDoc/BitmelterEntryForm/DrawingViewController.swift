//
//  ViewController.swift
//  TestDrawing

import UIKit

enum DrawMode{
    case erasor
    case drawing
}

public protocol DrawableViewControllerProtocol {
    func getTableView(_ entryForm: EntryForm) -> UITableViewCell?
    func viewEntryForm(_ entryForm: EntryForm)
    func shouldReload()
}

public protocol DrawingViewControllerDelegate {
    func drawingDoneWithImage(_ image: UIImage?, name: String)
}


open class DrawingViewController: UIViewController, DrawingWrapperCapable {
    
    open let kBlackColorButton = 0;
    open let kGreyColorButton = 1;
    open let kRedColorButton = 2;
    open let kBlueColorButton = 3;
    

    @IBOutlet open var mainImage: UIImageView!
    
    @IBOutlet var tempDrawImage: UIImageView!
    
    var lastPoint : CGPoint!;
    var red: CGFloat;
    var green: CGFloat;
    var blue: CGFloat;
    var mouseSwiped: Bool;
    var brush: CGFloat = 2;
    var opacity: CGFloat = 1.0;
    var lastDrawPoints : Array<CGPoint>;
    open let drawingWrapper : DrawingWrapper;
    var drawMode: DrawMode
    open var delegate: DrawingViewControllerDelegate?
    
    public override init(nibName: String?, bundle: Bundle?){
        red = 0.0/255.0;
        green = 0.0/255.0;
        blue = 0.0/255.0;
        mouseSwiped = false;
        lastDrawPoints = Array<CGPoint>();
        drawMode = DrawMode.drawing
        drawingWrapper = DrawingWrapper();
        super.init(nibName: nibName, bundle: bundle)
        drawingWrapper.setDelegate(self)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        red = 0.0/255.0;
        green = 0.0/255.0;
        blue = 0.0/255.0;
        mouseSwiped = false;
        lastDrawPoints = Array<CGPoint>();
        drawMode = DrawMode.drawing
        drawingWrapper = DrawingWrapper();
        super.init(coder: aDecoder);
        drawingWrapper.setDelegate(self)
    }
    
    func colorButtonPressed(_ sender: AnyObject){
        drawMode = DrawMode.drawing
        let uiBarButton = sender as? UIBarButtonItem;
        
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
    
    func doneButtonPressed(_ sender: AnyObject) {
        AlertHelper.InputDialog(self, title: NSLocalizedString("Name", comment: "Drawing or attachment title message of dialog to ask for title"), okButtonTitle: kSave, cancelButtonTitle: kDiscard, message: [NSLocalizedString("Please enter name", comment: "Message on attachment title dialog")], placeholder: NSLocalizedString("Name", comment: "Attachment title placeholder on dialog"), okCallback: { (data) -> Void in
            if let name = data {
                if name.characters.count == 0 {
                    AlertHelper.DisplayAlert(self, title: kErrorTitle, messages: [NSLocalizedString("Name is required!", comment: "Name is required message on error dialog")], callback: { 
                        self.doneButtonPressed(sender)
                    })
                } else {
                    self.dismiss(animated: true) { () -> Void in
                        if let d = self.delegate {
                            d.drawingDoneWithImage(self.getFinalImage(), name: name)
                        }
                    }
                }
            }}, cancelCallback: {() -> Void in
                self.cancleButtonPressed(sender)
        })
    }
    
    func cancleButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: .none)
    }
    
    func eraseButtonPressed(_ sender: AnyObject){
        if drawMode == DrawMode.drawing {
            drawMode = DrawMode.erasor
        }else{
            drawMode = DrawMode.drawing
        }
    }
    
    func resetButtonPressed(_ sender: AnyObject){
        mainImage.image = nil;
        for drawnElement in drawingWrapper.drawHistory {
            self.removeDrawnElement(drawnElement)
        }
        drawingWrapper.reset();
    }
    
    func removeLastDrawnElement(_ sender: AnyObject){
        if drawingWrapper.hasDrawings() {
            if let last = drawingWrapper.getLastElement() {
                if last.deleted {
                    drawingWrapper.redrowElement(last)
                    redrawDrawnElement(last, drawOnMainImage: false)
                }else{
                    drawingWrapper.removeLast()
                    removeDrawnElement(last)
                }
            }
        }
    }
    
    //MARK:Capturing touches
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        lastPoint = touch?.location(in: tempDrawImage)
        
        if drawMode == DrawMode.drawing {
            lastDrawPoints.removeAll(keepingCapacity: false)
            mouseSwiped = false
            lastDrawPoints.append(lastPoint)
        }

    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if drawMode == DrawMode.drawing {
            mouseSwiped = true;
            
            let touch = touches.first
            
            if let t = touch{
                let currentPoint = t.location(in: tempDrawImage);
                
                UIGraphicsBeginImageContext(tempDrawImage.frame.size);
                
                tempDrawImage.image?.draw(in: CGRect(x: 0, y: 0, width: tempDrawImage.frame.size.width, height: tempDrawImage.frame.size.height));
                
                //TODO:Lots of explicit unwrapping
                UIGraphicsGetCurrentContext()!.move(to: CGPoint(x: lastPoint.x, y: lastPoint.y));
                UIGraphicsGetCurrentContext()!.addLine(to: CGPoint(x: currentPoint.x, y: currentPoint.y));
                UIGraphicsGetCurrentContext()!.setLineCap(CGLineCap.round);
                UIGraphicsGetCurrentContext()!.setLineWidth(brush );
                UIGraphicsGetCurrentContext()!.setStrokeColor(red: red, green: green, blue: blue, alpha: 1.0);
                UIGraphicsGetCurrentContext()!.setBlendMode(CGBlendMode.normal);
                
                UIGraphicsGetCurrentContext()!.strokePath();
                self.tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext();
                self.tempDrawImage.alpha = opacity;
                UIGraphicsEndImageContext();
                lastPoint = currentPoint;
                lastDrawPoints.append(lastPoint);
            }
        }else{
            let touch = touches.first
            if let t = touch{
                lastPoint = t.location(in: tempDrawImage);
            }
        }
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if drawMode == DrawMode.drawing{
            if(!mouseSwiped) {
                UIGraphicsBeginImageContext(tempDrawImage.frame.size);
                self.tempDrawImage.image?.draw(in: CGRect(x: 0, y: 0, width: tempDrawImage.frame.size.width, height: tempDrawImage.frame.size.height));
                //TODO:Lots of explicit unwrapping
                UIGraphicsGetCurrentContext()!.setLineCap(CGLineCap.round);
                UIGraphicsGetCurrentContext()!.setLineWidth(brush);
                UIGraphicsGetCurrentContext()!.setStrokeColor(red: red, green: green, blue: blue, alpha: opacity);
                UIGraphicsGetCurrentContext()!.move(to: CGPoint(x: lastPoint.x, y: lastPoint.y));
                UIGraphicsGetCurrentContext()!.addLine(to: CGPoint(x: lastPoint.x, y: lastPoint.y));
                UIGraphicsGetCurrentContext()!.strokePath();
                UIGraphicsGetCurrentContext()!.flush();
                self.tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            
            let newLayer = UIImageView(frame: tempDrawImage.frame);
            newLayer.tag = drawingWrapper.getNextIndex()
            
            UIGraphicsBeginImageContext(newLayer.frame.size);
            
            newLayer.image?.draw(in: CGRect(x: 0, y: 0, width: newLayer.frame.size.width, height: newLayer.frame.size.height),blendMode: CGBlendMode.normal, alpha: 1.0);
            
            self.tempDrawImage.image?.draw(in: CGRect(x: 0, y: 0, width: tempDrawImage.frame.size.width, height: tempDrawImage.frame.size.height), blendMode: CGBlendMode.normal, alpha: opacity);
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
    
    fileprivate func removeDrawnElement(_ drawnElement: DrawnElement){
        let e = self.view.subviews.filter{ ($0 as? UIImageView)?.tag == drawnElement.index }
        for imageView in e {
            let d = imageView as? UIImageView
            if let image = d {
                image.removeFromSuperview()
            }
        }
    }
    
    fileprivate func redrawDrawnElement(_ drawnElement: DrawnElement, drawOnMainImage: Bool){
        let newLayer = UIImageView(frame: tempDrawImage.frame);
        newLayer.tag = drawnElement.index
        drawnElement.draw(newLayer)
        
        debugPrint(drawnElement)
        
        let drawingBelowDrawing = drawingWrapper.drawingBelowDrawing(drawnElement)
        
        debugPrint(drawingBelowDrawing as Any)
        
        if let belowDrawing = drawingBelowDrawing {
            let e = self.view.subviews.filter{ ($0 as? UIImageView)?.tag == belowDrawing.index }
            if e.count == 1 {
                let layer = e[0] as? UIImageView
                if let l = layer {
                    self.view.insertSubview(newLayer, aboveSubview: l)
                }
            }
        } else {
            self.view.insertSubview(newLayer, aboveSubview: self.mainImage)
        }
    }
    
    open func getFinalImage() -> UIImage? {
        for drawnElement in drawingWrapper.drawHistory {
            drawnElement.draw(self.mainImage)
        }
        if let img = self.mainImage.image {
            //TODO:We could configure the width and height in json settings
            let newImg = ImageUtilities.ImageWithImage(img, scaledToMaxWidth: ImageUtilities.DEFAULT_WIDTH, maxHeight: ImageUtilities.DEFAULT_HEIGHT)
            if let imgData = UIImageJPEGRepresentation(newImg, 0.8) {
                return UIImage(data: imgData)
            }
        }
        
        return self.mainImage.image
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    open func redrawElement(_ drawnElement: DrawnElement) {
        self.redrawDrawnElement(drawnElement, drawOnMainImage: false)
    }


}

