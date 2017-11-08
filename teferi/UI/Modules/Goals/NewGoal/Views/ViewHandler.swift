import UIKit

class ViewHandler<ItemType>
{
    private(set) var visibleCells = [UIView]()
    private let items : [ItemType]
    private let viewForItem : (ItemType, CGSize) -> UIView
    private let viewSize : CGSize
    private let numberOfVisibleCells: Int
    
    init(items: [ItemType], viewForItem: @escaping (ItemType, CGSize) -> UIView, viewSize: CGSize, numberOfVisibleCells: Int)
    {
        guard !items.isEmpty else { fatalError("empty data array") }
        
        self.items = items
        self.viewForItem = viewForItem
        self.viewSize = viewSize
        self.numberOfVisibleCells = numberOfVisibleCells
    }
    
    func item(forCell cell: UIView) -> ItemType
    {
        return items[cell.tag]
    }
    
    func lastVisibleCell(forward: Bool) -> UIView?
    {
        guard !visibleCells.isEmpty else { return nil }
        
        return forward ? visibleCells.last! : visibleCells.first!
    }
    
    func cell(before cell: UIView?, forward: Bool, cellSize: CGSize) -> UIView
    {
        let nextItemIndex = itemIndex(before: cell?.tag, forward: forward)
        let nextItem = items[nextItemIndex]
        
        let cellToReturn = viewForItem(nextItem, viewSize)
        
        cellToReturn.tag = nextItemIndex
        visibleCells.insert(cellToReturn, at: forward ? visibleCells.endIndex : visibleCells.startIndex)
        
        cellToReturn.layer.removeAllAnimations()
        cellToReturn.transform = .identity
        
        return cellToReturn
    }
    
    func remove(cell: UIView)
    {
        let index = visibleCells.index(of: cell)
        visibleCells.remove(at: index!)
        cell.removeFromSuperview()
    }
    
    func cleanAll()
    {
        visibleCells.forEach { (cell) in
            cell.removeFromSuperview()
        }
        
        visibleCells.removeAll()
    }
    
    private func itemIndex(before index: Int?, forward: Bool) -> Int
    {
        guard let index = index
        else
        {
            let startIndex = -numberOfVisibleCells/2
            return (startIndex + items.count) % items.count
        }
        
        guard items.count != 1 else { return 0 }
        
        let beforeIndex = index + (forward ? 1 : -1)
        
        return (beforeIndex + items.count) % items.count
    }
}
