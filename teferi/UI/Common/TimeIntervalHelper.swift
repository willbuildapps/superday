import UIKit

func calculatedLineHeight(for duration: TimeInterval) -> CGFloat
{
    let minutes = (duration > 1 ? duration : 1) / 60
    let height: Double
    let minHeight: Double = 16
    
    guard minutes > 0 else { return CGFloat(minHeight) }
    
    if minutes <= 60 {
        height = 8/(15*minutes) + 120/15
    } else {
        height = (480 + minutes) / 13.5
    }
    
    return CGFloat(max(height, minHeight))
}

func formatedElapsedTimeText(for duration: TimeInterval) -> String
{
    let hourMask = "%02d h %02d min"
    let minuteMask = "%02d min"

    let components = elapsedTimeComponents(for: duration)
    
    return components.hour! > 0 ?
        String(format: hourMask, components.hour!, components.minute!) :
        String(format: minuteMask, components.minute!)
}

func formatedElapsedTimeLongText(for duration: TimeInterval) -> String
{
    let components = elapsedTimeComponents(for: duration)
    guard let hours = components.hour, let minutes = components.minute else { return "0 hours" }
    
    if hours > 0 {
        if minutes > 0 {
            return String(format: "%.1f hours", (Double(hours) + Double(minutes) / 60))
        }
        
        if hours == 1 {
            return "1 hour"
        }
        return String(format: "%01d hours", hours)
    }
    
    if minutes == 1 {
        return "1 minute"
    }
    return String(format: "%01d minutes", minutes)
}

func elapsedTimeComponents(for duration: TimeInterval) -> DateComponents
{
    let minutes = (Int(duration) / 60) % 60
    let hours = (Int(duration) / 3600)
    
    let components = DateComponents(hour: hours, minute: minutes)
    
    return components
}
