import UIKit

class ExpandedTimelineCell: UITableViewCell
{
    static let cellIdentifier = "ExpandedTimelineCell"
    
    private(set) var item: SlotTimelineItem? = nil
    
    @IBOutlet private weak var lineView : LineView!
    @IBOutlet private weak var slotTime : UILabel!
    @IBOutlet private weak var elapsedTime : UILabel!
    @IBOutlet private weak var lineHeight: NSLayoutConstraint!
    @IBOutlet private weak var activityTagView: ActivityTagView!
    @IBOutlet private weak var separatorView : UIView!
    
    
    func configure(item: SlotTimelineItem, visibleSeparator: Bool)
    {
        self.item = item
        
        slotTime.text = item.startTime.formatedShortStyle
        
        layoutLine(withItem: item)
        
        elapsedTime.textColor = item.category.color
        elapsedTime.text = formatedElapsedTimeText(for: item.duration)
        
        setupActivityTag(withTagText: item.activityTagText)
        
        separatorView.isHidden = !visibleSeparator
    }
    
    private func layoutLine(withItem item: SlotTimelineItem)
    {
        lineHeight.constant = calculatedLineHeight(for: item.duration)
        lineView.color = item.category.color
        lineView.collapsed = false
        
        lineView.fading = false
        
        lineView.layoutIfNeeded()
    }
    
    private func setupActivityTag(withTagText tagText: String?)
    {
        guard let tagText = tagText else {
            activityTagView.isHidden = true
            return
        }
        
        activityTagView.isHidden = false
        activityTagView.configure(name: tagText)
    }
}
