import UIKit

class CategoryWheel : UIControl, TrigonometryHelper, UIDynamicAnimatorDelegate, CategoryButtonDelegate
{
    typealias DismissType = ((CategoryWheel) -> ())
    
    var categoryProvider : CategoryProvider?
    
    // MARK: - Flick components
    private var flickBehavior : UIDynamicItemBehavior!
    private var flickAnimator : UIDynamicAnimator!
    private var lastFlickPoint : CGPoint!
    private var flickView : UIView!
    private var flickViewAttachment : UIAttachmentBehavior!
    
    private var isSpinning : Bool = false
    {
        didSet
        {
            guard let viewHandler = viewHandler else { return }
            
            viewHandler.visibleCells.forEach { (cell) in
                cell.isUserInteractionEnabled = !isSpinning
            }
        }
    }
    
    // MARK: - Pan gesture components
    private var panGesture : UIPanGestureRecognizer!
    private var lastPanPoint : CGPoint!
    
    // MARK: - Tap gesture components
    private var tapGesture : UITapGestureRecognizer!

    private var viewHandler : CategoryButtonsHandler?
    
    private(set) var selectedItem : Category?
    
    private let cellSize : CGSize
    private let radius : CGFloat
    private let startAngle : CGFloat
    private let endAngle : CGFloat
    private var centerPoint : CGPoint
    private let angleBetweenCells : CGFloat
    private let dismissAction : DismissType?
    
    private var measurementStartPoint : CGPoint
    {
        return CGPoint(x: centerPoint.x + radius, y: centerPoint.y)
    }
    
    private var cellDiagonalDistance: CGFloat
    {
        return sqrt(pow(cellSize.width, 2) + pow(cellSize.height, 2))
    }
    
    private let animationDuration = TimeInterval(0.225)
    
    private lazy var startAnglePoint : CGPoint = {
        return self.rotatePoint(target: self.measurementStartPoint, aroundOrigin: self.centerPoint, by: self.startAngle)
    }()
    
    private lazy var endAnglePoint : CGPoint = {
        return self.rotatePoint(target: self.measurementStartPoint, aroundOrigin: self.centerPoint, by: self.endAngle)
    }()
    
    private lazy var allowedPath : UIBezierPath = {
        let ovalRect = CGRect(origin: CGPoint(x: self.centerPoint.x - self.radius, y: self.centerPoint.y - self.radius), size: CGSize(width: self.radius * 2, height: self.radius * 2))
        let ovalPath = UIBezierPath()
        ovalPath.addArc(withCenter: CGPoint(x: ovalRect.midX, y: ovalRect.midY), radius: ovalRect.width / 2, startAngle: -self.endAngle, endAngle: -self.startAngle, clockwise: true)
        ovalPath.addLine(to: CGPoint(x: ovalRect.midX, y: ovalRect.midY))
        ovalPath.close()
        return ovalPath
    }()
    
    // MARK: - Init
    
