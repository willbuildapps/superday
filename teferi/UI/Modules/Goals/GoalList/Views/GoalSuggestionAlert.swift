import Foundation
import UIKit
import SnapKit

class GoalSuggestionAlert: Alert
{
    private let text: String
    
    init(inViewController viewController: UIViewController?, text: String)
    {
        self.text = text
        super.init(inViewController: viewController)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func buildContentView() -> UIView
    {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.almostBlack
        label.text = text
        
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        container.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(14)
        }
        
        return container
    }
}

