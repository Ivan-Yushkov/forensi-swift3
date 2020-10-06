//
//  ImageUtilities.swift
//  ForensiDoc

import Foundation

open class ImageUtilities {
    public static let DEFAULT_HEIGHT:CGFloat = 225;
    public static let DEFAULT_WIDTH:CGFloat = 300;
    
    open class func ImageWithImage(_ image: UIImage, scaledToSize:CGSize) -> UIImage {
        if UIScreen.main.responds(to: #selector(NSDecimalNumberBehaviors.scale)) {
            UIGraphicsBeginImageContextWithOptions(scaledToSize, false, UIScreen.main.scale)
        } else {
            UIGraphicsBeginImageContext(scaledToSize)
        }
        image.draw(in: CGRect(x: 0, y: 0, width: scaledToSize.width, height: scaledToSize.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //TODO:We unwrap explicitly
        return newImage!;
    }
    
    open class func ImageWithImage(_ image: UIImage, scaledToMaxWidth:CGFloat, maxHeight:CGFloat)-> UIImage {
        let oldWidth = image.size.width;
        let oldHeight = image.size.height;
        
        let scaleFactor: CGFloat = (oldWidth > oldHeight) ? scaledToMaxWidth / oldWidth : maxHeight / oldHeight;
        
        let newHeight: CGFloat = oldHeight * scaleFactor;
        let newWidth: CGFloat = oldWidth * scaleFactor;
        let newSize: CGSize = CGSize(width: newWidth, height: newHeight);
        return ImageWithImage(image, scaledToSize: newSize)
    }
}
