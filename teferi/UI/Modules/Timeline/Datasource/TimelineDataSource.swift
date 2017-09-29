import RxDataSources
import Foundation

struct TimelineSection
{
    var items: [Item]
}

extension TimelineSection: AnimatableSectionModelType
{
    typealias Item = TimelineItem
    
    init(original: TimelineSection, items: [Item])
    {
        self = original
        self.items = items
    }
    
    var identity: String { return "" }
}

extension TimelineItem: IdentifiableType, Equatable
{
    var identity: Date {
        return startTime
    }
}

func == (lhs: TimelineItem, rhs: TimelineItem) -> Bool
{
    return lhs.category == rhs.category && lhs.isCollapsed == rhs.isCollapsed
        && lhs.hasCollapseButton == rhs.hasCollapseButton && lhs.isRunning == rhs.isRunning
        && lhs.elapsedTimeText == rhs.elapsedTimeText
}


class TimelineDataSource: RxTableViewSectionedAnimatedDataSource<TimelineSection>
{
    override init()
    {        
        super.init()
        
        self.animationConfiguration = AnimationConfiguration(
            insertAnimation: .fade,
            reloadAnimation: .fade,
            deleteAnimation: .fade
        )
        
    }
}
