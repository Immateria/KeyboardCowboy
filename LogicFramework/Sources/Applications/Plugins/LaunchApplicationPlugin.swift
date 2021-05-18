import Cocoa
import ModelKit

final class LaunchApplicationPlugin {
  private let workspace: WorkspaceProviding

  init(workspace: WorkspaceProviding) {
    self.workspace = workspace
  }

  /// Launch an application using the applications bundle identifier
  /// Applications are launched using `NSWorkspace`
  ///
  /// - Parameter command: An application command which is used to resolve the applications
  ///                      bundle identifier.
  /// - Throws: If `NSWorkspace.launchApplication` returns `false`, the method will throw
  ///           `ApplicationCommandControllingError.failedToLaunch`
  func execute(_ command: ApplicationCommand, then handler: @escaping (Error?) -> Void) {
    launchApplication(at: command.application.path,
                      activates: !command.modifiers.contains(.background),
                      hides: command.modifiers.contains(.hidden), then: handler)
  }

  private func launchApplication(at path: String,
                                 activates: Bool,
                                 hides: Bool,
                                 then handler: @escaping (Error?) -> Void) {
    let config = NSWorkspace.OpenConfiguration()

    config.activates = activates
    config.hides = hides

    workspace.open(URL(fileURLWithPath: path), config: config) { _, error in
      handler(error)
    }
  }
}
