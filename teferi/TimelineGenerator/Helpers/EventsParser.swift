import Foundation

class EventsParser
{
    let passes: [TimelineProcessingPass] = [
        TimelineProcessingPass.filterPass(types: [.other]),
        TimelineProcessingPass.mergePass(types: nil, maxDuration: 60 * 30),
        TimelineProcessingPass.filterPass(types: [.still, .run, .cycling], minDuration: 60 * 3),
        TimelineProcessingPass.mergePass(types: nil, maxDuration: 60 * 60),
        TimelineProcessingPass.filterPass(types: [.walk], minDuration: 60 * 3),
        TimelineProcessingPass.mergePass(types: [.run, .cycling, .auto], maxDuration: 60 * 60 * 3),
        TimelineProcessingPass.filterPass(types: nil, minDuration: 60 * 5),
    ]
    
    func parse(events: [AnnotatedEvent]) -> [AnnotatedEvent]
    {
        var auxEvents = events
        
        for pass in passes {
            switch pass.passType {
            case .merge(let maximumDuration):
                auxEvents = groupEvents(types: pass.eventTypes, maxDuration: maximumDuration, events: auxEvents)
            case .filter(let minimumDuration):
                auxEvents = filterEvents(types: pass.eventTypes, minDuration: minimumDuration, events: auxEvents)
            }
        }
        
        return auxEvents
    }
    
    private func groupEvents(types:[MotionEventType]?, maxDuration: TimeInterval, events: [AnnotatedEvent]) -> [AnnotatedEvent]
    {
        let grouped = events
            .splitBy{ event1, event2 in
                return event1.canBeMergedWith(event: event2)
                    && event1.duration < maxDuration && event2.duration < maxDuration
                    && (types == nil || types!.index(of: event1.type) != nil)
        }
        
        return grouped
            .map { eventsGroup -> AnnotatedEvent in
                let firstEvent = eventsGroup.first!
                guard eventsGroup.count > 1 else {
                    return firstEvent
                }
                return eventsGroup.reduce(firstEvent, { result, newEvent in
                    return result.merging(newEvent)
                })
        }
    }
    
    private func filterEvents(types: [MotionEventType]?, minDuration: TimeInterval, events: [AnnotatedEvent]) -> [AnnotatedEvent]
    {
        return events
            .reduce([AnnotatedEvent](), { acc, event in
                
                if event.duration < minDuration
                    && (types == nil || types!.index(of: event.type) != nil) {
                    guard let last = acc.last else {
                        return acc
                    }
                    return Array(acc.dropLast()) + [last.merging(event)]
                }
                
                return acc + [event]
                
            })
    }
}
