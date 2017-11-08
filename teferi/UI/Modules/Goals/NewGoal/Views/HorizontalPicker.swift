import UIKit
import RxSwift

class HorizontalPicker<ItemType: Equatable> : UIControl, TrigonometryHelper, UIDynamicAnimatorDelegate
{
    // MARK: Public Properties
    private(set) var isAlreadySetup = false
    var selectionItemObservable: Observable<ItemType> { return self.selectedItemSubject.asObservable().distinctUntilChanged() }
    
    // MARK: - Flick components
    private var flickBehavior : UIDynamicItemBehavior!
    private var flickAnimator : UIDynamicAnimator!
    private var previousFlickPoint : CGPoint!
    private var firstFlickPoint : CGPoint!
    private var flickView : UIView!
    
    fileprivate var isFlicking : Bool = false
    {
        didSet
        {
            viewHandler.visibleCells.forEach { (cell) in
                cell.isUserInteractionEnabled = !isFlicking
            }
        }
    }
    
    private let selectedItemSubject = PublishSubject<ItemType>()
    
    private var viewHandler : ViewHandler<ItemType>!
    private var centerRelativeToBounds : CGPoint { return CGPoint(x: bounds.width/2, y: bounds.height/2) }
    private var centerY : CGFloat { return bounds.height/2 }
    private var leftBoundryX : CGFloat { return 0 }
    private var rightBoundryX : CGFloat { return bounds.width }
    private var items : [ItemType]!
    
    private var cellSize : CGSize!
    private var cellSpacing : CGFloat { return bounds.width/CGFloat(numberOfVisibleCells) - cellSize.width }
    private var numberOfVisibleCells : Int!
    private var pageWidth : CGFloat { return cellSize.width + cellSpacing }
    private let animationDuration = TimeInterval(0.225)
    
    // MARK: - Pan gesture components
    private var panGesture : UIPanGestureRecognizer!
    private var previousPanPoint : CGPoint!
    private var firstPanPoint : CGPoint!
    
