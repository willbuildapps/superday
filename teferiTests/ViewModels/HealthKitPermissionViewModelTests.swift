import RxSwift
import XCTest
import Nimble
@testable import teferi

class HealthKitPermissionViewModelTests : XCTestCase
{
    private var viewModel : PermissionViewModel!
    private var disposable : Disposable? = nil
    
    private var timeService : MockTimeService!
    private var settingsService : MockSettingsService!
    private var appLifecycleService : MockAppLifecycleService!
    private var healthKitService : MockHealthKitService!
    
    override func setUp()
    {
        timeService = MockTimeService()
        settingsService = MockSettingsService()
        appLifecycleService = MockAppLifecycleService()
        healthKitService = MockHealthKitService()
        
        viewModel = HealthKitPermissionViewModel(timeService: timeService,
                                                      settingsService: settingsService,
                                                      appLifecycleService: appLifecycleService,
                                                      healthKitService: healthKitService)
    }
    
    override func tearDown()
    {
        disposable?.dispose()
    }
    
    func testPermissionShouldShowNonBlockingOverlayIfUserAlreadyGavePermission()
    {
        settingsService.hasLocationPermission = false
        
        viewModel.permissionGiven()
        
        appLifecycleService.publish(.movedToForeground(withDailyVotingNotificationDate: nil))
        
        expect(self.viewModel.remindMeLater).to(beFalse())
    }
}
