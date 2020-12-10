import SwiftUI
import ModelKit

public protocol ViewFactory {
  func mainView(store: ViewKitStore) -> MainView
  func groupList(store: ViewKitStore) -> GroupList
  func workflowList(group: Binding<ModelKit.Group>,
                    selectedWorkflow: Binding<Workflow?>) -> WorkflowList
  func workflowDetail(_ workflow: Binding<ModelKit.Workflow>,
                      group: Binding<ModelKit.Group>) -> WorkflowView
}
