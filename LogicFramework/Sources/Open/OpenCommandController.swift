import Combine
import Cocoa
import ModelKit

public protocol OpenCommandControlling {
  /// Execute an open command either with or without an optional associated application.
  /// `NSWorkspace` is used to perform open invocations.
  ///
  /// If an application is attached to the `OpenCommand`, then
  /// `open(_ urls: [URL] ... withApplicationAt: URL)` is invoked on `NSWorkspace`.
  ///
  /// If an application is not selected, then `open(_ url: URL ...)` will be used.
  ///
  /// - Note: All calls are made asynchronously.
  /// - Parameter command: An `OpenCommand` that should be invoked.
  /// - Returns: A publisher that wraps a result of the run operation.
  func run(_ command: OpenCommand) -> CommandPublisher
}

public enum OpenCommandControllingError: Error {
  case failedToOpenUrl
}

final class OpenCommandController: OpenCommandControlling {
  struct Plugins {
    let finderFolder: OpenFolderInFinder
    let parser = OpenURLParser()
    let open: OpenFilePlugin
    let swapTab = OpenURLSwapTabsPlugin()
  }

  let plugins: Plugins

  init(workspace: WorkspaceProviding) {
    self.plugins = Plugins(
      finderFolder: OpenFolderInFinder(workspace: workspace),
      open: OpenFilePlugin(workspace: workspace)
    )
  }

  func run(_ command: OpenCommand) -> CommandPublisher {
    Future { promise in
      let url = self.plugins.parser.parse(command.path.sanitizedPath)
      if self.plugins.finderFolder.validate(command) {
        self.plugins.finderFolder.execute(command, url: url) {
          promise(.success(()))
        }
      } else {
        guard self.plugins.swapTab.execute(command) == false else {
          promise(.success(()))
          return
        }

        self.plugins.open.execute(command, url: url) { error in
          if error != nil {
            promise(.failure(OpenCommandControllingError.failedToOpenUrl))
          } else {
            promise(.success(()))
          }
        }
      }
    }.eraseToAnyPublisher()
  }
}
