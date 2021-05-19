import Cocoa
import ModelKit

/// Bring the current applications windows to front using Apple Scripting
/// This is only here because sending `.activateAllWindows` to `NSRunningApplication.activate()`
/// currently does not work as expected.
final class BringToFrontApplicationPlugin {
  func execute(_ command: ApplicationCommand, then handler: @escaping (Error?) -> Void) {
    // swiftlint:disable line_length
    let source = """
      tell application "System Events"
      tell application "\(command.application.bundleName)"
          activate
        end tell
        click menu item "Bring All to Front" of menu "Window" of menu bar 1 of application process "\(command.application.bundleName)"
      end tell
      """

    let script = NSAppleScript(source: source)
    var dictionary: NSDictionary?
    script?.executeAndReturnError(&dictionary)

    if let dictionary = dictionary,
       let error = createError(from: dictionary) {
      handler(error)
    } else {
      handler(nil)
    }
  }

  private func createError(from dictionary: NSDictionary) -> Error? {
    let code = dictionary[NSAppleScript.errorNumber] as? Int ?? 0
    let errorMessage = dictionary[NSAppleScript.errorMessage] as? String ?? "Missing error message"
    let descriptionMessage = dictionary[NSAppleScript.errorBriefMessage] ?? "Missing description"
    let errorDomain = "com.zenangst.KeyboardCowboy.AppleScriptController"
    let error = NSError(domain: errorDomain, code: code, userInfo: [
      NSLocalizedFailureReasonErrorKey: errorMessage,
      NSLocalizedDescriptionKey: descriptionMessage
    ])
    return error
  }
}