    init(
        frame : CGRect,
        cellSize: CGSize,
        centerPoint: CGPoint,
        radius: CGFloat,
        startAngle: CGFloat,
        endAngle: CGFloat,
        angleBetweenCells: CGFloat,
        attributeSelector: @escaping ((Category) -> (UIImage, UIColor)),
        dismissAction: DismissType?)
    {
        if startAngle >= endAngle
        {
            fatalError("startAngle should be smaller than endAngle")
        }
        
        self.startAngle = startAngle
        self.endAngle = endAngle
        self.angleBetweenCells = angleBetweenCells
        self.radius = radius
        self.centerPoint = centerPoint
        self.cellSize = cellSize
        self.dismissAction = dismissAction
        
        super.init(frame: frame)
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(CategoryWheel.handlePan(_:)))
        panGesture.delaysTouchesBegan = false
        addGestureRecognizer(panGesture)
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(CategoryWheel.handleTap(_:)))
        addGestureRecognizer(tapGesture)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Tap gesture logic
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer)
    {
        resetFlick()
        isSpinning = false
        
        let tapPoint: CGPoint = sender.location(in: self)
        if distance(a: tapPoint, b: centerPoint) > radius + cellSize.width
        {
            dismissAction?(self)
        }
    }
    
    // MARK: - Pan gesture logic
    
    @objc private func handlePan(_ sender: UIPanGestureRecognizer)
    {
        resetFlick()
        
        let panPoint: CGPoint = sender.location(in: self)
        
        switch sender.state {
        case .began:
            
            if distance(a: panPoint, b: centerPoint) > radius + cellDiagonalDistance * 1.5
            {
                dismissAction?(self)
                sender.isEnabled = false
                return
            }
            
            isSpinning = true
            lastPanPoint = panPoint
            
        case .changed:
            
            let angleToRotate = angle(startPoint: lastPanPoint, endPoint: panPoint, anchorPoint: centerPoint)
            
            handleMovement(angleToRotate: angleToRotate)
            
            lastPanPoint = panPoint
            
        case .ended:
            
            isSpinning = false
            
            let velocity = sender.velocity(in: self)
            
            if shouldFlick(for: velocity)
            {
                flick(with: velocity, from: lastPanPoint!)
            }
            
            lastPanPoint = nil
            
        default:
            isSpinning = false
        }
    }
    
    // MARK: - Flick logic
    
    private func flick(with velocity: CGPoint, from point: CGPoint)
    {
        resetFlick()
        
        flickAnimator = UIDynamicAnimator(referenceView: self)
        flickAnimator.delegate = self
        
        let flickViewStartingAngle = positiveAngle(startPoint: measurementStartPoint, endPoint: point, anchorPoint: centerPoint)
        let flickViewCenter = rotatePoint(target: measurementStartPoint, aroundOrigin: centerPoint, by: flickViewStartingAngle)
        flickView = UIView(frame: CGRect(origin: CGPoint(x: flickViewCenter.x - cellSize.width / 2, y: flickViewCenter.y - cellSize.height / 2), size: cellSize))
        flickView.isUserInteractionEnabled = false
        flickView.isHidden = true
        addSubview(flickView)
        
        flickViewAttachment = UIAttachmentBehavior(item: flickView, attachedToAnchor: centerPoint)
        flickAnimator.addBehavior(flickViewAttachment!)

        flickBehavior = UIDynamicItemBehavior(items: [flickView])
        flickBehavior.addLinearVelocity(velocity, for: flickView)
        flickBehavior.allowsRotation = false
        flickBehavior.resistance = 5
        flickBehavior.elasticity = 1
        flickBehavior.density = 1.5
        flickBehavior.action = flickBehaviorAction
        flickAnimator.addBehavior(flickBehavior)
    }
    
    private func resetFlick()
    {
        flickAnimator = nil
        flickBehavior = nil
        flickView = nil
        flickViewAttachment = nil
        lastFlickPoint = nil
    }
    
    func flickBehaviorAction()
    {
        guard let _ = lastFlickPoint
        else
        {
            lastFlickPoint = flickView.center
            return
        }
        
        let angleToRotate = angle(startPoint: lastFlickPoint, endPoint: flickView.center, anchorPoint: centerPoint)
        
        if distance(a: lastFlickPoint, b: flickView.center) == 0
        {
            isSpinning = false
        }
        
        handleMovement(angleToRotate: angleToRotate)
        
        lastFlickPoint = flickView.center
    }
    
    // MARK: - UIDynamicAnimatorDelegate
    
    func dynamicAnimatorWillResume(_ animator: UIDynamicAnimator)
    {
        isSpinning = true
    }
    
    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator)
    {
        isSpinning = false
    }
    
    // MARK: - Rotation logic
    
    private func handleMovement(angleToRotate: CGFloat)
    {
        guard let viewHandler = viewHandler else { return }
        
        let rotationDirection = angleToRotate < 0

        let cells = viewHandler.visibleCells
        
        let pointToBaseMovement = rotatePoint(target: cells.first!.center, aroundOrigin: centerPoint, by: toPositive(angle: angleToRotate))
        
        for (index, cell) in cells.enumerated()
        {
            let center = rotatePoint(target: pointToBaseMovement, aroundOrigin: centerPoint, by: toPositive(angle: CGFloat(index) * angleBetweenCells))
            positionAndRotateCell(cell, center: center)
            
            if !isInAllowedRange(point: cell.center)
            {
                viewHandler.remove(cell: cell)
            }
        }
        
        guard var lastCellBasedOnRotationDirection = viewHandler.lastVisibleCell(forward: rotationDirection) else { return }
        
        var angleOfLastPoint = positiveAngle(startPoint: measurementStartPoint, endPoint: lastCellBasedOnRotationDirection.center, anchorPoint: centerPoint)
        
        var edgeAngle = (rotationDirection ? endAngle : startAngle)
        edgeAngle = toPositive(angle: edgeAngle)
        
        while abs(abs(angleOfLastPoint) - edgeAngle) > angleBetweenCells
        {
            let newCell = viewHandler.cell(before: lastCellBasedOnRotationDirection, forward: rotationDirection, cellSize: cellSize)
            newCell.delegate = self
            let center = rotatePoint(target: lastCellBasedOnRotationDirection.center, aroundOrigin: centerPoint, by: ( rotationDirection ? 1 : -1 ) * angleBetweenCells)
            positionAndRotateCell(newCell, center:center)
            newCell.isUserInteractionEnabled = !isSpinning
            
            addSubview(newCell)
            
            lastCellBasedOnRotationDirection = newCell
            angleOfLastPoint = positiveAngle(startPoint: measurementStartPoint, endPoint: lastCellBasedOnRotationDirection.center, anchorPoint: centerPoint)
        }
    }
    
    // MARK: - Presentation and dismissal logic
    
    func show(below view: UIView, showing numberToShow: Int = 5, startingAngle: CGFloat = CGFloat.pi / 2)
    {
        guard let categoryProvider = categoryProvider else { return }
        
        viewHandler = CategoryButtonsHandler(items: categoryProvider.getAll(but: .unknown))

        view.superview?.insertSubview(self, belowSubview: view)
        
        centerPoint = view.center
        
        panGesture.isEnabled = true
        
        var animationSequence = DelayedSequence.start()
        
        let delay = TimeInterval(0.04)
        var previousCell : CategoryButton?
        
        for index in 0..<numberToShow
        {
            let cell = viewHandler!.cell(before: previousCell, forward: true, cellSize: cellSize)
            cell.delegate = self
            let center = rotatePoint(target: measurementStartPoint, aroundOrigin: centerPoint, by: toPositive(angle: startingAngle + CGFloat(index) * angleBetweenCells))
            positionAndRotateCell(cell, center: center)
            cell.isHidden = true

            addSubview(cell)
            
            animationSequence = animationSequence.after(delay, animate(cell, presenting: true))
            
            previousCell = cell
        }
    }
    
    func hide()
    {
        guard let viewHandler = viewHandler else { return }
        
        var animationSequence = DelayedSequence.start()
        
        let delay = TimeInterval(0.02)
        
        for cell in viewHandler.visibleCells.filter({ $0.frame.intersects(bounds) })
        {
            animationSequence = animationSequence.after(delay, animate(cell, presenting: false))
        }
        
        animationSequence.after(animationDuration, cleanupAfterHide())
    }
    
    private func cleanupAfterHide() -> (TimeInterval) -> ()
    {
        guard let viewHandler = viewHandler else { return { _ in } }

        return { delay in
            
            Timer.schedule(withDelay: delay)
            {
                self.resetFlick()
                viewHandler.cleanAll()
                self.removeFromSuperview()
            }
        }
    }
    
    private func animate(_ cell: CategoryButton, presenting: Bool) -> (TimeInterval) -> ()
    {
        return { delay in
            Timer.schedule(withDelay: delay)
            {
                let translationTransform = CGAffineTransform(translationX: self.centerPoint.x - cell.center.x, y: self.centerPoint.y - cell.center.y)
                
                let scaleTransform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                
                cell.transform = presenting ?
                    translationTransform :
                    .identity
                
                cell.alpha = presenting ? 0.0 : 1.0
                
                cell.isHidden = false
                
                cell.show()
                
                let timingFunction = CAMediaTimingFunction(controlPoints: 0.23, 1, 0.32, 1)
                
                CATransaction.begin()
                CATransaction.setAnimationTimingFunction(timingFunction)
                
                UIView.animate(withDuration: self.animationDuration, animations:
                {
                    cell.transform = presenting ?
                        .identity :
                        scaleTransform.concatenating(translationTransform)
                    
                    cell.alpha = presenting ? 1.0 : 0.0
                })
                
                CATransaction.commit()
            }
        }
    }
    
    private func positionAndRotateCell(_ cell: CategoryButton, center:CGPoint)
    {
        cell.center = center
        cell.angle = angle(from: cell.center, to: centerPoint)
    }

    
    // MARK: - SelectionHandling
    func categorySelected(category: Category)
    {
        selectedItem = category
        sendActions(for: .valueChanged)
    }
    
    // MARK: - Math functions
    
    private func isInAllowedRange(point: CGPoint) -> Bool
    {
        return allowedPath.contains(point)
    }
    
    private func shouldFlick(for velocity: CGPoint) -> Bool
    {
        return max( abs( velocity.x ), abs( velocity.y ) ) > 200
    }
}