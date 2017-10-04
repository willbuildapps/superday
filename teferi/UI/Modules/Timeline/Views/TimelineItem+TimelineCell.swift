import Foundation
import CoreGraphics

extension TimelineItem
{
    var lineHeight: CGFloat
    {
        let minutes = duration / 60
        let height: Double
        
        if minutes <= 60 {
            height = 8/(15*minutes) + 120/15
        } else {
            height = (480 + minutes) / 13.5
        }

        return CGFloat(max(height, 16))
    }
    
    var slotTimeText: String
    {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        let startString = formatter.string(from: startTime)
        
        if isLastInPastDay, let endTime = endTime {
            let endString = formatter.string(from: endTime)
            return startString + " - " + endString
        } else {
            return startString
        }
    }
    
    var elapsedTimeText: String
    {
        let hourMask = "%02d h %02d min"
        let minuteMask = "%02d min"

        let minutes = (Int(duration) / 60) % 60
        let hours = (Int(duration) / 3600)
        
        return hours > 0 ? String(format: hourMask, hours, minutes) : String(format: minuteMask, minutes)
    }
    
    var slotDescriptionText: String
    {
        guard shouldDisplayCategoryName && category != .unknown else {
            return ""
        }

        return category.description
    }
}
