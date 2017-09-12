import Foundation

enum LifecycleEvent:Equatable
{
    case movedToForeground(withDailyVotingNotificationDate: Date?)
    case movedToBackground
}

func == (lhs:LifecycleEvent, rhs:LifecycleEvent) -> Bool
{
    switch (lhs, rhs) {
    case (.movedToForeground(_), .movedToForeground(_)):
        return true
    case (.movedToBackground, .movedToBackground):
        return true
    default:
        return false
    }
}
