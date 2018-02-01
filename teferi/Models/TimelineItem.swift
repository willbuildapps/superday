import Foundation
import RxDataSources

enum TimelineItem : IdentifiableType, Equatable
{
    case slot(item: SlotTimelineItem)
    case commuteSlot(item: SlotTimelineItem)
    case expandedCommuteTitle(item: SlotTimelineItem)
    case expandedTitle(item: SlotTimelineItem)
    case expandedSlot(item: SlotTimelineItem, hasSeparator: Bool)
    case collapseButton(color: UIColor)
    
    var identity: String
    {
        switch self {
        case .slot(let item),
             .commuteSlot(let item),
             .expandedSlot(let item, _):
            return item.startTime.description
        case .expandedCommuteTitle(let item):
            return item.startTime.description + "commuteTitle"
        case .expandedTitle(let item):
            return item.startTime.description + "expandedTitle"
        case .collapseButton(let color):
            return color.hexString + "expandedCollapse"
        }
    }
    
    static func == (lhs: TimelineItem, rhs: TimelineItem) -> Bool
    {
        switch (lhs, rhs) {
        case (.slot(let lhsItem), .slot(let rhsItem)),
             (.expandedSlot(let lhsItem, _), .expandedSlot(let rhsItem, _)),
             (.commuteSlot(let lhsItem), .commuteSlot(let rhsItem)):
            return lhsItem.duration == rhsItem.duration
                && lhsItem.isRunning == rhsItem.isRunning
                && lhsItem.elapsedTimeText == rhsItem.elapsedTimeText
                && lhsItem.category == rhsItem.category
                && lhsItem.containsMultiple == rhsItem.containsMultiple
        case (.expandedTitle(let lhsItem), .expandedTitle(let rhsItem)),
             (.expandedCommuteTitle(let lhsItem), .expandedCommuteTitle(let rhsItem)):
            return lhsItem.category == rhsItem.category
                && lhsItem.duration == rhsItem.duration
        case (.collapseButton(let lhsColor), .collapseButton(let rhsColor)):
            return lhsColor == rhsColor
        default:
            return false
        }
    }
}
