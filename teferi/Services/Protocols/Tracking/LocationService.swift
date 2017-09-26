import RxSwift

protocol LocationService : EventSource
{
    var alwaysAuthorizationGranted: Observable<Bool> { get }

    func requestAuthorization()
    func startLocationTracking()
    func getLastKnownLocation() -> Location?
}