    // MARK: - Tap gesture components
    private var tapGesture : UITapGestureRecognizer!
    
    
    // MARK: - Public methode
    func setup(withItems items: [ItemType], viewForItem: @escaping (ItemType, CGSize) -> UIView, viewSize: CGSize, numberOfVisibleViews: Int)
    {
        isAlreadySetup = true
        
        self.cellSize = viewSize
        self.numberOfVisibleCells = numberOfVisibleViews % 2 != 0 ? numberOfVisibleViews : numberOfVisibleViews + 1
        self.items = items
        self.viewHandler = ViewHandler(items: items, viewForItem: viewForItem, viewSize: viewSize, numberOfVisibleCells: numberOfVisibleViews)
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(HorizontalPicker<ItemType>.handlePan(_:)))
        panGesture.delaysTouchesBegan = false
        addGestureRecognizer(panGesture)
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(HorizontalPicker<ItemType>.handleTap(_:)))
        addGestureRecognizer(tapGesture)
        
        clipsToBounds = true
        
        show()
    }
    
    // MARK: Private Methods
    @objc private func handleTap(_ sender: UITapGestureRecognizer)
    {
        resetFlick()
        snapCellsToCorrrectPosition()
    }
    
    // MARK: - Pan gesture logic
    @objc private func handlePan(_ sender: UIPanGestureRecognizer)
    {
        resetFlick()
        
        let panPoint: CGPoint = sender.location(in: self)
        
        switch sender.state {
        case .began:
            
            previousPanPoint = panPoint
            firstPanPoint = panPoint
            
        case .changed:
            
            handle(movement: panPoint.x - previousPanPoint.x)
            
            previousPanPoint = panPoint
            
        case .ended:
            
            isFlicking = false
            
            let velocity = sender.velocity(in: self)
            
            if shouldFlick(for: velocity)
            {
                flick(with: velocity, from: previousPanPoint!)
            }
            else
            {
                snapCellsToCorrrectPosition()
            }
            
            previousPanPoint = nil
            
        default:
            break
        }
    }
    
    // MARK: - Movement logic
    private func handle(movement: CGFloat)
    {
        guard movement != 0 else { return }
        
        let cells = viewHandler.visibleCells
        
        guard cells.count > 0 else { return }
        
        let isMovingForward = movement < 0
        
        let pointToBaseMovement = isMovingForward ? CGPoint(x: cells.first!.center.x + movement, y: centerY) : CGPoint(x: cells[1].center.x + movement - pageWidth, y: centerY)
        
        for (index, cell) in cells.enumerated()
        {
            cell.center = CGPoint(x: pointToBaseMovement.x + pageWidth * CGFloat(index), y: pointToBaseMovement.y)
            
            if cell.frame.contains(centerRelativeToBounds)
            {
                selectedItemSubject.on(.next(viewHandler.item(forCell: cell)))
            }
            
            if !isInAllowedRange(cell)
            {
                viewHandler.remove(cell: cell)
            }
        }
        
        guard var lastCellBasedOnDirection = viewHandler.lastVisibleCell(forward: isMovingForward) else { return }
        
        while isMovingForward ? lastCellBasedOnDirection.frame.minX + cellSize.width < rightBoundryX : lastCellBasedOnDirection.frame.minX - cellSpacing > leftBoundryX
        {
            let newCell = viewHandler.cell(before: lastCellBasedOnDirection, forward: isMovingForward, cellSize: cellSize)
            newCell.center = CGPoint(x: lastCellBasedOnDirection.center.x + pageWidth * (isMovingForward ? 1 : -1), y: centerY)
            
            if newCell.frame.contains(centerRelativeToBounds)
            {
                selectedItemSubject.on(.next(viewHandler.item(forCell: newCell)))
            }
            
            addSubview(newCell)
            
            lastCellBasedOnDirection = newCell
        }
    }
    
    // MARK: - Flick logic
    private func flick(with velocity: CGPoint, from point: CGPoint)
    {
        resetFlick()
        
        flickAnimator = UIDynamicAnimator(referenceView: self)
        flickAnimator.delegate = self
        
        let flickViewCenter = point
        firstFlickPoint = flickViewCenter
        flickView = UIView(frame: CGRect(origin: CGPoint(x: flickViewCenter.x - cellSize.width / 2, y: flickViewCenter.y - cellSize.height / 2), size: cellSize))
        flickView.isUserInteractionEnabled = false
        flickView.isHidden = true
        addSubview(flickView)
        
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
        previousFlickPoint = nil
        firstFlickPoint = nil
    }
    
    private func flickBehaviorAction()
    {
        guard let _ = previousFlickPoint
            else
        {
            previousFlickPoint = flickView.center
            return
        }
        
        if distance(a: previousFlickPoint, b: flickView.center) == 0
        {
            isFlicking = false
            resetFlick()
            snapCellsToCorrrectPosition()
            return
        }
        
        handle(movement: flickView.center.x - previousFlickPoint.x)
        
        previousFlickPoint = flickView.center
    }
    
    private func show()
    {
        var previousCell : UIView?
        var index = 0

        while index != 0 ? bounds.contains(previousCell!.frame) : true
        {
            let cell = viewHandler.cell(before: previousCell, forward: true, cellSize: cellSize)
            cell.center = CGPoint(x: leftBoundryX + pageWidth * CGFloat(index) + cellSize.width / 2 + cellSpacing / 2, y: centerY)
            
            if cell.frame.contains(centerRelativeToBounds)
            {
                selectedItemSubject.on(.next(viewHandler.item(forCell: cell)))
            }

            addSubview(cell)

            previousCell = cell
            index += 1
        }
    }
    
    // MARK: - Animation
    private func snapCellsToCorrrectPosition()
    {
        let cells = viewHandler.visibleCells
        
        guard let firstCell = cells.first else { return }
        
        let distanceBasedOnPageWidth = firstCell.center.x - leftBoundryX + pageWidth / 2
        
        let offset = abs(pageWidth - abs(distanceBasedOnPageWidth)) < pageWidth / 2 ?
            (distanceBasedOnPageWidth > 0 ? 1 : -1) * pageWidth - distanceBasedOnPageWidth :
            -distanceBasedOnPageWidth
        
        let animationDuration = 0.334
        
        UIView.animate({
            cells.forEach { (cell) in
                cell.center = CGPoint(x: cell.center.x + offset, y: self.centerY)
                
                if cell.frame.contains(self.centerRelativeToBounds)
                {
                    self.selectedItemSubject.on(.next(self.viewHandler.item(forCell: cell)))
                }
                
                if !self.isInAllowedRange(cell)
                {
                    self.viewHandler.remove(cell: cell)
                }
            }
        }, duration: TimeInterval(animationDuration),
           options: [.curveEaseInOut])
    }
    
    // MARK: - Math functions
    private func isInAllowedRange(_ cell: UIView) -> Bool
    {
        return (cell.frame.minX > leftBoundryX && cell.frame.minX < rightBoundryX) || (cell.frame.maxX > leftBoundryX && cell.frame.maxX < rightBoundryX)
    }
    
    private func shouldFlick(for velocity: CGPoint) -> Bool
    {
        return abs( velocity.x ) > 200
    }
    
    // MARK: - UIDynamicAnimatorDelegate
    
    func dynamicAnimatorWillResume(_ animator: UIDynamicAnimator)
    {
        isFlicking = true
    }
    
    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator)
    {
        isFlicking = false
    }
}
