import UIKit

class ShortTimelineCell: UITableViewCell
{
    static let cellIdentifier = "shortTimelineCell"
    
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var activityTag: ActivityTagView!
    
    private(set) var slotTimelineItem: SlotTimelineItem?
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        startLabel.textColor = UIColor.normalGray
    }
    
    func configure(slotTimelineItem: SlotTimelineItem, showStartAndDuration: Bool = true)
    {
        self.slotTimelineItem = slotTimelineItem
        
        startLabel.text = showStartAndDuration ? slotTimelineItem.slotTimeText : nil
        durationLabel.text = showStartAndDuration ? slotTimelineItem.elapsedTimeText : nil
        durationLabel.textColor = slotTimelineItem.category.color
        
        activityTag.configure(name: slotTimelineItem.activityTagText ?? L10n.movement, amount: slotTimelineItem.timeSlots.count)
    }
}
