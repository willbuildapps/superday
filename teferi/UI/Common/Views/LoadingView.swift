import UIKit
import SnapKit

class LoadingView: UIView
{    
    private let backgroundView = UIView()
    private let loadingIndicator = LoadingIndicator()
    private let label = UILabel()
    
    var text: NSAttributedString? = nil {
        didSet {
            label.attributedText = text
        }
    }
    
    init()
    {
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        backgroundView.backgroundColor = UIColor(white: 1.0, alpha: 0.9)
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.almostBlack
        
        addSubview(backgroundView)
        addSubview(loadingIndicator)
        addSubview(label)
        
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.width.height.equalTo(16)
            make.centerX.centerY.equalToSuperview()
        }
        
        label.snp.makeConstraints { make in
            make.top.equalTo(loadingIndicator.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Public Methods
    
    func show()
    {
        guard let window = UIApplication.shared.windows.first else {
            return
        }
        
        if superview == nil {
            frame = window.bounds
            window.addSubview(self)
        }
        
        loadingIndicator.animateCircle()
        
        alpha = 0
        loadingIndicator.transform = CGAffineTransform(translationX: 0, y: 50)
        label.transform = CGAffineTransform(translationX: 0, y: 200)
        
        UIView.animate(
            withDuration: 0.6,
            delay: 0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.4,
            options: [],
            animations: { [unowned self] in
                self.alpha = 1.0
                self.loadingIndicator.transform = CGAffineTransform.identity
                self.label.transform = CGAffineTransform.identity
            },
            completion: nil)
    }
    
    func hide()
    {
        guard let _ = superview else { return }
        
        UIView.animate(
            withDuration: 0.3,
            animations: { [unowned self] in
                self.alpha = 0.0
            },
            completion: { _ in
                self.removeFromSuperview()
            })
    }
}

extension LoadingView
{
    static var locating: LoadingView = {
        let loadingView = LoadingView()
        
        let textAttachment = NSTextAttachment()
        textAttachment.image = #imageLiteral(resourceName: "icEmojiNerd")
        textAttachment.bounds = CGRect(x: 0.0, y: UIFont.systemFont(ofSize: 12).descender, width: textAttachment.image!.size.width, height: textAttachment.image!.size.height)
        let text = NSMutableAttributedString(string: "Finding your location... ")
        text.append(NSAttributedString(attachment: textAttachment))
        
        loadingView.text = text
        
        return loadingView
    }()
    
    static var generating: LoadingView = {
        let loadingView = LoadingView()
        
        let textAttachment = NSTextAttachment()
        textAttachment.image = #imageLiteral(resourceName: "icEmojiNerd")
        textAttachment.bounds = CGRect(x: 0.0, y: UIFont.systemFont(ofSize: 12).descender, width: textAttachment.image!.size.width, height: textAttachment.image!.size.height)
        let text = NSMutableAttributedString(string: "Generating your timeline... ")
        text.append(NSAttributedString(attachment: textAttachment))
        
        loadingView.text = text
        
        return loadingView
    }()
}
