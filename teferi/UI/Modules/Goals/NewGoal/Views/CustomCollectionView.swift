import UIKit

protocol CustomCollectionViewDatasource
{
    func numberOfItems(for collectionView: UICollectionView) -> Int
    func cell(at row: Int, for collectionView: UICollectionView) -> UICollectionViewCell
}

protocol CustomCollectionViewDelegate
{
    func itemSelected(for collectionView: UICollectionView, at row: Int)
}

class CustomCollectionView: UICollectionView
{
    let numberOfLoops: Int = 100
    
    var loops: Bool = false
    var customDatasource: CustomCollectionViewDatasource? {
        didSet {
            delegate = self
            dataSource = self
            
            totalNumberOfItems = customDatasource!.numberOfItems(for: self)
        }
    }
    
    var customDelegate: CustomCollectionViewDelegate?
    
    private var didLayout: Bool = false
    fileprivate var totalNumberOfItems: Int = 0
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout)
    {
        super.init(frame: frame, collectionViewLayout: layout)
        setup()
    }
    
    private func setup()
    {
        allowsSelection = false
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let inset = frame.width / 2 - layout.itemSize.width / 2
        contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        
        firstLayoutIfNeeded()
    }
    
    private func firstLayoutIfNeeded()
    {
        guard !didLayout else { return }
        
        didLayout = true
        if loops {
            let layout = collectionViewLayout as! UICollectionViewFlowLayout
            let cellWidth = layout.itemSize.width + layout.minimumInteritemSpacing
            contentOffset = CGPoint(x: -contentInset.left + cellWidth * CGFloat(numberOfLoops/2 * totalNumberOfItems), y: 0)
        } else {
            contentOffset = CGPoint(x: -contentInset.left, y: 0)
        }
    }
}

extension CustomCollectionView: UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return totalNumberOfItems * (loops ? numberOfLoops : 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        var normalizedIndexPath = indexPath
        if loops {
            normalizedIndexPath = IndexPath(row: indexPath.row % totalNumberOfItems, section: 0)
        }
        return customDatasource!.cell(at: normalizedIndexPath.row, for: self)
    }
}

extension CustomCollectionView: UICollectionViewDelegate
{
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidth = layout.itemSize.width + layout.minimumInteritemSpacing
        
        let page: CGFloat
        let snapDelta: CGFloat = 0.7
        let proposedPage = (targetContentOffset.pointee.x + contentInset.left - layout.minimumInteritemSpacing) / cellWidth
        
        if floor(proposedPage + snapDelta) == floor(proposedPage) && scrollView.contentOffset.x <= targetContentOffset.pointee.x {
            page = floor(proposedPage)
        } else {
            page = floor(proposedPage + 1)
        }
        
        targetContentOffset.pointee = CGPoint(
            x: cellWidth * page - contentInset.left,
            y: targetContentOffset.pointee.y
        )
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidth = layout.itemSize.width + layout.minimumInteritemSpacing
        var page = Int(round((scrollView.contentOffset.x + contentInset.left - layout.minimumInteritemSpacing) / cellWidth))
        if loops {
            page = page % totalNumberOfItems
        }
        page = min(max(0, page), totalNumberOfItems - 1)
        customDelegate?.itemSelected(for: self, at: page)
    }
}
