import UIKit
import Foundation

extension UIImage
{
    static func resizableShadowImage(cornerRadius: CGFloat, shadowBlur: CGFloat) -> UIImage
    {
        let innerImageSize: CGFloat = 50
        let shadowColor: UIColor = UIColor.black
        let shadowAlpha: CGFloat = 0.3
        
        let side = innerImageSize + (cornerRadius + shadowBlur) * 2.0
        let graphicContextSize = CGSize(width: side, height: side)
        
        // Note: the image is transparent
        UIGraphicsBeginImageContextWithOptions(graphicContextSize, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()!
        defer {
            UIGraphicsEndImageContext()
        }
        
        let roundedRect = CGRect(x: shadowBlur, y: shadowBlur, width: side - shadowBlur*2, height: side - shadowBlur*2)
        let shadowPath = UIBezierPath(roundedRect: roundedRect, cornerRadius: cornerRadius)
        let color = shadowColor.withAlphaComponent(shadowAlpha).cgColor
        
        // Cut out the middle
        context.addRect(context.boundingBoxOfClipPath)
        context.addPath(shadowPath.cgPath)
        context.clip(using: .evenOdd)
        
        context.setStrokeColor(color)
        context.addPath(shadowPath.cgPath)
        context.setShadow(offset: CGSize.zero, blur: shadowBlur, color: color)
        context.fillPath()
        
        let capInset = cornerRadius + shadowBlur
        let edgeInsets = UIEdgeInsets(top: capInset, left: capInset, bottom: capInset, right: capInset)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        
        return image.resizableImage(withCapInsets: edgeInsets, resizingMode: .tile)
    }
}
