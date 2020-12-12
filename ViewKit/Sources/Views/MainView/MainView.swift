import SwiftUI
import ModelKit

public struct MainView: View {
  @ObservedObject var store: ViewKitStore
  @AppStorage("groupSelection") var groupSelection: String?
  @AppStorage("workflowSelection") var workflowSelection: String?
  let groupController: GroupController

  public init(store: ViewKitStore, groupController: GroupController) {
    self.store = store
    self.groupController = groupController
  }

  @ViewBuilder
  public var body: some View {
    NavigationView {
      SidebarView(store: store,
                  selection: $groupSelection,
                  workflowSelection: $workflowSelection)
        .toolbar(content: { GroupListToolbar(groupController: groupController) })
      ListPlaceHolder()
      DetailViewPlaceHolder()
    }
  }
}

struct MainView_Previews: PreviewProvider, TestPreviewProvider {
  static var previews: some View {
    testPreview.previewAllColorSchemes()
  }

  static var testPreview: some View {
    MainView(store: .init(context: .preview()),
             groupController: GroupPreviewController().erase())
    .frame(width: 960, height: 620, alignment: .leading)
  }
}
