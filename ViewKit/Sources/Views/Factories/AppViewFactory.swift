import ModelKit
import SwiftUI

public class AppViewFactory: ViewFactory {
  let applicationProvider: ApplicationProvider
  let commandController: CommandController
  let groupController: GroupController
  let keyboardShortcutController: KeyboardShortcutController
  let openPanelController: OpenPanelController
  let searchController: SearchController
  let workflowController: WorkflowController

  let groupStore: GroupStore
  let workflowStore: WorkflowStore

  public init(applicationProvider: ApplicationProvider,
              commandController: CommandController,
              groupController: GroupController,
              keyboardShortcutController: KeyboardShortcutController,
              openPanelController: OpenPanelController,
              searchController: SearchController,
              workflowController: WorkflowController,
              groupStore: GroupStore,
              workflowStore: WorkflowStore
  ) {
    self.applicationProvider = applicationProvider
    self.commandController = commandController
    self.groupController = groupController
    self.keyboardShortcutController = keyboardShortcutController
    self.openPanelController = openPanelController
    self.searchController = searchController
    self.workflowController = workflowController
    self.groupStore = groupStore
    self.workflowStore = workflowStore
  }

  public func mainView(store: ViewKitStore) -> MainView {
    MainView(factory: self,
             workflowController: workflowController,
             store: store,
             groupStore: groupStore,
             workflowStore: workflowStore)
  }

  public func groupList(store: ViewKitStore) -> GroupList {
    GroupList(
      applicationProvider: applicationProvider,
      factory: self,
      groupController: groupController,
      workflowController: workflowController,
      store: store,
      groupStore: self.groupStore,
      workflowStore: self.workflowStore)
  }

  public func workflowList(group: Binding<ModelKit.Group>, selectedWorkflow: Binding<Workflow?>) -> WorkflowList {
    WorkflowList(factory: self, group: group,
                 searchController: searchController,
                 workflowController: workflowController,
                 selection: selectedWorkflow)
  }
}
