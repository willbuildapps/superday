import Foundation
import Firebase

class FirebaseMetricsService : MetricsService
{
    ///Perform any framework specific initialization
    func initialize()
    {
        #if ADHOC
            print(#function)
            let filePath = Bundle.main.path(forResource: "GoogleService-Info-AdHoc", ofType: "plist")
            guard let fileopts = FirebaseOptions.init(contentsOfFile: filePath!)
                else { assert(false, "Couldn't load config file"); return }
            FirebaseApp.configure(options: fileopts)
        #elseif APPSTORE
            let filePath = Bundle.main.path(forResource: "GoogleService-Info-AppStore", ofType: "plist")
            guard let fileopts = FirebaseOptions.init(contentsOfFile: filePath!)
                else { assert(false, "Couldn't load config file"); return }
            FirebaseApp.configure(options: fileopts)
        #endif
    }
    
    ///Used to send custom events to the framework
    func log(event: CustomEvent)
    {
        #if ADHOC || APPSTORE
            Analytics.logEvent(event.name, parameters: event.attributes)
        #endif
    }
}
