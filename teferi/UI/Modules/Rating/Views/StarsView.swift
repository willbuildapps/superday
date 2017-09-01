import UIKit
import RxSwift

@IBDesignable
class StarsView: UIView
{
    var selectionObservable : Observable<Int>
    {
        return selectionSubject.asObservable()
    }
    
    private let selectedColor = UIColor(red: 1.000, green: 0.764, blue: 0.106, alpha: 1.000)
    private let unselectedColor = UIColor(red: 0.809, green: 0.804, blue: 0.804, alpha: 1.000)
    
    private let selectionSubject = PublishSubject<Int>()
    
    private var selectedStars = 0
    {
        didSet
        {
            self.setNeedsDisplay()
        }
    }
    
    // MARK: - Init
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: - Methods
    private func setup()
    {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(StarsView.handleTap(_:)))
        addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(StarsView.handlePan(_:)))
        addGestureRecognizer(panGesture)
    }
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer)
    {
        let tapPoint: CGPoint = sender.location(in: self)
        selectedStars = stars(forX: tapPoint.x)
        selectionSubject.on(.next(selectedStars))
    }
    
    @objc private func handlePan(_ sender: UIPanGestureRecognizer)
    {
        let panPoint: CGPoint = sender.location(in: self)
        
        switch sender.state {
        case .began, .changed:
            
            selectedStars = stars(forX: panPoint.x)
            
        case .ended:
            
            selectedStars = stars(forX: panPoint.x)
            selectionSubject.on(.next(selectedStars))
        default:
            break
        }
    }
    
    private func stars(forX x: CGFloat) -> Int
    {
        let starTouchWidth = self.bounds.width / 5
        
        var valueToReturn = 0
        
        for index in Array(1...5) {
            if CGFloat(index) * starTouchWidth >= x
            {
                valueToReturn = index
                break
            }
        }
        
        return valueToReturn
    }
    
    private func drawStar(in rect: CGRect, withColor color: UIColor)
    {
        let star1Path = UIBezierPath()
        star1Path.move(to: CGPoint(x: rect.minX + 0.50000 * rect.width, y: rect.minY + 0.00000 * rect.height))
        star1Path.addLine(to: CGPoint(x: rect.minX + 0.63519 * rect.width, y: rect.minY + 0.31393 * rect.height))
        star1Path.addLine(to: CGPoint(x: rect.minX + 0.97553 * rect.width, y: rect.minY + 0.34549 * rect.height))
        star1Path.addLine(to: CGPoint(x: rect.minX + 0.71874 * rect.width, y: rect.minY + 0.57107 * rect.height))
        star1Path.addLine(to: CGPoint(x: rect.minX + 0.79389 * rect.width, y: rect.minY + 0.90451 * rect.height))
        star1Path.addLine(to: CGPoint(x: rect.minX + 0.50000 * rect.width, y: rect.minY + 0.73000 * rect.height))
        star1Path.addLine(to: CGPoint(x: rect.minX + 0.20611 * rect.width, y: rect.minY + 0.90451 * rect.height))
        star1Path.addLine(to: CGPoint(x: rect.minX + 0.28126 * rect.width, y: rect.minY + 0.57107 * rect.height))
        star1Path.addLine(to: CGPoint(x: rect.minX + 0.02447 * rect.width, y: rect.minY + 0.34549 * rect.height))
        star1Path.addLine(to: CGPoint(x: rect.minX + 0.36481 * rect.width, y: rect.minY + 0.31393 * rect.height))
        star1Path.close()
        color.setFill()
        star1Path.fill()
    }
    
    override func draw(_ rect: CGRect)
    {
        //// General Declarations
        // This non-generic function dramatically improves compilation times of complex expressions.
        func fastFloor(_ x: CGFloat) -> CGFloat { return floor(x) }
        
        //// Subframes
        let rect1: CGRect = CGRect(x: rect.minX + fastFloor(rect.width * 0.03500 + 0.5), y: rect.minY + fastFloor(rect.height * 0.14706 + 0.5), width: fastFloor(rect.width * 0.16500 + 0.5) - fastFloor(rect.width * 0.03500 + 0.5), height: fastFloor(rect.height * 0.91176 + 0.5) - fastFloor(rect.height * 0.14706 + 0.5))
        let rect2: CGRect = CGRect(x: rect.minX + fastFloor(rect.width * 0.23500 + 0.5), y: rect.minY + fastFloor(rect.height * 0.11765 + 0.5), width: fastFloor(rect.width * 0.36000 + 0.5) - fastFloor(rect.width * 0.23500 + 0.5), height: fastFloor(rect.height * 0.91176 + 0.5) - fastFloor(rect.height * 0.11765 + 0.5))
        let rect3: CGRect = CGRect(x: rect.minX + fastFloor(rect.width * 0.43500 + 0.5), y: rect.minY + fastFloor(rect.height * 0.11765 + 0.5), width: fastFloor(rect.width * 0.56000 + 0.5) - fastFloor(rect.width * 0.43500 + 0.5), height: fastFloor(rect.height * 0.91176 + 0.5) - fastFloor(rect.height * 0.11765 + 0.5))
        let rect4: CGRect = CGRect(x: rect.minX + fastFloor(rect.width * 0.63500 + 0.5), y: rect.minY + fastFloor(rect.height * 0.11765 + 0.5), width: fastFloor(rect.width * 0.76000 + 0.5) - fastFloor(rect.width * 0.63500 + 0.5), height: fastFloor(rect.height * 0.91176 + 0.5) - fastFloor(rect.height * 0.11765 + 0.5))
        let rect5: CGRect = CGRect(x: rect.minX + fastFloor(rect.width * 0.83500 + 0.5), y: rect.minY + fastFloor(rect.height * 0.14706 + 0.5), width: fastFloor(rect.width * 0.96500 + 0.5) - fastFloor(rect.width * 0.83500 + 0.5), height: fastFloor(rect.height * 0.91176 + 0.5) - fastFloor(rect.height * 0.14706 + 0.5))
        
        let rects = [rect1, rect2, rect3, rect4, rect5]
        
        for (index, rect) in rects.enumerated()
        {
            drawStar(in: rect, withColor: selectedStars >= index + 1 ? selectedColor : unselectedColor)
        }
    }
}
