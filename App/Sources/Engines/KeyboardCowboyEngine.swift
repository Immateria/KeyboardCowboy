import Combine
import Cocoa
import CoreGraphics
import Foundation
import MachPort
import os

@MainActor
final class KeyboardCowboyEngine {
  private var subscriptions = Set<AnyCancellable>()

  private let bundleIdentifier = Bundle.main.bundleIdentifier!
  private let contentStore: ContentStore
  private let commandEngine: CommandEngine
  private let machPortEngine: MachPortEngine
  private let shortcutStore: ShortcutStore

  private let applicationTriggerController: ApplicationTriggerController
  private var machPortController: MachPortEventController?
  private var token: Any?

  init(_ contentStore: ContentStore,
       keyboardEngine: KeyboardEngine,
       keyboardShortcutsCache: KeyboardShortcutsCache,
       scriptEngine: ScriptEngine,
       shortcutStore: ShortcutStore,
       workspace: NSWorkspace = .shared) {
    
    let commandEngine = CommandEngine(workspace, scriptEngine: scriptEngine, keyboardEngine: keyboardEngine)
    self.contentStore = contentStore
    self.commandEngine = commandEngine
    self.machPortEngine = MachPortEngine(store: keyboardEngine.store,
                                         commandEngine: commandEngine,
                                         keyboardEngine: keyboardEngine,
                                         keyboardShortcutsCache: keyboardShortcutsCache,
                                         mode: .intercept)
    self.shortcutStore = shortcutStore
    self.applicationTriggerController = ApplicationTriggerController(commandEngine)

    subscribe(to: workspace)

    machPortEngine.subscribe(to: contentStore.recorderStore.$mode)

    contentStore.recorderStore.subscribe(to: machPortEngine.$recording)

    guard !isRunningPreview else { return }

    guard !launchArguments.isEnabled(.disableMachPorts) else { return }

    if !hasPrivileges() { } else {
      do {
        if !launchArguments.isEnabled(.runningUnitTests) {
          let machPortController = try MachPortEventController(
            .privateState,
            signature: "com.zenangst.Keyboard-Cowboy",
            mode: .commonModes)
          commandEngine.eventSource = machPortController.eventSource
          machPortEngine.subscribe(to: machPortController.$event)
          machPortEngine.machPort = machPortController
          commandEngine.machPort = machPortController
          self.machPortController = machPortController

//          let swipeEvent = CGEvent(mouseEventSource: nil, mouseType: .otherMouseDragged, mouseCursorPosition: CGPoint.zero, mouseButton: .left)!
//          swipeEvent.post(tap: .cghidEventTap)
//          swipeEvent.setDoubleValueField(.gestureSwipeDeltaX, value: 100)
//          swipeEvent.setDoubleValueField(.gestureSwipeDeltaY, value: 0)
//          swipeEvent.setIntegerValueField(.gestureSwipeDirection, value: Int32(kCGGestureSwipeRight.rawValue))
//          swipeEvent.setIntegerValueField(.gestureType, value: Int32(kCGGestureTypeSwipe.rawValue))

//          machPortController.postMouseEvent(.leftMouseDown,
//                                            position: .init(x: 200, y: 200),
//                                            button: .left)
//          machPortController.postMouseEvent(.leftMouseDragged,
//                                            position: .init(x: 300, y: 300),
//                                            button: .center)
//          machPortController.postMouseEvent(.leftMouseUp,
//                                            position: .init(x: 400, y: 400),
//                                            button: .center)


        }
      } catch let error {
        os_log(.error, "\(error.localizedDescription)")
      }
    }
  }

  func run(_ commands: [Command], execution: Workflow.Execution) {
    switch execution {
    case .concurrent:
      commandEngine.concurrentRun(commands)
    case .serial:
      commandEngine.serialRun(commands)
    }
  }

  func reveal(_ commands: [Command]) {
    commandEngine.reveal(commands)
  }

  // MARK: Private methods

  private func hasPrivileges() -> Bool {
    let trusted = kAXTrustedCheckOptionPrompt.takeUnretainedValue()
    let privOptions = [trusted: true] as CFDictionary
    let accessEnabled = AXIsProcessTrustedWithOptions(privOptions)

    return accessEnabled
  }

  private func subscribe(to workspace: NSWorkspace) {
    workspace.publisher(for: \.frontmostApplication)
      .debounce(for: .milliseconds(250), scheduler: RunLoop.main)
      .compactMap { $0 }
      .sink { [weak self] application in
        self?.reload(with: application)
      }
      .store(in: &subscriptions)

    guard KeyboardCowboy.env == .production else { return }

    applicationTriggerController.subscribe(to: workspace)
    applicationTriggerController.subscribe(to: contentStore.groupStore.$groups)
  }

  private func reload(with application: NSRunningApplication) {
    guard KeyboardCowboy.env == .production else { return }
    guard contentStore.preferences.hideFromDock else { return }
    let newPolicy: NSApplication.ActivationPolicy
    if application.bundleIdentifier == bundleIdentifier {
      newPolicy = .regular
    } else {
      newPolicy = .accessory
    }

    _ = NSApplication.shared.setActivationPolicy(newPolicy)
  }
}
