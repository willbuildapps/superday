import UIKit

class LoadingIndicator: UIView
{

    var circleLayer: CAShapeLayer!
    
    init()
    {
        super.init(frame: CGRect(x: 0, y: 0, width: 16, height: 16))
        self.backgroundColor = UIColor.clear
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0), radius: frame.size.width/2, startAngle: 0.0, endAngle: CGFloat.pi * 2.0, clockwise: true)
        
        circleLayer = CAShapeLayer()
        circleLayer.frame = frame
        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = UIColor.familyGreen.cgColor
        circleLayer.lineWidth = 3.0
        
        circleLayer.actions = [
            "strokeEnd": NSNull(),
            "transform": NSNull()
        ]
        
        circleLayer.strokeEnd = 1.0
        layer.addSublayer(circleLayer)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animateCircle()
    {
        let duration = 1.0
        
        circleLayer.removeAllAnimations()
        circleLayer.strokeEnd = 0.0
        circleLayer.strokeStart = 0.0

        let grow = CABasicAnimation(keyPath: "strokeEnd")
        grow.duration = duration
        grow.fromValue = 0
        grow.toValue = 1
        grow.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        grow.repeatCount = Float.greatestFiniteMagnitude
        grow.autoreverses = true
        circleLayer.add(grow, forKey: "animateEnd")
        
        let rotate = CABasicAnimation(keyPath: "transform.rotation")
        rotate.duration = duration / 1.5
        rotate.fromValue = 0
        rotate.toValue = CGFloat.pi * 2
        rotate.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        rotate.repeatCount = Float.greatestFiniteMagnitude
        circleLayer.add(rotate, forKey: "rotateAnimation")
    }
    
    func stopAnimation()
    {
        circleLayer.removeAllAnimations()
    }
}
