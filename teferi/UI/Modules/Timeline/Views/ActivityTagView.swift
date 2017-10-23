import UIKit
import SnapKit

class ActivityTagView: UIView
{
    private let activityLabel = UILabel()
    private let numberLabel = UILabel()
    private let nameBackgroundView = UIView()
    private let numberBackgroundView = UIView()
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        activityLabel.textColor = Category.commute.color
        activityLabel.font = UIFont.boldSystemFont(ofSize: 12)
        numberLabel.textColor = Category.commute.color
        numberLabel.font = UIFont.boldSystemFont(ofSize: 12)

        layer.cornerRadius = 8
        clipsToBounds = true
        
        nameBackgroundView.backgroundColor = UIColor.lightBlue
        numberBackgroundView.backgroundColor = UIColor.lightBlue2
        
        addSubview(nameBackgroundView)
        addSubview(numberBackgroundView)
        nameBackgroundView.addSubview(activityLabel)
        numberBackgroundView.addSubview(numberLabel)
    }
    
    override func updateConstraints()
    {
        let numberIsHidden = numberBackgroundView.isHidden
        
        nameBackgroundView.snp.removeConstraints()
        numberBackgroundView.snp.removeConstraints()
        activityLabel.snp.removeConstraints()
        numberLabel.snp.removeConstraints()
        
        nameBackgroundView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.right.equalTo(numberBackgroundView.snp.left)
        }
        
        numberBackgroundView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            if numberIsHidden {
                make.leading.equalTo(self.snp.trailing)
            } else {
                make.trailing.equalToSuperview()
            }
        }
        
        activityLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(6)
            make.trailing.equalToSuperview().inset(numberIsHidden ? 6 : 2)
            make.centerY.equalToSuperview()
        }
        
        numberLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(4)
            make.trailing.equalToSuperview().inset(6)
            make.centerY.equalToSuperview()
        }
        
        super.updateConstraints()
    }
    
    func configure(name: String, amount: Int = 1)
    {
        numberBackgroundView.isHidden = amount <= 1        
        activityLabel.text = name
        numberLabel.text = String(amount)
        
        setNeedsUpdateConstraints()
    }
}
