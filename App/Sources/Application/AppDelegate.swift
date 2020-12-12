import Cocoa
let bundleIdentifier = Bundle.main.bundleIdentifier!
//
class AppDelegate {
  static let enableNotification = Notification.Name("enableHotKeys")
  static let disableNotification = Notification.Name("disableHotKeys")
}
