import Foundation
@testable import teferi

private let earthRadius = 6_378_000.0
private let metersToLatitudeFactor = 1.0 / 111_000

enum Direction:UInt32
{
    case north
    case south
    case west
    case east
}

typealias Coordinates = (latitude: Double, longitude: Double)

extension Location
{
    static var baseLocation:Location
    {
        return Location(timestamp: Date.noon,
                        latitude: 37.628060, longitude: -116.848463,
                        accuracy: 100)
    }
    
    fileprivate func offsetCoordinates(_ direction: Direction, meters: Double) -> Coordinates
    {
        let newLatitude : Double
        let newLongitude : Double
        
        switch(direction)
        {
            case .north:
                
                newLatitude = latitude + meters * metersToLatitudeFactor
                newLongitude = longitude
                break
            
            case .south:
                
                newLatitude = latitude + -meters * metersToLatitudeFactor
                newLongitude = longitude
                break
            
            case .west:
                
                newLatitude = latitude
                newLongitude = longitude + (-meters / earthRadius) * (180 / .pi) / cos(latitude * .pi / 180)
                break
            
            case .east:
                
                newLatitude = latitude
                newLongitude = longitude + (meters / earthRadius) * (180 / .pi) / cos(latitude * .pi / 180)
                break
        }
        
        return (latitude: newLatitude, longitude: newLongitude)
    }
}

extension Location
{
    func offset(_ direction: Direction, meters: Double, timestamp: Date? = nil) -> Location
    {
        let newCoordinates = offsetCoordinates(direction, meters: meters)
        let newLocation = Location(timestamp: timestamp ?? self.timestamp,
                                   latitude: newCoordinates.latitude, longitude: newCoordinates.longitude,
                                   speed: 0, course: 0, altitude: altitude,
                                   verticalAccuracy: horizontalAccuracy, horizontalAccuracy: horizontalAccuracy)
        
        return newLocation
    }
    
    func offset(_ direction: Direction?, meters: Double = 0, seconds: TimeInterval = 0) -> Location
    {
        let newCoordinates: Coordinates
        if let direction = direction {
            newCoordinates = offsetCoordinates(direction, meters: meters)
        } else {
            newCoordinates = (latitude: latitude, longitude: longitude)
        }
        
        let newLocation = Location(timestamp: timestamp.addingTimeInterval(seconds),
                                   latitude: newCoordinates.latitude, longitude: newCoordinates.longitude,
                                   speed: 0, course: 0, altitude: altitude,
                                   verticalAccuracy: horizontalAccuracy, horizontalAccuracy: horizontalAccuracy)
        
        return newLocation
    }
    
    
    func randomOffset(withAccuracy accuracy:Double? = nil) -> Location
    {
        let newCoordinates = offsetCoordinates(
            Direction(rawValue: arc4random_uniform(4))!,
            meters: randomBetweenNumbers(firstNum: 10, secondNum: 100000)
        )
        
        let newAccuracy = accuracy ?? horizontalAccuracy
        
        return Location(timestamp: Date(),
                        latitude: newCoordinates.latitude, longitude: newCoordinates.longitude,
                        speed: 0, course: 0, altitude: altitude,
                        verticalAccuracy: newAccuracy, horizontalAccuracy: newAccuracy)
    }
    
    
    func with(accuracy:Double) -> Location
    {
        return Location(timestamp: timestamp,
                        latitude: latitude, longitude: longitude,
                        speed: 0, course: 0, altitude: altitude,
                        verticalAccuracy: accuracy, horizontalAccuracy: accuracy)
    }
}

fileprivate func randomBetweenNumbers(firstNum: Double, secondNum: Double) -> Double
{
    return Double(arc4random()) / Double(Int.max) * (secondNum - firstNum) + firstNum
}
