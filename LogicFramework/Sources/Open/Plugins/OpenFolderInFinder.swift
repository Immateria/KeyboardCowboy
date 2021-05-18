import Cocoa
import ModelKit

final class OpenFolderInFinder {
  private let finderBundleIdentifier = "com.apple.finder"
  let workspace: WorkspaceProviding

  init(workspace: WorkspaceProviding) {
    self.workspace = workspace
  }

  func execute(_ command: OpenCommand,
               url: URL,
               then handler: @escaping () -> Void) {
    let source = """
      tell application "Finder"
        set the target of the front Finder window to folder ("\(url.path)" as POSIX file)
      end tell
      """
    let script = NSAppleScript(source: source)
    script?.executeAndReturnError(nil)
    handler()
  }

  func validate(_ command: OpenCommand) -> Bool {
    command.application?.bundleIdentifier.lowercased() == finderBundleIdentifier ||
      workspace.frontApplication?.bundleIdentifier?.lowercased() == finderBundleIdentifier
  }
}
