import Foundation
import XCTest
import Nimble
@testable import teferi

class SlotTimelineItem_TimelineCellTests: XCTestCase
{
    func testTheTimelineCellLineHeightIsHigherForLongerItems()
    {
        let now = Date()
        
        var timeslots = [
            TimeSlot(startTime: now, endTime: now.addingTimeInterval(150 * 60), category: .work)
        ]
        let item1 = SlotTimelineItem(timeSlots: timeslots)
        
        timeslots = [
            TimeSlot(startTime: now, endTime: now.addingTimeInterval(300 * 60), category: .work),
        ]
        let item2 = SlotTimelineItem(timeSlots: timeslots)
        
        expect(item1.lineHeight).to(beLessThan(item2.lineHeight))
    }
    
    func testTheTimelineCellLineHeightCantBeShorterThan16()
    {
        let now = Date()
        
        let timeslots = [
            TimeSlot(startTime: now, endTime: now.addingTimeInterval(15), category: .work),
            ]
        let item = SlotTimelineItem(timeSlots: timeslots)
        
        expect(item.lineHeight).to(equal(16))
    }
    
    func testTimeSlotTextMatchesStartTime()
    {
        let startTime = Date()
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let expected = formatter.string(from: startTime)
        
        let timeslots = [
            TimeSlot(startTime: startTime, endTime: startTime.addingTimeInterval(15 * 60), category: .work),
        ]
        let item = SlotTimelineItem(timeSlots: timeslots)
        
        expect(item.slotTimeText).to(equal(expected))
    }
    
    func testTimeSlotTextMatchesStartAndEndTimeForLastSlotInLastDay()
    {
        let startTime = Date().yesterday.ignoreTimeComponents()
        let endTime = startTime.addingTimeInterval(2*60*60)
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let startText = formatter.string(from: startTime)
        let endText = formatter.string(from: endTime)
        let expectedText = "\(startText) - \(endText)"
        
        let timeslots = [
            TimeSlot(startTime: startTime, endTime: endTime, category: .work)
        ]
        let item = SlotTimelineItem(timeSlots: timeslots, isLastInPastDay: true)
        
        expect(item.slotTimeText).to(equal(expectedText))
    }
    
    func testTheElapsedTimeLabelShowsOnlyMinutesWhenLessThanAnHourHasPassed()
    {
        let startTime = Date()
        let duration: TimeInterval = 2000

        let minuteMask = "%02d min"
        let minutes = (Int(duration) / 60) % 60
        let expectedText = String(format: minuteMask, minutes)
        
        let timeslots = [
            TimeSlot(startTime: startTime, endTime: startTime.addingTimeInterval(duration), category: .work),
            ]
        let item = SlotTimelineItem(timeSlots: timeslots)
        
        expect(item.elapsedTimeText).to(equal(expectedText))
    }
    
    func testTheElapsedTimeLabelShowsHoursAndMinutesWhenOverAnHourHasPassed()
    {
        let startTime = Date()
        let duration: TimeInterval = 5000
        
        let hourMask = "%01d h %01d min"
        let minutes = (Int(duration) / 60) % 60
        let hours = (Int(duration) / 3600)
        let expectedText = String(format: hourMask, hours, minutes)
        
        let timeslots = [
            TimeSlot(startTime: startTime, endTime: startTime.addingTimeInterval(duration), category: .work)
            ]
        let item = SlotTimelineItem(timeSlots: timeslots)
        
        expect(item.elapsedTimeText).to(equal(expectedText))
    }
    
    func testTheDescriptionMatchesTheBoundTimeSlot()
    {
        let startTime = Date()
        
        let timeslots = [
            TimeSlot(startTime: startTime, endTime: startTime.addingTimeInterval(15 * 60), category: .work),
            ]
        let item = SlotTimelineItem(timeSlots: timeslots)
        
        expect(item.slotDescriptionText).to(equal(item.category.description))
    }
    
    func testTheDescriptionHasNoTextWhenTheCategoryIsUnknown()
    {
        let startTime = Date()
        
        let timeslots = [
            TimeSlot(startTime: startTime, endTime: startTime.addingTimeInterval(15*50), category: .unknown),
            ]
        let item = SlotTimelineItem(timeSlots: timeslots)
        
        expect(item.slotDescriptionText).to(equal(""))
    }
    
    func testNoCategoryIsShownIfTheTimeSlotHasThePropertyShouldDisplayCategoryNameSetToFalse()
    {
        let startTime = Date()
        
        let timeslots = [
            TimeSlot(startTime: startTime, endTime: startTime.addingTimeInterval(15*60), category: .unknown),
            ]
        let item = SlotTimelineItem(timeSlots: timeslots, shouldDisplayCategoryName: false)
        
        expect(item.slotDescriptionText).to(equal(""))
    }
}
