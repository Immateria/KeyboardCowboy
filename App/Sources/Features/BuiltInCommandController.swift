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
  public var previousAction: (context: HotKeyContext?, workflow: Workflow?) = (context: nil, workflow: nil)

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

  func run(_ command: BuiltInCommand) -> CommandPublisher {
    Future { promise in
      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        switch command.kind {
        case .repeatLastKeystroke:
          guard let currentContext = self.currentContext,
                let keyboardController = self.keyboardController,
                let commandController = self.commandController else {
            return
          }

          if let workflow = self.previousAction.workflow {
            if case .keyboard(let command) = workflow.commands.last {
              _ = keyboardController.run(command, type: currentContext.type, eventSource: currentContext.eventSource)
            } else {
              if currentContext.type == .keyDown {
                commandController.run(workflow.commands)
              }
            }
          } else if let hotkeyContext = self.previousAction.context {
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
