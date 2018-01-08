import Foundation
import UIKit
import SnapKit

class AddGoalAlert: Alert
{
    let tapClosure: () -> ()
    
    init(inViewController viewController: UIViewController?, tapClosure: @escaping () -> ())
    {
        self.tapClosure = tapClosure
        super.init(inViewController: viewController)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func buildContentView() -> UIView
    {
        let btn = UIButton()
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        btn.setTitle("Set a goal", for: .normal)
        btn.backgroundColor = UIColor.familyGreen
        btn.layer.cornerRadius = 14
        btn.isUserInteractionEnabled = false
        
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.almostBlack
        label.text = "What do you want to achieve today?"
        
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        container.addSubview(label)
        container.addSubview(btn)
        
        label.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(14)
            make.trailing.equalTo(btn.snp.leading).offset(-27)
        }
        
        btn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(15)
            make.height.equalTo(28)
            make.width.equalTo(92)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(AddGoalAlert.tap))
        container.addGestureRecognizer(tap)
        
        return container
    }
    
    @objc private func tap()
    {
        hide()
        tapClosure()
    }
}
