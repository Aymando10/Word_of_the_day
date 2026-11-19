import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    UNUserNotificationCenter.current().delegate = self
    if let registrar = registrar(forPlugin: "DailyWordNotifications") {
      let channel = FlutterMethodChannel(
        name: DailyWordNotifications.channelName,
        binaryMessenger: registrar.messenger()
      )
      channel.setMethodCallHandler(DailyWordNotifications.handle)
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /// Show reminders as banners even while the app is open.
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([.banner, .list, .sound])
  }
}

/// Native scheduler behind `lib/services/notification_service.dart`.
///
/// Flutter sends a list of dated reminders; each becomes a one-off local
/// notification at that local date and time.
enum DailyWordNotifications {
  static let channelName = "com.aymanstrauch.wordapp/notifications"
  private static let idPrefix = "daily-word-"

  static func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "requestPermission":
      requestPermission(result: result)
    case "schedule":
      guard
        let args = call.arguments as? [String: Any],
        let items = args["items"] as? [[String: Any]]
      else {
        result(FlutterError(code: "bad_args", message: "Expected a list of reminders.", details: nil))
        return
      }
      schedule(items, result: result)
    case "cancelAll":
      removePending { result(nil) }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private static func requestPermission(result: @escaping FlutterResult) {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
      DispatchQueue.main.async {
        if let error {
          result(FlutterError(code: "permission_error", message: error.localizedDescription, details: nil))
        } else {
          result(granted)
        }
      }
    }
  }

  private static func schedule(_ items: [[String: Any]], result: @escaping FlutterResult) {
    removePending {
      let center = UNUserNotificationCenter.current()
      for item in items {
        guard
          let year = item["year"] as? Int,
          let month = item["month"] as? Int,
          let day = item["day"] as? Int,
          let hour = item["hour"] as? Int,
          let minute = item["minute"] as? Int,
          let title = item["title"] as? String,
          let body = item["body"] as? String
        else { continue }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        var components = DateComponents()
        (components.year, components.month, components.day) = (year, month, day)
        (components.hour, components.minute) = (hour, minute)

        let id = String(format: "%@%04d-%02d-%02d", idPrefix, year, month, day)
        let request = UNNotificationRequest(
          identifier: id,
          content: content,
          trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        )
        center.add(request)
      }
      result(nil)
    }
  }

  /// Removes only this app's daily-word reminders, then calls [completion] on the main queue.
  private static func removePending(then completion: @escaping () -> Void) {
    let center = UNUserNotificationCenter.current()
    center.getPendingNotificationRequests { requests in
      let ids = requests.map(\.identifier).filter { $0.hasPrefix(idPrefix) }
      center.removePendingNotificationRequests(withIdentifiers: ids)
      DispatchQueue.main.async(execute: completion)
    }
  }
}
