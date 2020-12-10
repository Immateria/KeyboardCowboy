import SwiftUI
import ModelKit

public struct MainView: View {
  let factory: ViewFactory
  let workflowController: WorkflowController

  var groupStore: GroupStore
  var workflowStore: WorkflowStore

  @ObservedObject var store: ViewKitStore

  public init(factory: ViewFactory,
              workflowController: WorkflowController,
              store: ViewKitStore,
              groupStore: GroupStore,
              workflowStore: WorkflowStore) {
    self.factory = factory
    self.workflowController = workflowController
    self.store = store
    self.groupStore = groupStore
    self.workflowStore = workflowStore
  }

  @ViewBuilder
  public var body: some View {
    NavigationView {
      SidebarView(factory: factory, store: store)
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
      ListPlaceHolder()
      DetailView(factory: factory, store: store,
                 groupStore: groupStore, workflowStore: workflowStore,
                 workflowController: workflowController)
    }
  }
}

struct MainView_Previews: PreviewProvider, TestPreviewProvider {
  static var previews: some View {
    testPreview.previewAllColorSchemes()
  }

  static var testPreview: some View {
    DesignTimeFactory().mainView(
      store: ViewKitStore(groups: [])
    )
    .frame(width: 960, height: 620, alignment: .leading)
  }
}
