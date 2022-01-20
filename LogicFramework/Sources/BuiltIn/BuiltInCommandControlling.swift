import Combine
import Foundation
import ModelKit

public protocol BuiltInCommandControlling: AnyObject {
  var commandController: CommandControlling? { get set }
  var currentContext: HotKeyContext? { get set }
  var keyboardController: KeyboardCommandControlling? { get set }
  var keyboardShortcutValidator: KeyboardShortcutValidator? { get set }

  func receive(_ action: RecordedAction)
  func run(_ command: BuiltInCommand) -> CommandPublisher
}

public class RecordedAction {
  public var context: HotKeyContext?
  public var workflow: Workflow?

  public init(context: HotKeyContext? = nil, workflow: Workflow? = nil) {
    self.context = context
    self.workflow = workflow
  }
}

public class BuiltInCommandControllerMock: BuiltInCommandControlling {
  public var commandController: CommandControlling?
  public var currentContext: HotKeyContext?
  public var keyboardController: KeyboardCommandControlling?
  public var keyboardShortcutValidator: KeyboardShortcutValidator?
  public func receive(_ recordedAction: RecordedAction) { }
  public func run(_ command: BuiltInCommand) -> CommandPublisher {
    Future { promise in
      promise(.success(()))
    }.eraseToAnyPublisher()
  }
}
