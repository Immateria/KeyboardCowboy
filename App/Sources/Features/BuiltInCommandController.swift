import Cocoa
import Combine
import LogicFramework
import ModelKit

class BuiltInCommandController: BuiltInCommandControlling {
  enum BuiltInCommandError: Error {
    case noWindowController
  }

  var windowController: QuickRunWindowController?
  public weak var commandController: CommandControlling?
  public var currentContext: HotKeyContext?
  public var keyboardController: KeyboardCommandControlling?
  public var keyboardShortcutValidator: KeyboardShortcutValidator?
  public var recordedActions = [RecordedAction]()

  private var isRecording: Bool = false
  private var previousApplication: RunningApplication?
  private var subscriptions = [AnyCancellable]()

  init() {
    NSWorkspace.shared
      .publisher(for: \.frontmostApplication)
      .removeDuplicates()
      .filter({ $0?.bundleIdentifier != bundleIdentifier })
      .sink(receiveValue: { [weak self] application in
        self?.previousApplication = application
      }).store(in: &subscriptions)
  }

  func receive(_ action: RecordedAction) {
    let shouldExcludeFromRecording = action.workflow?.commands.filter {
      if case .builtIn(let command) = $0 {
        switch command.kind {
        case .recordSequence, .repeatLastKeystroke:
          return true
        case .quickRun:
          return false
        }
      }
      return false
    }.isEmpty == false

    guard !shouldExcludeFromRecording else { return }

    if isRecording {
      recordedActions.append(action)
    }
  }

  func run(_ command: BuiltInCommand) -> CommandPublisher {
    Future { promise in
      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        switch command.kind {
        case .recordSequence:
          let shouldEmptyStack = !self.isRecording && !self.recordedActions.isEmpty
          if shouldEmptyStack {
            self.recordedActions = []
          }
          self.isRecording.toggle()
        case .repeatLastKeystroke:
          self.isRecording = false
          guard let currentContext = self.currentContext,
                let keyboardController = self.keyboardController,
                let commandController = self.commandController else {
            return
          }

          for (offset, action) in self.recordedActions.enumerated() {
//            if let workflow = action.workflow {
//              if case .keyboard(let command) = workflow.commands.last {
//                _ = keyboardController.run(command, type: currentContext.type, eventSource: currentContext.eventSource)
//              } else {
//                if currentContext.type == .keyDown {
//                  commandController.run(workflow.commands)
//                }
//              }
//            } else
            if let hotkeyContext = action.context {
              guard let container = try? self.keyboardShortcutValidator?.keycodeMapper.map(Int(hotkeyContext.keyCode),
                                                                                           modifiers: 0) else {
                return
              }

              let modifiers = ModifierKey.fromCGEvent(hotkeyContext.event,
                                                      specialKeys: Array(KeyCodes.specialKeys.keys))
              let keyboardShortcut = KeyboardShortcut(
                key: container.displayValue,
                modifiers: modifiers)

              let keyboardCommand = KeyboardCommand(keyboardShortcut: keyboardShortcut)
                _ = keyboardController.run(keyboardCommand,
                                           type: currentContext.type, eventSource:
                                            currentContext.eventSource)
            }
          }
        case .quickRun:
          guard let windowController = self.windowController else {
            promise(.failure(BuiltInCommandError.noWindowController))
            return
          }
          if windowController.window?.isVisible == true {
            windowController.close()
            _ = self.previousApplication?.activate(options: .activateIgnoringOtherApps)
          } else {
            NSApp.activate(ignoringOtherApps: true)
            NSApp.mainWindow?.close()
            windowController.showWindow(nil)
            windowController.becomeFirstResponder()
          }
        }
        promise(.success(()))
      }
    }.eraseToAnyPublisher()
  }
}
