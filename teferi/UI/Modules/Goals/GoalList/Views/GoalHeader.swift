import UIKit

class GoalHeader: UIView
{
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var categoryBackground: UIView!
    @IBOutlet private weak var categoryImageView: UIImageView!
    @IBOutlet private(set) weak var newGoalButton: UIButton!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!
    
    func configure(withViewModel viewModel: GoalViewModel, andGoal goal: Goal?)
    {
        let messageAndVisibilityFlags = viewModel.messageAndCategoryVisibility(forGoal: goal)
        
        textLabel.text = messageAndVisibilityFlags.message
        
        if messageAndVisibilityFlags.newGoalButtonVisible
        {
            separatorView.isHidden = false
            newGoalButton.isHidden = false
            
            bottomConstraint.constant = 70
        }
        else
        {
            separatorView.isHidden = true
            newGoalButton.isHidden = true
            
            bottomConstraint.constant = 0
        }
        
        if let goal = goal, messageAndVisibilityFlags.categoryVisible
        {
            categoryBackground.backgroundColor = goal.category.color
            categoryImageView.image = goal.category.icon.image
        }
        else
        {
            categoryBackground.backgroundColor = .clear
            categoryImageView.image = nil
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
