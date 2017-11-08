import UIKit

class CategoryWithNameView: UIView
{
    @IBOutlet private weak var categoryNameLabel: UILabel!
    @IBOutlet private weak var categoryBackgroundvView: UIView!
    @IBOutlet private weak var categoryImageView: UIImageView!
    
    var category: Category?
    {
        didSet
        {
            guard let category = category else { return }
            
            categoryNameLabel.text = category.description.capitalized
            categoryNameLabel.textColor = category.color
            categoryImageView.image = category.icon.image
            categoryBackgroundvView.backgroundColor = category.color
        }
    }
    
    class func fromNib() -> CategoryWithNameView
    {
        let voteView = Bundle.main.loadNibNamed("CategoryWithNameView", owner: nil, options: nil)![0] as! CategoryWithNameView
        return voteView
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        categoryBackgroundvView.layer.cornerRadius = categoryBackgroundvView.bounds.width / 2
    }
}
