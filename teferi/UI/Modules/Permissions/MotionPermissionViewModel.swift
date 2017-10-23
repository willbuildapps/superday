import RxSwift
import Foundation

class MotionPermissionViewModel : PermissionViewModel
{
    // MARK: Public Properties
    var isSecondaryButtonHidden : Bool
    {
        return true
    }
    
    var titleText : String?
    {
        return self.isFirstTimeUser ? self.titleFirstUse : self.title
    }
    
    var descriptionText : String
    {
        return self.isFirstTimeUser ? self.disabledDescriptionFirstUse : self.disabledDescription
    }
    
    var enableButtonTitle : String
    {
        return L10n.motionEnableButtonTitle
    }
    
    var secondaryButtonTitle : String?
    {
        return nil
    }
    
    var image : UIImage?
    {
        return nil
    }
    
    var permissionGivenObservable : Observable<Void>
    {
        return self.appLifecycleService
            .movedToForegroundObservable
            .map { [unowned self] in
                return self.settingsService.hasCoreMotionPermission
            }
            .filter{ $0 }
            .mapTo(())
    }
    
    private(set) lazy var hideOverlayObservable : Observable<Void> =
    {
        return self.appLifecycleService.movedToForegroundObservable
            .map(self.overlayVisibilityState)
            .filter{ !$0 }
            .mapTo(())
    }()
    
    // MARK: Private Properties
    private let title = L10n.motionDisabledTitle
    private let titleFirstUse = L10n.motionDisabledTitleFirstUse
    private let disabledDescription = L10n.motionDisabledDescription
    private let disabledDescriptionFirstUse = L10n.motionDisabledDescriptionFirstUse
    
    private let settingsService : SettingsService
    private let appLifecycleService : AppLifecycleService
    
    private let disposeBag = DisposeBag()
    
    private var isFirstTimeUser : Bool { return !self.settingsService.userEverGaveMotionPermission }
    
    // MARK: Initializers
    init(settingsService: SettingsService,
         appLifecycleService : AppLifecycleService)
    {
        self.settingsService = settingsService
        self.appLifecycleService = appLifecycleService
    }
    
    // MARK: Public Methods
    
    func getUserPermission()
    {
        settingsService.setCoreMotionPermission(userGavePermission: true)

        let url = URL(string: UIApplicationOpenSettingsURLString)!
        UIApplication.shared.openURL(url)
    }
    
    func permissionGiven() {}
    
    func secondaryAction() {}
    
    // MARK: Private Methods
    
    private func overlayVisibilityState() -> Bool
    {
        return !settingsService.hasCoreMotionPermission
    }
}

