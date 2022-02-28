import Apps
import SwiftUI

struct WorkflowCommandsListView: View, Equatable {
  enum Focusable: Hashable {
    case none
    case row(id: String)
  }

  @Binding var workflow: Workflow

  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Label("Commands:", image: "")
          .labelStyle(HeaderLabelStyle())
        Spacer()
      }
      LazyVStack {
        ForEach($workflow.commands, id: \.self, content: { command in
          ResponderView(command) { responder in
            CommandView(command: command, responder: responder)
          }
        })
      }
    }
  }

  static func == (lhs: WorkflowCommandsListView, rhs: WorkflowCommandsListView) -> Bool {
    lhs.workflow.commands == rhs.workflow.commands
  }
}

struct WorkflowCommandsView_Previews: PreviewProvider {
  static var previews: some View {
    WorkflowCommandsListView(workflow: .constant(Workflow.designTime(.application([
      ApplicationTrigger.init(application: Application.finder())
    ]))))
  }
}
