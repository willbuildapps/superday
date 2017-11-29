import UIKit

class GoalTimeCell: UICollectionViewCell
{
    @IBOutlet weak var timeLabel: UILabel!
    
    var goalTime: GoalTime? {
        didSet {
            configure()
        }
    }
    
    private func configure()
    {
        guard let goalTime = goalTime else { return }
        timeLabel.text = goalTime.durationString
    }
}
