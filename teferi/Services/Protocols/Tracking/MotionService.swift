import RxSwift

enum MotionServiceError: Error
{
    case motionNotAvailable
    case noMotionActivities
}

protocol MotionService
{
    var motionAuthorizationGranted: Observable<Bool> { get }

    func askForAuthorization()
    func getActivities(since start: Date, until end: Date) -> Observable<[MotionEvent]>
}
