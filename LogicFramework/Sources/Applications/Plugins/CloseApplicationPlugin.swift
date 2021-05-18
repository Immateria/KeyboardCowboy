import Cocoa
import ModelKit

final class CloseApplicationPlugin {
  let workspace: WorkspaceProviding

  init(workspace: WorkspaceProviding) {
    self.workspace = workspace
  }

  func execute(_ command: ApplicationCommand) -> Bool {
    guard let runningApplication = workspace.applications.first(where: {
      command.application.bundleIdentifier == $0.bundleIdentifier
    }) else {
      return false
    }

    return runningApplication.terminate()
  }
}
