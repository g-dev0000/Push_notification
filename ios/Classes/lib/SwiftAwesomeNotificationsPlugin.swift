
import Flutter
import UIKit
import UserNotifications

public class SwiftAwesomeNotificationsPlugin: NSObject, FlutterPlugin, UNUserNotificationCenterDelegate {

    private static var _instance:SwiftAwesomeNotificationsPlugin?
    
    static let TAG = "AwesomeNotificationsPlugin"
    
    static var appLifeCycle:NotificationLifeCycle = NotificationLifeCycle.AppKilled

    var flutterChannel:FlutterMethodChannel?
    
    public static var instance:SwiftAwesomeNotificationsPlugin? {
        get { return _instance }
    }
    
    private static func checkGooglePlayServices() -> Bool {
        return true
    }
    
    public func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        let jsonData:String? = notification.userInfo?[Definitions.NOTIFICATION_JSON] as? String
        receiveAction(jsonData: jsonData)
    }
    
    @available(iOS 10.0, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        receiveAction(jsonData: response.notification.request.content.userInfo[Definitions.NOTIFICATION_JSON] as? String)
    }
    
    @available(iOS 10.0, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    private func receiveAction(jsonData: String?){
        Log.d(SwiftAwesomeNotificationsPlugin.TAG, "NOTIFICATION RECEIVED")
        let actionReceived:ActionReceived? = NotificationBuilder.buildNotificationActionFromJson(jsonData: jsonData)
        flutterChannel?.invokeMethod(Definitions.CHANNEL_METHOD_RECEIVED_ACTION, arguments: actionReceived?.toMap())
    }
    
    public func createEvent(notificationReceived:NotificationReceived){
        Log.d(SwiftAwesomeNotificationsPlugin.TAG, "NOTIFICATION CREATED")
        flutterChannel?.invokeMethod(Definitions.CHANNEL_METHOD_NOTIFICATION_CREATED, arguments: notificationReceived.toMap())
    }
    
    public func displayEvent(notificationReceived:NotificationReceived){
        Log.d(SwiftAwesomeNotificationsPlugin.TAG, "NOTIFICATION DISPLAYED")
        flutterChannel?.invokeMethod(Definitions.CHANNEL_METHOD_NOTIFICATION_DISPLAYED, arguments: notificationReceived.toMap())
    }
    
    public func applicationDidBecomeActive(_ application: UIApplication){
        SwiftAwesomeNotificationsPlugin.appLifeCycle =
            SwiftAwesomeNotificationsPlugin.getApplicationLifeCycle(application)
    }

    public func applicationDidEnterBackground(_ application: UIApplication) {
        SwiftAwesomeNotificationsPlugin.appLifeCycle =
            SwiftAwesomeNotificationsPlugin.getApplicationLifeCycle(application)
    }

    public func applicationWillTerminate(_ application: UIApplication){
        SwiftAwesomeNotificationsPlugin.appLifeCycle =
            SwiftAwesomeNotificationsPlugin.getApplicationLifeCycle(application)
    }

    public static func getApplicationLifeCycle() -> NotificationLifeCycle {
        return getApplicationLifeCycle(UIApplication.shared)
    }
    
    public static func getApplicationLifeCycle(_ application: UIApplication) -> NotificationLifeCycle {
        switch application.applicationState {
            case .active:
                appLifeCycle = NotificationLifeCycle.Foreground
                return NotificationLifeCycle.Foreground
                
            case .inactive:
                appLifeCycle = NotificationLifeCycle.AppKilled
                return NotificationLifeCycle.AppKilled
                
            case .background:
                appLifeCycle = NotificationLifeCycle.Background
                return NotificationLifeCycle.Background
                
            @unknown default:
                appLifeCycle = NotificationLifeCycle.AppKilled
                return NotificationLifeCycle.AppKilled
        }
    }

    private static func requestPermissions() -> Bool {
        NotificationBuilder.requestPermissions()
        return true
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: Definitions.CHANNEL_FLUTTER_PLUGIN, binaryMessenger: registrar.messenger())
        let instance = SwiftAwesomeNotificationsPlugin()

        instance.initializeFlutterPlugin(registrar: registrar, channel: channel)
        SwiftAwesomeNotificationsPlugin._instance = instance
    }

    private func initializeFlutterPlugin(registrar: FlutterPluginRegistrar, channel: FlutterMethodChannel) {
        self.flutterChannel = channel
        registrar.addMethodCallDelegate(self, channel: self.flutterChannel!)
                
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

        switch call.method {
            
            case Definitions.CHANNEL_METHOD_INITIALIZE:
                channelMethodInitialize(call: call, result: result)
                return
                
            case Definitions.CHANNEL_METHOD_IS_FCM_AVAILABLE:
                channelMethodIsFcmAvailable(call: call, result: result)
                return
          
            case Definitions.CHANNEL_METHOD_GET_FCM_TOKEN:
                channelMethodGetFcmToken(call: call, result: result)
                return
                
            case Definitions.CHANNEL_METHOD_CREATE_NOTIFICATION:
                channelMethodCreateNotification(call: call, result: result)
                return
                
            case Definitions.CHANNEL_METHOD_CANCEL_NOTIFICATION:
                channelMethodCancelNotification(call: call, result: result)
                return
                
            case Definitions.CHANNEL_METHOD_CANCEL_ALL_NOTIFICATIONS:
                channelMethodCancelAllNotifications(call: call, result: result)
                return

            default:
                result(FlutterError.init(code: "methodNotFound", message: "method not found", details: call.method));
                return
        }
    }

    private func channelMethodInitialize(call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        do {

            let platformParameters:[String:Any?] = call.arguments as? [String:Any?] ?? [:]
            let defaultIconPath:String? = platformParameters[Definitions.DEFAULT_ICON] as? String
            let channelsData:[Any] = platformParameters[Definitions.INITIALIZE_CHANNELS] as? [Any] ?? []

            try setDefaultConfigurations(
                defaultIconPath,
                channelsData
            )

            NotificationBuilder.requestPermissions()
            
            Log.d(SwiftAwesomeNotificationsPlugin.TAG, "Awesome Notification service initialized")
            result(true)

        } catch {
            
            result(
                FlutterError.init(
                    code: "\(error)",
                    message: "Awesome Notification service could not beeing initialized",
                    details: error
                )
            )
        }
        
        result(nil)
    }

    private func channelMethodGetFcmToken(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(false)
    }

    private func channelMethodIsFcmAvailable(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(nil)
    }

    private func channelMethodCancelNotification(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let notificationId:Int? = call.arguments as? Int
        if(notificationId == nil){ result(false); return }
        
        NotificationSender.cancelNotification(id: notificationId!)
        
        result(true)
    }

    private func channelMethodCancelAllNotifications(call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        NotificationSender.cancelAllNotifications()
        result(true)
    }

    private func channelMethodCreateNotification(call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        do {

            let pushData:[String:Any?] = call.arguments as? [String:Any?] ?? [:]
            let pushNotification:PushNotification? = PushNotification().fromMap(arguments: pushData) as? PushNotification
            
            if(pushNotification != nil){
            
                if(pushNotification?.schedule == nil){
                    
                    try NotificationSender().send(
                        createdSource: NotificationSource.Local,
                        pushNotification: pushNotification
                    )
                    
                }
                else {
                    // TODO
                }
                
                Log.d(SwiftAwesomeNotificationsPlugin.TAG, "Notification sent");
                result(true)
            }
            else {
                result(
                    FlutterError.init(
                        code: "Invalid parameters",
                        message: "Notification content is invalid",
                        details: nil
                    )
                )
            }

        } catch {
            
            result(
                FlutterError.init(
                    code: "\(error)",
                    message: "Awesome Notification service could not beeing initialized",
                    details: error
                )
            )
        }
        
        result(nil)
    }

    private func setDefaultConfigurations(_ defaultIconPath:String?, _ channelsData:[Any]) throws {
        
        for anyData in channelsData {
            if let channelData = anyData as? [String : Any?] {
                let channel:NotificationChannelModel? = (NotificationChannelModel().fromMap(arguments: channelData) as? NotificationChannelModel)
                
                if(channel != nil){
                    ChannelManager.saveChannel(channel: channel!)
                }
            }
        }
    }
}
