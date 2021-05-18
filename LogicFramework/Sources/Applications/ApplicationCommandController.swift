import Cocoa
import Combine
import ModelKit

public protocol ApplicationCommandControlling {
  /// Run `ApplicationCommand` which should either launch or
  /// activate the target application. The `Application` struct
  /// is used to determine which app should be invoked.
  ///
  /// - Parameter command: An `ApplicationCommand` that indicates
  ///                      which application should be launched
  ///                      or activated if already running.
  /// - Returns: A publisher that wraps a result of the run operation.
  func run(_ command: ApplicationCommand) -> CommandPublisher
}

public enum ApplicationCommandControllingError: Error {
  case failedToLaunch
  case failedToFindRunningApplication
  case failedToActivate
  case failedToClose
}

public enum ApplicationCommandNotification: String {
  case keyboardCowboyWasActivate
}

final class ApplicationCommandController: ApplicationCommandControlling {
  struct Plugins {
    let activateApplication: ActivateApplicationPlugin
    let closeApplication: CloseApplicationPlugin
    let launchApplication: LaunchApplicationPlugin
  }

  let plugins: Plugins
  let windowListProvider: WindowListProviding
  let workspace: WorkspaceProviding

  init(windowListProvider: WindowListProviding, workspace: WorkspaceProviding) {
    self.windowListProvider = windowListProvider
    self.workspace = workspace
    self.plugins = Plugins(
      activateApplication: ActivateApplicationPlugin(workspace: workspace),
      closeApplication: CloseApplicationPlugin(workspace: workspace),
      launchApplication: LaunchApplicationPlugin(workspace: workspace)
    )
  }

  // MARK: Public methods

  func run(_ command: ApplicationCommand) -> CommandPublisher {
    Future { [weak self] promise in
      guard let self = self else { return }

      if command.modifiers.contains(.onlyIfNotRunning) {
        let bundleIdentifiers = self.workspace.applications.compactMap({ $0.bundleIdentifier })
        if bundleIdentifiers.contains(command.application.bundleIdentifier) {
          promise(.success(()))
          return
        }
      }

      switch command.action {
      case .open:
        self.openApplication(command: command, promise: promise)
      case .close:
        if self.plugins.closeApplication.execute(command) {
          promise(.success(()))
        } else {
          promise(.failure(ApplicationCommandControllingError.failedToClose))
        }
      }

    }.eraseToAnyPublisher()
  }

  private func openApplication(command: ApplicationCommand,
                               promise: @escaping (Result<Void, Error>) -> Void) {

    if command.application.bundleIdentifier == Bundle.main.bundleIdentifier {
      DispatchQueue.main.async {
        NotificationCenter.default.post(.keyboardCowboyWasActivate)
        promise(.success(()))
      }
      return
    }

    if command.modifiers.contains(.background) ||
        command.application.metadata.isElectron {
      plugins.launchApplication.execute(command) { error in
        if let error = error {
          promise(.failure(error))
        } else {
          promise(.success(()))
        }
      }
      return
    }

    let isFrontMostApplication = command.application
      .bundleIdentifier == workspace.frontApplication?.bundleIdentifier

    if isFrontMostApplication, plugins.activateApplication.execute(command) != nil {
      if !windowListProvider.windowOwners().contains(command.application.bundleName) {
        plugins.launchApplication.execute(command) { error in
          if error != nil {
            promise(.failure(ApplicationCommandControllingError.failedToActivate))
          } else {
            promise(.success(()))
          }
        }
      } else {
        promise(.success(()))
      }
    } else {
      plugins.launchApplication.execute(command) { error in
        if error != nil {
          promise(.failure(ApplicationCommandControllingError.failedToLaunch))
        } else if !self.windowListProvider.windowOwners().contains(command.application.bundleName) {
          if let error = self.plugins.activateApplication.execute(command) {
            promise(.failure(error))
          } else {
            promise(.success(()))
          }
        } else {
          promise(.success(()))
        }
      }
    }
  }
}

private extension NotificationCenter {
  func post(_ notification: ApplicationCommandNotification) {
    self.post(.init(name: .init(rawValue: notification.rawValue)))
  }
}
