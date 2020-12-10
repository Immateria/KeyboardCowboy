import ModelKit
import SwiftUI

public class DesignTimeFactory: ViewFactory {
  let applicationProvider = ApplicationPreviewProvider().erase()
  let commandController = CommandPreviewController().erase()
  let groupController = GroupPreviewController().erase()
  let keyboardShortcutController = KeyboardShortcutPreviewController().erase()
  let openPanelController = OpenPanelPreviewController().erase()
  let searchController = SearchPreviewController().erase()
  let workflowController = WorkflowPreviewController().erase()

  public func mainView(store: ViewKitStore) -> MainView {
    MainView(factory: self,
             workflowController: workflowController,
             store: store,
             groupStore: GroupStore(group: nil),
             workflowStore: WorkflowStore(workflow: nil))
  }

  public func groupList(store: ViewKitStore) -> GroupList {
    GroupList(applicationProvider: applicationProvider,
              factory: self,
              groupController: groupController,
              workflowController: workflowController,
              store: store,
              groupStore: GroupStore(group: nil),
              workflowStore: WorkflowStore(workflow: nil))
  }

  public func workflowList(group: Binding<ModelKit.Group>,
                           selectedWorkflow: Binding<Workflow?>) -> WorkflowList {
    WorkflowList(
      factory: self,
      group: .constant(ModelFactory().groupList().first!),
      searchController: searchController,
      workflowController: workflowController,
      selection: .constant(nil))
  }

  public func workflowDetail(_ workflow: Binding<Workflow>, group: Binding<ModelKit.Group>) -> WorkflowView {
    WorkflowView(workflow: .constant(ModelFactory().workflowDetail()),
                 group: .constant(ModelFactory().groupList().first!),
                 applicationProvider: applicationProvider,
                 commandController: commandController,
                 keyboardShortcutController: keyboardShortcutController,
                 openPanelController: openPanelController,
                 searchController: searchController,
                 workflowController: workflowController)
  }
}
