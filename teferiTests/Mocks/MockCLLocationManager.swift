import Foundation
import CoreLocation
@testable import teferi

class MockCLLocationManager:CLLocationManager
{
    private(set) var updatingLocation:Bool = false
    private(set) var monitoringSignificantLocationChanges:Bool = false
    
    override init() { }
    
    override func startUpdatingLocation()
    {
        updatingLocation = true
    }
    
    override func startMonitoringSignificantLocationChanges()
    {
        monitoringSignificantLocationChanges = true
    }
    
    override func stopUpdatingLocation()
    {
        updatingLocation = false
    }
    
    func sendLocations(_ locations:[Location])
    {
        guard updatingLocation || monitoringSignificantLocationChanges else { return }
        delegate?.locationManager!(self, didUpdateLocations: locations.map{ $0.toCLLocation() })
    }
}
