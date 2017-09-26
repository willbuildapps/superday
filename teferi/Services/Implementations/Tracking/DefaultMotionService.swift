import Foundation
import CoreMotion
import RxSwift


class DefaultMotionService: MotionService
{
    let motionActivityManager: CMMotionActivityManager
    
    var motionAuthorizationGranted: Observable<Bool>
    {
        return Observable<Bool>.create { [unowned self] observer in
            
            self.motionActivityManager.queryActivityStarting(from: Date().addingTimeInterval(-24*60*60), to: Date(), to: OperationQueue.main) { activities, error in
                if let _ = error {
                    observer.onNext(false)
                } else {
                    observer.onNext(true)
                }
                observer.onCompleted()
            }
            
            return Disposables.create {}
        }
    }
    
    init ()
    {
        motionActivityManager = CMMotionActivityManager()
    }
    
    func askForAuthorization()
    {
        motionActivityManager.queryActivityStarting(from: Date().addingTimeInterval(-24*60*60), to: Date(), to: OperationQueue.main) { _ in }
    }
    
    func getActivities(since start: Date, until end: Date) -> Observable<[MotionEvent]>
    {
        guard CMMotionActivityManager.isActivityAvailable() else {
            return Observable.error(MotionServiceError.notAvailable)
        }
        
        return Observable.create { [unowned self] observer in
            
            self.motionActivityManager.queryActivityStarting(from: start, to: end, to: OperationQueue.current ?? OperationQueue(), withHandler: { (activities, error) in
                guard error == nil else {
                    observer.onError(error!)
                    return
                }
                
                var events = activities!
                    .reduce([MotionEvent](), { acc, activity in
                        guard activity.confidence == CMMotionActivityConfidence.high || activity.confidence == CMMotionActivityConfidence.medium else {
                            return acc
                        }
                        
                        let newEvent = MotionEvent.from(activity: activity)
                        
                        guard let last = acc.last else {
                            return [newEvent]
                        }
                        
                        if last.type == newEvent.type {
                            return Array(acc.dropLast()) + [last.with(end: newEvent.start)]
                        }
                        
                        return Array(acc.dropLast()) + [last.with(end: newEvent.start), newEvent]
                    })
                
                guard let last = events.last else {
                    observer.onError(MotionServiceError.noActivities)
                    return
                }
                
                events = Array(events.dropLast()) + [last.with(end: end)]
                observer.onNext(events)
                observer.onCompleted()
            })
            
            return Disposables.create {
                
            }
        }
    }
}

fileprivate extension MotionEvent
{
    static func from(activity: CMMotionActivity) -> MotionEvent
    {
        var type: MotionEventType = .other
        if activity.automotive {
            type = .auto
        } else {
            if activity.running {
                type = .run
            } else {
                if activity.cycling {
                    type = .cycling
                } else {
                    if activity.walking {
                        type = .walk
                    } else {
                        if activity.stationary {
                            type = .still
                        }
                    }
                }
            }
        }
        
        return MotionEvent(start: activity.startDate,
                           end: activity.startDate,
                           type: type)
    }
}
