import UIKit
import RxSwift

class CollapseCell: UITableViewCell
{
    static let cellIdentifier = "CollapseCell"
    
    @IBOutlet private weak var collapseImageView: UIImageView!
    @IBOutlet private weak var collapseButton : UIButton!
    
    var collapseObservable : Observable<Void> {
        return self.collapseButton.rx.tap.asObservable()
    }
    
    private(set) var disposeBag = DisposeBag()
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    func configure(color: UIColor)
    {
        collapseImageView.image = collapseImageView.image!.withRenderingMode(.alwaysTemplate)
        collapseImageView.tintColor = color
    }
}
