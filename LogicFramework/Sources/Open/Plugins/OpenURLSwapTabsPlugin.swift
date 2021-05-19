import Cocoa
import ModelKit

final class OpenURLSwapTabsPlugin {
  enum OpenURLSwapToPluginError: Error {
    case failedToCreate
    case failedToCompile
    case failedToRun
  }

  func execute(_ command: OpenCommand) -> Bool {
    var dictionary: NSDictionary?
    guard let script = createAppleScript(command.path) else {
      return false
    }

    let result = script.executeAndReturnError(&dictionary).booleanValue

    if dictionary != nil { return false }

    return result
  }

  private func createAppleScript(_ urlString: String) -> NSAppleScript? {
    let source = """
      set searchPattern to "\(urlString)"
      tell application "Safari"
        repeat with cWindow in windows
          repeat with cTab in tabs of cWindow
            set currentIndex to index of cTab
            set currentURL to URL of cTab
            if currentURL contains searchPattern then
              set index of cWindow to 1
              set current tab of cWindow to cTab
              activate
              return true
              exit repeat
            end if
          end repeat
        end repeat
        return false
      end tell
      """
    let appleScript = NSAppleScript(source: source)
    return appleScript
  }
}
