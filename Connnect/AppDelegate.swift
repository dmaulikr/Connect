import UIKit
import MapKit
import PubNub
import CoreLocation


enum AppColors {
    static let TenderShoots = UIColor(colorLiteralRed: 179/255,
                                      green: 230/255, blue: 18/255, alpha: 1)
    static let JadeCream = UIColor(colorLiteralRed: 97/255,
                                   green: 189/255, blue: 147/255, alpha: 1)
    static let Cayenne = UIColor(colorLiteralRed: 224/255,
                                 green: 73/255, blue: 81/255, alpha: 1)
    static let LightGray = UIColor(colorLiteralRed: 219/255,
                                   green: 217/255, blue: 206/255, alpha: 1)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PNObjectEventListener {

    static let shared = UIApplication.shared.delegate as! AppDelegate

    var locationManager = CLLocationManager()
    let themeColor = AppColors.LightGray

    
    var window: UIWindow?
    var client: PubNub!
    var myMessages = [String]()
    var notification = NotificationCenter.default
    let notificationName = Notification.Name("NewMessage")


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //UIColors
        window?.tintColor = AppColors.JadeCream
        UINavigationBar.appearance().barTintColor = themeColor
//        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
//        UIBarButtonItem.appearance().tintColor = AppColors.JadeCream
        // Override point for customization after application launch.
        // Initialize and configure PubNub client instance
        let configuration = PNConfiguration(publishKey: PubNubKeys.publish, subscribeKey: PubNubKeys.subscribe)
        self.client = PubNub.client(with: configuration)
        self.client.add(self)

        let currentChannels = (UserDefaults.standard.array(forKey: channelKey) ?? []) as! [String]
        if currentChannels.isEmpty {
            let newChannelStorybard = UIStoryboard(name: "EditChannel", bundle: nil)
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = newChannelStorybard.instantiateInitialViewController()!
        } else {
            AppDelegate.shared.client.subscribe(toChannels: currentChannels, withPresence: true)
            var current = (UserDefaults.standard.array(forKey: channelKey) ?? [Any]()) as? [String]
            if current == nil {
                current = [String]()
            }
            for channel in currentChannels {
                current!.append(channel)
            }
            UserDefaults.standard.set(current!, forKey: channelKey)
        }

        return true
    }

    func openMainViewController() {
        let main = UIStoryboard(name: "Main", bundle: nil)
        window?.rootViewController = main.instantiateInitialViewController()
    }


}


extension AppDelegate {
    
    // Handle new message from one of channels on which client has been subscribed.
    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        

        // Handle new message stored in message.data.message
        if message.data.actualChannel != message.data.subscribedChannel {
            
            // Message has been received on channel group stored in message.data.subscription.
        }
        else {
            
            // Message has been received on channel stored in message.data.channel.
        }
        guard let theMessage = message.data.message as? String else {return}
        myMessages.insert(theMessage, at: 0)
        let note = Notification(name: notificationName)
        notification.post(note)
        print("Received message: \(message.data.message) on channel \(message.data.actualChannel) " +
            "at \(message.data.timetoken)")
        
    }
    
    // New presence event handling.
    func client(_ client: PubNub, didReceivePresenceEvent event: PNPresenceEventResult) {
        
        // Handle presence event event.data.presenceEvent (one of: join, leave, timeout, state-change).
        if event.data.actualChannel != event.data.subscribedChannel {
            
            // Presence event has been received on channel group stored in event.data.subscription.
        }
        else {
            
            // Presence event has been received on channel stored in event.data.channel.
        }
        
        if event.data.presenceEvent != "state-change" {
            
            print("\(event.data.presence.uuid) \"\(event.data.presenceEvent)'ed\"\n" +
                "at: \(event.data.presence.timetoken) on \(event.data.actualChannel) " +
                "(Occupancy: \(event.data.presence.occupancy))");
        }
        else {
            
            print("\(event.data.presence.uuid) changed state at: " +
                "\(event.data.presence.timetoken) on \(event.data.actualChannel) to:\n" +
                "\(event.data.presence.state)");
        }
    }
    
    // Handle subscription status change.
    func client(_ client: PubNub, didReceive status: PNStatus) {
        
        if status.operation == .subscribeOperation {
            
            // Check whether received information about successful subscription or restore.
            if status.category == .PNConnectedCategory || status.category == .PNReconnectedCategory {
                
                let subscribeStatus: PNSubscribeStatus = status as! PNSubscribeStatus
                if subscribeStatus.category == .PNConnectedCategory {
                    
                    // This is expected for a subscribe, this means there is no error or issue whatsoever.
                    
                    // Select last object from list of channels and send message to it.
                    let targetChannel = client.channels().last!
                    client.publish("Hello from the PubNub Swift SDK", toChannel: targetChannel,
                                   compressed: false, withCompletion: { (publishStatus) -> Void in
                                    
                                    if !publishStatus.isError {
                                        
                                        // Message successfully published to specified channel.
                                    }
                                    else {
                                        
                                        /**
                                         Handle message publish error. Check 'category' property to find out
                                         possible reason because of which request did fail.
                                         Review 'errorData' property (which has PNErrorData data type) of status
                                         object to get additional information about issue.
                                         
                                         Request can be resent using: publishStatus.retry()
                                         */
                                    }
                    })
                }
                else {
                    
                    /**
                     This usually occurs if subscribe temporarily fails but reconnects. This means there was
                     an error but there is no longer any issue.
                     */
                }
            }
            else if status.category == .PNUnexpectedDisconnectCategory {
                
                /**
                 This is usually an issue with the internet connection, this is an error, handle
                 appropriately retry will be called automatically.
                 */
            }
                // Looks like some kind of issues happened while client tried to subscribe or disconnected from
                // network.
            else {
                
                let errorStatus: PNErrorStatus = status as! PNErrorStatus
                if errorStatus.category == .PNAccessDeniedCategory {
                    
                    /**
                     This means that PAM does allow this client to subscribe to this channel and channel group
                     configuration. This is another explicit error.
                     */
                }
                else {
                    
                    /**
                     More errors can be directly specified by creating explicit cases for other error categories 
                     of `PNStatusCategory` such as: `PNDecryptionErrorCategory`,  
                     `PNMalformedFilterExpressionCategory`, `PNMalformedResponseCategory`, `PNTimeoutCategory`
                     or `PNNetworkIssuesCategory`
                     */
                }
            }
        }
    }
}

extension AppDelegate: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("I just enetered this location")
        let targetChannel = client.channels().last!
        client.publish("Just Got to Work", toChannel: targetChannel , withCompletion: nil)
    }
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("I just exited this location")
        let targetChannel = client.channels().last!
        client.publish("Just Left From Work", toChannel: targetChannel , withCompletion: nil)
    }
}



