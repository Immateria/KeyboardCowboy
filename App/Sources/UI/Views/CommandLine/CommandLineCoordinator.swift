import AppKit
import Carbon
import Combine
import KeyCodes
import InputSources
import Foundation
import SwiftUI

final class CommandLineCoordinator: NSObject, ObservableObject, NSWindowDelegate, CommandLineWindowEventDelegate, @unchecked Sendable {
  @Published var input: String = ""
  @MainActor
  @Published var data: CommandLineViewModel = .init(kind: nil, results: [])

  @Published var selection: Int = 0

  nonisolated(unsafe) static private(set) var shared: CommandLineCoordinator = .init()

  @MainActor
  lazy var windowController: NSWindowController = {
    let window = CommandLineWindow(.init(width: 200, height: 200),
                                   rootView: CommandLineView(coordinator: CommandLineCoordinator.shared))
    window.eventDelegate = self
    return NSWindowController(
      window: window
    )
  }()

  private let applicationStore = ApplicationStore.shared
  private var subscription: AnyCancellable?
  private var task: Task<Void, Error>?

  private override init() {
    super.init()
    subscription = $input
      .throttle(for: 0.2, scheduler: DispatchQueue.main, latest: true)
      .sink { [weak self] newInput in
        guard let self else { return }
        Task { @MainActor in
          await self.handleInputDidChange(newInput)
        }
    }

    Task { await applicationStore.load() }
  }

  @MainActor
  func show(_ action: CommandLineAction) -> String {
    if windowController.window?.isVisible == true {
      windowController.close()
      return ""
    }

    windowController.showWindow(nil)
    windowController.window?.delegate = self
    windowController.window?.makeKeyAndOrderFront(nil)
    KeyboardCowboy.activate(setActivationPolicy: false)
    return ""
  }

  @MainActor
  func run() {
    Task {
      let _ = try? await task?.value
      switch data.kind {
      case .keyboard:
        break
      case .app:
        let result = data.results[selection]
        switch result {
        case .app(let application):
          try? await ApplicationCommandRunner(
            scriptCommandRunner: .init(),
            keyboard: .init(
              store: KeyCodesStore(
                InputSourceController()
              )
            ),
            workspace: NSWorkspace.shared
          )
          .run(.init(application: application), checkCancellation: false)
        default: break
        }
      case .url:
        if case .url(var url) = data.results[selection] {
          break
//          var components = URLComponents(string: url.absoluteString)
//          if components?.host == nil {
//            components?.host = "https"
//          }
//          guard let newUrl = components?.url else { return }
//          NSWorkspace.shared.open(newUrl)
        }
      case .none:
        break
      }

      windowController.window?.close()
    }
  }

  // MARK: CommandLineWindowEventDelegate

  @MainActor
  func shouldConsumeEvent(_ event: NSEvent) -> Bool {
    switch Int(event.keyCode) {
    case kVK_Escape:
      if event.type == .keyDown {
        windowController.close()
      }
      return true
    case kVK_UpArrow:
      if event.type == .keyDown {
        let newSelection = selection - 1
        selection = max(0, newSelection)
      }
      return true
    case kVK_DownArrow:
      if event.type == .keyDown {
        let newSelection = selection + 1
        selection = min(data.results.count - 1, newSelection)
      }
      return true
    default:
      return false
    }
  }

  // MARK: NSWindowDelegate

  func windowDidResignKey(_ notification: Notification) {
    windowController.close()
  }

  // MARK: Private methods

  func handleInputDidChange(_ newInput: String) async {
    guard !newInput.isEmpty else {
      Task { @MainActor in
        data.kind = .none
        data.results = []
      }
      return
    }

    if newInput.hasPrefix(":") {
      Task { @MainActor in
        data.kind = .keyboard
      }
      return
    }

    if let url = URL(string: newInput) {
      Task { @MainActor in
        data.kind = .url
        withAnimation(.smooth(duration: 0.1)) {
          data.results = [.url(url)]
        }
      }
      return
    }

    task = Task(priority: .high) {
      let apps = applicationStore.apps()
      let searchString = newInput.lowercased()
      let matches = apps.filter({
        $0.bundleIdentifier.lowercased().contains(searchString) ||
        $0.path.lowercased().contains(searchString) ||
        $0.displayName.lowercased().hasPrefix(searchString)
      })

      try Task.checkCancellation()

      let results = matches.map {
        CommandLineViewModel.Result.app($0)
      }

      try Task.checkCancellation()

      await MainActor.run {
        withAnimation(.smooth(duration: 0.1)) {
          data.results = results
        }
        data.kind = .app
      }
    }
  }
}
