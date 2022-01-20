import LogicFramework
import ModelKit

class CommandControllerMock: CommandControlling {
  typealias Handler = ([Command]) -> Void
  weak var delegate: CommandControllingDelegate?
  var handler: Handler
  var currentContext: HotKeyContext?
  var previousAction: RecordedAction = RecordedAction(context: nil, workflow: nil)

  init(_ handler: @escaping Handler) {
    self.handler = handler
  }

  func run(_ commands: [Command]) {
    handler(commands)
  }
}
