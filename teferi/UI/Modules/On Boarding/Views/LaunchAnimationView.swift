import UIKit

class LaunchAnimationView : UIView
{
    // MARK: Fields
    private var background = CALayer()
    private var dots = [CALayer]()
    
    // MARK: Initializers
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        background.frame = frame
        background.backgroundColor = UIColor.white.cgColor
        layer.addSublayer(background)
        
        let colors = [Style.Color.green, Style.Color.purple, Style.Color.transparentPurple,
                      Style.Color.transparentGreen, Style.Color.yellow, Style.Color.purple,
                      Style.Color.green, Style.Color.transparentYellow, Style.Color.yellow]
        
        let dotSize = CGFloat(20)
        let dotMargin = CGFloat(8.0)
        let dotStep = dotSize + dotMargin
        let centerOffset = dotSize * 1.5 + dotMargin
        let offsetX = frame.width / 2 - centerOffset
        let offsetY = frame.height / 2 - centerOffset
        let cornerRadius = dotSize / 2
        
        for i in 0..<9
        {
            let dot = CALayer()
            
            let row = CGFloat(i / 3)
            let column = CGFloat(i % 3)
            
            dot.frame = CGRect(
                x: offsetX + dotStep * column,
                y: offsetY + dotStep * row,
                width: dotSize,
                height: dotSize
            )
            
            dot.backgroundColor = colors[i].cgColor
            dot.cornerRadius = cornerRadius
            
            dots.append(dot)
            layer.addSublayer(dot)
        }
    }
    
    // MARK: Actions
    func animate(onCompleted: @escaping () -> ())
    {
        let animationOrder = [0, 8, 2, 6, 1, 7, 3, 5, 4]
        
        let duration = 0.15
        let interval = 0.1
        let lastDuration = 0.25
        
        for i in 0..<8
        {
            animateDot(dots[animationOrder[i]], duration: duration, delay: Double(i) * interval)
        }
        
        animateDot(dots[animationOrder[8]], duration: lastDuration, delay: 8 * interval)

        Timer.schedule(withDelay: duration * 5) {  onCompleted() }
    }
    
    private func animateDot(_ dot: CALayer, duration: Double, delay: Double)
    {
        animateLayer(dot, duration: duration, delay: delay, animation:
            { _ in
                let f = dot.frame
                dot.frame = CGRect(x: f.origin.x + f.width / 2, y: f.origin.y + f.width / 2, width: 0, height: 0)
                dot.cornerRadius = 0
            }, properties: "position", "bounds", "cornerRadius")
    }
}
