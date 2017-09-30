import Foundation
@testable import teferi

extension Date
{
    static var noon:Date {
        return Date.midnight.addingTimeInterval(12 * 60 * 60)
    }
    
    static var midnight:Date {
        return Date().ignoreTimeComponents()
    }
}
