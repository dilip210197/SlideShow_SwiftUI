//
//  UIImage.swift
//  SlideShow
//
//  Created by Anuj Joshi on 14/06/24.
//

import Foundation
import UIKit

extension UIImage{
    
    convenience init(view: UIView) {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: image!.cgImage!)
    }
    
        class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
            let count = CGImageSourceGetCount(source)
            var images = [UIImage]()
            var duration = 0.0
            
            for i in 0..<count {
                guard let image = CGImageSourceCreateImageAtIndex(source, i, nil) else { return nil }
                images.append(UIImage(cgImage: image)) // Convert CGImage to UIImage
                
                guard let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [String: Any],
                      let gifDict = properties[kCGImagePropertyGIFDictionary as String] as? [String: Any],
                      let gifDelay = gifDict[kCGImagePropertyGIFDelayTime as String] as? Double
                else { return nil }
                
                duration += gifDelay
            }
            
            let animation = UIImage.animatedImage(with: images, duration: duration)
            return animation
        }
    
    public class func gifImageWithData(_ data: Data) -> UIImage? {
            guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
                print("Error: Source for GIF not found")
                return nil
            }

            return UIImage.animatedImageWithSource(source)
        }
}
