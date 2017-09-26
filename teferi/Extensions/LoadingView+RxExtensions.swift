import RxSwift
import RxCocoa

extension Reactive where Base: LoadingView
{
    var isActive: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { view, active in
            if active {
                view.show()
            } else {
                view.hide()
            }
        }
    }
}

