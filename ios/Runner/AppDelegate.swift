import UIKit
import Flutter
import GoogleMaps
import flutter_local_notifications
import FirebaseCore
import FirebaseMessaging
import FBSDKCoreKit
import GoogleSignIn
import ActivityKit

@available(iOS 16.1, *)
private struct LiveActivitiesAppAttributes: ActivityAttributes, Identifiable {
    public struct ContentState: Codable, Hashable {
        var appGroupId: String

        init(appGroupId: String) {
            self.appGroupId = appGroupId
        }
    }

    var id = UUID()
}

@main
@objc class AppDelegate: FlutterAppDelegate {
    private let liveActivityAppGroupId = "group.faskhaninja.liveactivities"
  
  override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure()
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        GMSServices.provideAPIKey("AIzaSyBDfirv6d7BiO-9YnsU5zCHEn9iM9iNtuM")
        GeneratedPluginRegistrant.register(with: self)
        FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
            GeneratedPluginRegistrant.register(with: registry)
        }
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted for debug handler")
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            } else if let error = error {
                print("Error requesting notification permission: \(error)")
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)

    }

    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        let tokenParts = deviceToken.map { String(format: "%02x", $0) }
        let token = tokenParts.joined()
        print("APNS_TOKEN_REGISTERED => \(token)")
        super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }

    override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }

    override func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        print("REMOTE_NOTIFICATION_RECEIVED => \(userInfo)")

        guard isLiveActivityPayload(userInfo) else {
            super.application(
                application,
                didReceiveRemoteNotification: userInfo,
                fetchCompletionHandler: completionHandler
            )
            return
        }

        guard #available(iOS 16.1, *) else {
            completionHandler(.noData)
            return
        }

        Task {
            let didUpdate = await updateLiveActivityFromPush(userInfo)
            completionHandler(didUpdate ? .newData : .noData)
        }
    }


    // Properties for MethodChannel handling
    // var flutterResult: FlutterResult?
    // var paymobPaymentKey: String?
    // var acceptSDK = AcceptSDK()

    // Google Sign-In URL handling - COMMENTED OUT
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let googleHandled = GIDSignIn.sharedInstance.handle(url)

        let facebookHandled = ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )

        return googleHandled || facebookHandled || super.application(app, open: url, options: options)
    }

    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        if isLiveActivityPayload(userInfo) {
            completionHandler([])
            return
        }
        completionHandler(.alert) // shows banner even if app is in foreground
    }

    @available(iOS 16.1, *)
    private func updateLiveActivityFromPush(_ userInfo: [AnyHashable: Any]) async -> Bool {
        let payload = mergedLiveActivityPayload(userInfo)
        guard let rawStatus = extractStatus(from: payload) else {
            print("LIVE_ACTIVITY_NATIVE_UPDATE_SKIPPED => missing order status")
            return false
        }

        let displayStatus = toDisplayStatus(rawStatus)
        let shouldEnd = isTerminalStatus(rawStatus)
        let orderId = extractOrderId(from: payload)

        guard let sharedDefault = UserDefaults(suiteName: liveActivityAppGroupId) else {
            print("LIVE_ACTIVITY_NATIVE_UPDATE_SKIPPED => app group unavailable")
            return false
        }

        let activities = Activity<LiveActivitiesAppAttributes>.activities
        if activities.isEmpty {
            print("LIVE_ACTIVITY_NATIVE_UPDATE_SKIPPED => no active activities")
            return false
        }

        sharedDefault.set(displayStatus, forKey: "order_status")
        sharedDefault.set(displayStatus, forKey: "orderStatus")
        if let orderId = orderId, !orderId.isEmpty {
            sharedDefault.set(orderId, forKey: "order_id")
            sharedDefault.set(orderId, forKey: "orderId")
        }

        for activity in activities {
            let prefix = activity.attributes.id.uuidString
            sharedDefault.set(displayStatus, forKey: "\(prefix)_order_status")
            sharedDefault.set(displayStatus, forKey: "\(prefix)_orderStatus")
            if let orderId = orderId, !orderId.isEmpty {
                sharedDefault.set(orderId, forKey: "\(prefix)_order_id")
                sharedDefault.set(orderId, forKey: "\(prefix)_orderId")
            }

            if shouldEnd {
                await activity.end(dismissalPolicy: .immediate)
                print("LIVE_ACTIVITY_NATIVE_END => \(activity.id) status=\(displayStatus)")
            } else {
                let contentState = LiveActivitiesAppAttributes.ContentState(appGroupId: liveActivityAppGroupId)
                await activity.update(using: contentState)
                print("LIVE_ACTIVITY_NATIVE_UPDATE => \(activity.id) status=\(displayStatus)")
            }
        }

        return true
    }

    private func isLiveActivityPayload(_ userInfo: [AnyHashable: Any]) -> Bool {
        let merged = mergedLiveActivityPayload(userInfo)

        let marker = "\(merged["live_activity"] ?? "")".lowercased()
        let type = "\(merged["notification_type"] ?? merged["notificationType"] ?? merged["type"] ?? "")".lowercased()
        let hasStatus = extractStatus(from: merged) != nil
        let hasActivityId = merged["activity-id"] != nil || merged["activity_id"] != nil || merged["activityId"] != nil || merged["live_activity_id"] != nil || merged["liveActivityId"] != nil

        if type == "live_activity" || type == "live-activity" || type == "liveactivity" { return true }
        if marker == "1" || marker == "true" { return true }
        if hasStatus && hasActivityId { return true }
        if hasActivityId { return true }

        return false
    }

    private func mergedLiveActivityPayload(_ userInfo: [AnyHashable: Any]) -> [String: Any] {
        var root: [String: Any] = [:]
        for (rawKey, value) in userInfo {
            if let key = rawKey as? String {
                root[key] = value
            }
        }

        let nestedData = parseJsonObject(root["data"]) ?? asDict(root["data"])
        let contentState = parseJsonObject(root["content-state"]) ?? asDict(root["content-state"])
        let aps = asDict(root["aps"])
        let apsContentState = parseJsonObject(aps?["content-state"]) ?? asDict(aps?["content-state"])

        return root
            .merging(nestedData ?? [:]) { _, new in new }
            .merging(contentState ?? [:]) { _, new in new }
            .merging(apsContentState ?? [:]) { _, new in new }
    }

    private func asDict(_ any: Any?) -> [String: Any]? {
        return any as? [String: Any]
    }

    private func parseJsonObject(_ any: Any?) -> [String: Any]? {
        if let dict = any as? [String: Any] {
            return dict
        }
        if let text = any as? String, let data = text.data(using: .utf8) {
            let object = try? JSONSerialization.jsonObject(with: data, options: [])
            return object as? [String: Any]
        }
        return nil
    }

    private func extractStatus(from payload: [String: Any]) -> String? {
        let values: [Any?] = [
            payload["order_status"],
            payload["orderStatus"],
            payload["order_state"],
            payload["orderState"],
            payload["status"],
            (payload["order"] as? [String: Any])?["status"],
        ]

        for value in values {
            guard let value = value else { continue }
            let status = String(describing: value).trimmingCharacters(in: .whitespacesAndNewlines)
            if !status.isEmpty {
                return status
            }
        }
        return nil
    }

    private func extractOrderId(from payload: [String: Any]) -> String? {
        let values: [Any?] = [
            payload["order_id"],
            payload["orderId"],
            payload["id"],
            (payload["order"] as? [String: Any])?["id"],
            (payload["order"] as? [String: Any])?["order_id"],
        ]

        for value in values {
            guard let value = value else { continue }
            let orderId = String(describing: value).trimmingCharacters(in: .whitespacesAndNewlines)
            if !orderId.isEmpty {
                return orderId
            }
        }
        return nil
    }

    private func isTerminalStatus(_ rawStatus: String) -> Bool {
        let normalized = rawStatus
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "-", with: "_")
            .replacingOccurrences(of: " ", with: "_")

        return normalized == "ended" ||
            normalized == "delivered" ||
            normalized == "completed" ||
            normalized == "cancelled" ||
            normalized == "declined"
    }

    private func toDisplayStatus(_ rawStatus: String) -> String {
        let normalized = rawStatus
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "-", with: "_")
            .replacingOccurrences(of: " ", with: "_")

        switch normalized {
        case "new_order", "pending", "accepted", "preparing", "in_preparation":
            return "Preparing"
        case "picked_up", "on_the_way", "out_for_delivery", "shipped":
            return "On the Way"
        case "delivered", "completed":
            return "Delivered"
        default:
            let value = rawStatus.replacingOccurrences(of: "_", with: " ").trimmingCharacters(in: .whitespacesAndNewlines)
            return value.isEmpty ? "Preparing" : value
        }
    }
}
