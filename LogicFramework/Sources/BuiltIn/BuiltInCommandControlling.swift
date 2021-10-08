import Combine
import Foundation
import ModelKit

public protocol BuiltInCommandControlling: AnyObject {
  var commandController: CommandControlling? { get set }
  var currentContext: HotKeyContext? { get set }
  var keyboardController: KeyboardCommandControlling? { get set }
  var previousAction: (context: HotKeyContext?, workflow: Workflow?) { get set }
  var keyboardShortcutValidator: KeyboardShortcutValidator? { get set }

  func run(_ command: BuiltInCommand) -> CommandPublisher
}

public class BuiltInCommandControllerMock: BuiltInCommandControlling {
  public var commandController: CommandControlling?
  public var currentContext: HotKeyContext?
  public var keyboardController: KeyboardCommandControlling?
  public var keyboardShortcutValidator: KeyboardShortcutValidator?
  public var previousAction: (context: HotKeyContext?, workflow: Workflow?) = (context: nil, workflow: nil)
  public func run(_ command: BuiltInCommand) -> CommandPublisher {
    Future { promise in
      promise(.success(()))
    }.eraseToAnyPublisher()
  }
}
