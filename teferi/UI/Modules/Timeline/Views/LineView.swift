import UIKit

class LineView: UIView
{
    var color:UIColor = UIColor.black
        {
        didSet
        {
            setNeedsDisplay()
        }
    }
    
    var fading:Bool = false
        {
        didSet
        {
            setNeedsDisplay()
        }
    }
    
    var collapsed: Bool = false
    {
        didSet
        {
            setNeedsDisplay()
        }
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        backgroundColor = UIColor.clear
    }
    
    override func draw(_ rect: CGRect)
    {        
        backgroundColor = UIColor.clear
        let dotHeight:CGFloat = rect.width
        
        if collapsed {
            drawLine(inRect: CGRect(x: 0, y: 0, width: rect.width, height: rect.height / 2 - dotHeight))
            drawDot(atPoint: CGPoint(x: 0, y: rect.height / 2), width: rect.width)
            drawLine(inRect: CGRect(x: 0, y: rect.height / 2 + dotHeight, width: rect.width, height: rect.height / 2 - dotHeight))
        } else {
            drawSingleLine(inRect: rect)
        }
    }
    
    private func drawLine(inRect rect: CGRect)
    {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        let line = UIBezierPath(roundedRect: rect, cornerRadius: rect.width/2)
        ctx.addPath(line.cgPath)
        color.setFill()
        ctx.drawPath(using: .fill)
    }
    
    private func drawDot(atPoint point: CGPoint, width: CGFloat)
    {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        ctx.addEllipse(in: CGRect(x: point.x, y: point.y - width/2, width: width, height: width))
        
        color.setFill()
        ctx.drawPath(using: .fill)
    }
    
    func drawSingleLine(inRect rect: CGRect)
    {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }

        let line = UIBezierPath(roundedRect: rect, cornerRadius: rect.width/2)
        ctx.addPath(line.cgPath)
        
        if fading
        {
            ctx.clip()
            let colors = [color.cgColor, UIColor.white.cgColor] as CFArray
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: nil)
            
            let gradientHeight = min(100, rect.height)
            ctx.drawLinearGradient(gradient!, start: CGPoint(x:0, y:rect.height - gradientHeight), end: CGPoint(x:rect.origin.x, y:rect.height), options: CGGradientDrawingOptions.drawsBeforeStartLocation)
        }
        else {
            color.setFill()
            ctx.drawPath(using: .fill)
        }
    }
}
