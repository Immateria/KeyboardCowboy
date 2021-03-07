import ModelKit
import SwiftUI

struct WorkflowListToolbar: ToolbarContent {
  let action: () -> Void
  let groupId: String?
  let workflowsController: WorkflowsController

  var body: some ToolbarContent {
    ToolbarItemGroup(placement: .primaryAction) {
      Button(action: {
        workflowsController.perform(.create(groupId: groupId))
        action()
      },
      label: {
        Image(systemName: "rectangle.stack.badge.plus")
          .renderingMode(.template)
          .foregroundColor(Color(.systemGray))
      })
    }
  }
}
