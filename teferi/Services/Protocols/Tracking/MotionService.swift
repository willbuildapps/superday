import RxSwift

enum MotionServiceError: Error
{
    case notAvailable
    case noActivities
}

protocol MotionService
{
    func askForAuthorization()
    func getActivities(since start: Date, until end: Date) -> Observable<[MotionEvent]>
}
