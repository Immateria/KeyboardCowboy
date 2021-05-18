import Cocoa
import ModelKit

final class OpenFilePlugin {
  let workspace: WorkspaceProviding

  init(workspace: WorkspaceProviding) {
    self.workspace = workspace
  }

  func execute(_ command: OpenCommand,
               url: URL,
               then handler: @escaping (Error?) -> Void) {
    let config = NSWorkspace.OpenConfiguration()

    if let application = command.application {
      let applicationUrl = URL(fileURLWithPath: application.path)
      workspace.open(
        [url],
        withApplicationAt: applicationUrl,
        config: config,
        completionHandler: { _, error in
          handler(error)
        })
    } else {
      workspace.open(url, config: config, completionHandler: { _, error in
        handler(error)
      })
    }
  }
}
