import RxDataSources
import Foundation

struct GoalSection
{
    var items: [Item]
}

extension GoalSection: AnimatableSectionModelType
{
    typealias Item = Goal
    
    init(original: GoalSection, items: [Item])
    {
        self = original
        self.items = items
    }
    
    var identity: String { return "" }
}

extension Goal: IdentifiableType, Equatable
{
    var identity: Date {
        return date
    }
}

func == (lhs: Goal, rhs: Goal) -> Bool
{
    return lhs.category == rhs.category
        && lhs.date == rhs.date
        && lhs.value == rhs.value
}

class GoalDataSource: RxTableViewSectionedAnimatedDataSource<GoalSection>
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
