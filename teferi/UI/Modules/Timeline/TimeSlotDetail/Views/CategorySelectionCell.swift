import UIKit

class CategorySelectionCell: UITableViewCell
{
    static let cellIdentifier = "categorySelectionCell"
    
    private(set) var editView : EditTimeSlotView!
    private var slotTimelineItem : SlotTimelineItem!

    func configure(with categoryProvider: CategoryProvider, slotTimelineItem: SlotTimelineItem)
    {
        self.slotTimelineItem = slotTimelineItem
        
        if editView == nil
        {
            editView = EditTimeSlotView(categoryProvider: categoryProvider)
            editView.backgroundColor = .clear
            contentView.addSubview(editView)
            editView.constrainEdges(to: contentView)
        }
        
        editView.onEditBegan(point: CGPoint(x: 0, y: 34), slotTimelineItem: slotTimelineItem, hideCurrentCategory: false)
        editView.backgroundColor = .clear
    }
}
