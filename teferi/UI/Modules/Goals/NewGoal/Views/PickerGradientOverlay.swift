import UIKit

class PickerGradientOverlay: UIView
{
    let cellSize : CGSize
    
    init(withframe frame: CGRect, cellSize: CGSize)
    {
        self.cellSize = cellSize
        
        super.init(frame: frame)
        
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        setNeedsDisplay()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect)
    {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Color Declarations
        let transparentWhite = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.000)
        let semiTransparentWhite = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.910)
        
        let percentageOfCellSize = cellSize.width / rect.width
        let halfPercentageOfCellSize = percentageOfCellSize / 2
        
        //// Gradient Declarations
        let gradient = CGGradient(colorsSpace: nil, colors: [UIColor.white.cgColor, semiTransparentWhite.cgColor, transparentWhite.cgColor, transparentWhite.cgColor, semiTransparentWhite.cgColor, UIColor.white.cgColor] as CFArray, locations: [0.04, 0.36, 0.5 - halfPercentageOfCellSize, 0.5 + halfPercentageOfCellSize, 0.64, 0.96])!
        
        //// Rectangle Drawing
        let rectangleRect = CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height)
        let rectanglePath = UIBezierPath(rect: rectangleRect)
        context.saveGState()
        rectanglePath.addClip()
        context.drawLinearGradient(gradient,
                                   start: CGPoint(x: rectangleRect.minX, y: rectangleRect.midY),
                                   end: CGPoint(x: rectangleRect.maxX, y: rectangleRect.midY),
                                   options: [])
        context.restoreGState()
    }
}
