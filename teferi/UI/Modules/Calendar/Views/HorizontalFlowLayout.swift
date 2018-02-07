import UIKit

class HorizontalFlowLayout: UICollectionViewLayout
{
    var itemSize: CGSize = CGSize.zero
    private var cache = [UICollectionViewLayoutAttributes]()
    private var contentSize: CGSize = CGSize.zero
    
    override func prepare()
    {
        guard cache.isEmpty == true, let collectionView = collectionView else {
            return
        }
        
        let pageWidth = collectionView.bounds.width
        let itemWidth = itemSize.width
        let itemHeight = itemSize.height
        var maxHeight: CGFloat = 0
        
        for section in 0..<collectionView.numberOfSections
        {
            for item in 0..<collectionView.numberOfItems(inSection: section)
            {
                let frame = CGRect(
                    x: CGFloat(item % 7) * itemWidth + CGFloat(section) * pageWidth,
                    y: floor(CGFloat(item) / 7) * itemHeight,
                    width: itemWidth,
                    height: itemHeight
                )
                
                let indexPath = IndexPath(row: item, section: section)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = frame
                cache.append(attributes)
                
                maxHeight = max(maxHeight, frame.maxY)
            }
        }
        
        contentSize = CGSize(
            width: CGFloat(collectionView.numberOfSections) * pageWidth,
            height: maxHeight
        )
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]?
    {
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        return cache[indexPath.item]
    }
    
    override var collectionViewContentSize: CGSize {
        return contentSize
    }
    
}
