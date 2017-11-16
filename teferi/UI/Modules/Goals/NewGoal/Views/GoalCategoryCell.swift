import UIKit

class GoalCategoryCell: UICollectionViewCell
{    
    @IBOutlet weak var categoryBackgroundView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var category: Category? {
        didSet {
            configure()
        }
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        categoryBackgroundView.layer.cornerRadius = categoryBackgroundView.frame.width / 2
        iconImageView.contentMode = .center
    }
    
    private func configure()
    {
        guard let category = category else { return }
        
        contentView.backgroundColor = UIColor.white
        backgroundColor = UIColor.white
        
        categoryBackgroundView.backgroundColor = category.color
        iconImageView.image = category.icon.image
        nameLabel.text = category.description
        nameLabel.textColor = category.color
    }
}
