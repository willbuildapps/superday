import RxSwift

protocol LocationService : EventSource
{
    var alwaysAuthorizationGranted: Observable<Bool> { get }
    var currentLocation: Observable<Location> { get }
    
    func requestAuthorization()
    func startLocationTracking()
    func getLastKnownLocation() -> Location?
}
