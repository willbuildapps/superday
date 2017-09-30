import Foundation
import RxSwift

class CMAccessForExistingUsersViewModel
{
    // MARK: Public Properties
    
    private(set) lazy var hideOverlayObservable : Observable<Void> =
    {
        return self.motionService.motionAuthorizationGranted
            .mapTo(())
    }()

    // MARK: Private Properties

    private let settingsService : SettingsService
    private let motionService : MotionService

    // MARK: Initializers

    init(settingsService: SettingsService,
         motionService: MotionService)
    {
        self.settingsService = settingsService
        self.motionService = motionService
    }
}
