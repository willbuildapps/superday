import UIKit

class GoalHeader: UIView
{
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var categoryBackground: UIView!
    @IBOutlet private weak var categoryImageView: UIImageView!
    @IBOutlet private(set) weak var newGoalButton: UIButton!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!
    
    func configure(withGoal goal: Goal?, message: String?)
    {
        if let goal = goal
        {
            if let message = message
            {
                textLabel.text = message
                
                categoryBackground.backgroundColor = .clear
                categoryImageView.image = nil
            }
            else
            {
                let components = elapsedTimeComponents(for: goal.targetTime)
                textLabel.text = "Today i want to\nspend \(components.hour!) hours on"
                textLabel.sizeToFit()
                
                categoryBackground.backgroundColor = goal.category.color
                categoryImageView.image = goal.category.icon.image
            }
            
            separatorView.isHidden = true
            newGoalButton.isHidden = true
            
            bottomConstraint.constant = 0
        }
        else
        {
            textLabel.text = "What do you want to\nachieve today?"
            textLabel.sizeToFit()
            
            categoryBackground.backgroundColor = .clear
            categoryImageView.image = nil
            
            separatorView.isHidden = false
            newGoalButton.isHidden = false
            
            bottomConstraint.constant = 70
        }
        
        updateConstraintsIfNeeded()
        layoutIfNeeded()
    }
    
    class func fromNib() -> GoalHeader
    {
        let voteView = Bundle.main.loadNibNamed("GoalHeader", owner: nil, options: nil)![0] as! GoalHeader
        return voteView
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        translatesAutoresizingMaskIntoConstraints = false

        categoryBackground.layer.cornerRadius = categoryBackground.frame.size.width / 2
    }
}
