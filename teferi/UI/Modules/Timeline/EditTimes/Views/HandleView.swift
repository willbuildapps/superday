import UIKit
import SnapKit

class HandleView: UIView
{
    var color: UIColor = UIColor.gray {
        didSet {
            line.backgroundColor = color
            topHandle.backgroundColor = color
            bottomHandle.backgroundColor = color
        }
    }
    override func awakeFromNib()
    {
        super.awakeFromNib()
        setup()
    }
    
    private let line = UIView()
    private let topHandle = UIView()
    private let bottomHandle = UIView()
    
    private func setup()
    {
        backgroundColor = UIColor.clear
        
        line.backgroundColor = color
        line.layer.cornerRadius = 1
        addSubview(line)
        
        topHandle.backgroundColor = color
        topHandle.layer.cornerRadius = 2
        addSubview(topHandle)
        
        bottomHandle.backgroundColor = color
        bottomHandle.layer.cornerRadius = 2
        addSubview(bottomHandle)
        
        line.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(2)
            make.centerY.equalToSuperview()
        }
        
        topHandle.snp.makeConstraints { make in
            make.width.equalTo(24)
            make.height.equalTo(4)
            make.centerX.equalToSuperview()
            make.centerY.equalTo(line.snp.centerY).offset(5)
        }
        
        bottomHandle.snp.makeConstraints { make in
            make.width.equalTo(24)
            make.height.equalTo(4)
            make.centerX.equalToSuperview()
            make.centerY.equalTo(line.snp.centerY).offset(-5)
        }
    }
}
