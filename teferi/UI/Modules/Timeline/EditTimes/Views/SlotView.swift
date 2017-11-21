import UIKit
import SnapKit

class SlotView: UIView
{
    var category: Category = .unknown {
        didSet {
            lineView.backgroundColor = category.color
            durationLabel.textColor = category.color
            categoryLabel.text = category.description
            deleteIconView.tintColor = category.color
        }
    }
    
    var startTime: String = "" {
        didSet {
            startLabel.text = startTime
        }
    }

    var duration: TimeInterval = 0 {
        didSet {
            durationLabel.text = formatedElapsedTimeText(for: duration)
            
            if duration < 60 {
                UIView.animate(withDuration: 0.3, animations: setDeletionState(true))
            } else if oldValue < 60 {
                UIView.animate(withDuration: 0.3, animations: setDeletionState(false))
            }
        }
    }
    
    private let lineView = UIView()
    private let categoryLabel = UILabel()
    private let startLabel = UILabel()
    private let durationLabel = UILabel()
    private let redOverlay = UIView()
    private let deleteIconView = UIImageView(image: UIImage(named: "icDelete")?.withRenderingMode(.alwaysTemplate))
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        backgroundColor = UIColor.clear
        
        lineView.layer.cornerRadius = 2
        deleteIconView.contentMode = .center
        
        categoryLabel.font = UIFont.boldSystemFont(ofSize: 14)
        categoryLabel.textColor = UIColor.almostBlack
        
        startLabel.font = UIFont.systemFont(ofSize: 14)
        startLabel.textColor = UIColor.normalGray
        
        durationLabel.font = UIFont.boldSystemFont(ofSize: 14)
        durationLabel.textColor = category.color
        
        redOverlay.backgroundColor = UIColor.white
        redOverlay.alpha = 0
        
        deleteIconView.tintColor = category.color
        
        addSubview(lineView)
        addSubview(categoryLabel)
        addSubview(startLabel)
        addSubview(durationLabel)
        addSubview(redOverlay)
        addSubview(deleteIconView)
        
        lineView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(4)
        }
        
        categoryLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(deleteIconView.snp.trailing).offset(4)
        }
        
        startLabel.snp.makeConstraints { make in
            make.centerY.equalTo(categoryLabel.snp.centerY)
            make.leading.equalTo(categoryLabel.snp.trailing).offset(6)
        }
        
        durationLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel.snp.bottom).offset(4)
            make.leading.equalTo(categoryLabel.snp.leading)
        }
        
        redOverlay.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        deleteIconView.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.top.equalToSuperview().offset(6)
            make.leading.equalTo(lineView.snp.trailing).offset(-20)
        }
        
        self.setNeedsLayout()
    }

    private func setDeletionState(_ toBeDeleted: Bool) -> () -> ()
    {
        return {
            self.redOverlay.alpha = toBeDeleted ? 0.8 : 0
            self.deleteIconView.alpha = toBeDeleted ? 1 : 0
            self.deleteIconView.snp.updateConstraints { make in
               make.leading.equalTo(self.lineView.snp.trailing).offset(toBeDeleted ? 4 : -20)
            }
            self.layoutIfNeeded()
        }
    }
}
