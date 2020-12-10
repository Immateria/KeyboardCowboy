import ModelKit
import SwiftUI

struct WorkflowListToolbar: ToolbarContent {
  let group: ModelKit.Group
  let workflowController: WorkflowController

  var body: some ToolbarContent {
    ToolbarItemGroup(placement: .primaryAction) {
      Button(action: { workflowController.perform(.createWorkflow(in: group)) },
             label: {
              Image(systemName: "rectangle.stack.badge.plus")
                .renderingMode(.template)
                .foregroundColor(Color(.systemGray))
             })
        .help("Add Workflow to \"\(group.name)\"")
    }
  }
}
