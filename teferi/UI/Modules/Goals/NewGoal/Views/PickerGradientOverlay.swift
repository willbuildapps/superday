import UIKit

class PickerGradientOverlay: UIView
{
    private let middleGap: CGFloat
    
    init(middleGap: CGFloat = 5)
    {
        self.middleGap = middleGap
        
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))

        backgroundColor = .clear
        isUserInteractionEnabled = false
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect)
    {
        
        let context = UIGraphicsGetCurrentContext()!

        let location1 = (rect.width / 2 - middleGap/2) / rect.width
        let location2 = (rect.width / 2 + middleGap/2) / rect.width
        
        let gradient = CGGradient(
            colorsSpace: nil,
            colors: [UIColor(white: 1.0, alpha: 0.9).cgColor, UIColor(white: 1.0, alpha: 0).cgColor, UIColor(white: 1.0, alpha: 0).cgColor, UIColor(white: 1.0, alpha: 0.9).cgColor] as CFArray,
            locations: [0.2, location1, location2, 0.8]
        )!
        
        let rectanglePath = UIBezierPath(rect: rect)
        context.saveGState()
        rectanglePath.addClip()
        context.drawLinearGradient(gradient,
                                   start: CGPoint(x: rect.minX, y: rect.midY),
                                   end: CGPoint(x: rect.maxX, y: rect.midY),
                                   options: [])
        context.restoreGState()
    }
}
