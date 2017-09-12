import RxSwift

protocol LocationService : EventSource
{
    func startLocationTracking()
    func getLastKnownLocation() -> Location?
}
