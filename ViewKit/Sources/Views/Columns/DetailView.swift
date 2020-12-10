import ModelKit
import SwiftUI

struct DetailView: View {
  let factory: ViewFactory
  @ObservedObject var store: ViewKitStore
  @ObservedObject var groupStore: GroupStore
  @ObservedObject var workflowStore: WorkflowStore
  let workflowController: WorkflowController

  @ViewBuilder
  var body: some View {
    WorkflowView(config: WorkflowConfig(name: "Foobar"))
  }
}
