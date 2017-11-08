import UIKit

class GoalNavigationController: UINavigationController
{
    private var logoImageView : UIImageView!
    private var titleLabel : UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 120, height: 60))
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium)
        titleLabel.textColor = Style.Color.offBlack
        titleLabel.text = L10n.appName
        
        logoImageView = UIImageView(image: Image(asset: Asset.icSuperday))
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool)
    {
        super.pushViewController(viewController, animated: animated)
        
        setupNavigationBar(viewController: viewController)
    }
    
    private func setupNavigationBar(viewController: UIViewController)
    {
        let bigSpacing = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        bigSpacing.width = 18
        
        viewController.navigationItem.leftBarButtonItems = [
            UIBarButtonItem(customView: logoImageView),
            bigSpacing,
            UIBarButtonItem(customView: titleLabel)
        ]
    }
}
