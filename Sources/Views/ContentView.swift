import SwiftUI

struct ContentView: View, Equatable {
  static func ==(lhs: ContentView, rhs: ContentView) -> Bool {
    return true
  }
  @StateObject var store: Saloon

  @State var detailViewSheet: WorkflowView.Sheet?
  @State var sidebarViewSheet: SidebarView.Sheet?

  @Binding private var selectedGroups: [WorkflowGroup]
  @Binding private var selectedWorkflows: [Workflow]

  @AppStorage("selectedGroupIds") private var groupIds = Set<String>()
  @AppStorage("selectedWorkflowIds") private var workflowIds = Set<String>()

  @FocusState private var focus: Focus?

  init(store: Saloon) {
    _store = .init(wrappedValue: store)
    _selectedGroups = .init(get: { store.groupStore.selectedGroups },
                            set: { store.groupStore.selectedGroups = $0 })
    _selectedWorkflows = .init(get: { store.selectedWorkflows },
                               set: { store.selectedWorkflows = $0 })

    focus = .main(.groupComponent)
  }

  var body: some View {
    NavigationView {
      SidebarView(appStore: store.applicationStore,
                  configurationStore: store.configurationStore,
                  focus: _focus,
                  groupStore: store.groupStore,
                  saloon: store,
                  sheet: $sidebarViewSheet,
                  selection: $groupIds)
      .toolbar {
        SidebarToolbar(configurationStore: store.configurationStore,
                       focus: _focus,
                       saloon: store,
                       action: handleSidebar(_:))
      }
      .frame(minWidth: 200, idealWidth: 310)
      .onChange(of: groupIds, perform: { store.selectGroupsIds($0) })

      MainView(action: handleMainAction(_:),
               applicationStore: store.applicationStore,
               focus: _focus, store: store.groupStore, selection: $workflowIds)
      .toolbar { MainViewToolbar(action: handleToolbarAction(_:)) }
      .frame(minWidth: 270)
      .onChange(of: workflowIds, perform: { workflowIds in
        store.selectWorkflowIds(workflowIds)
      })

      DetailView(applicationStore: store.applicationStore,
                 focus: _focus,
                 workflows: $store.selectedWorkflows,
                 sheet: $detailViewSheet,
                 action: handleDetailAction(_:))
      .equatable()
      .toolbar { DetailToolbar(action: handleDetailToolbarAction(_:)) }
      // Handle workflow updates
      .onChange(of: selectedWorkflows, perform: { workflows in
        store.updateWorkflows(workflows)
      })
      .frame(minWidth: 380, minHeight: 417)
    }
    .searchable(text: .constant(""))
  }

  // MARK: Private methods

  private func handleSidebar(_ action: SidebarToolbar.Action) {
    switch action {
    case .addGroup:
      let group = WorkflowGroup.empty()
      sidebarViewSheet = .edit(group)
      store.groupStore.add(group)
      groupIds = [group.id]
    case .toggleSidebar:
      NSApp.keyWindow?.firstResponder?.tryToPerform(
        #selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
  }

  private func handleMainAction(_ action: MainView.Action) {
    switch action {
    case .add:
      break
    case .delete(let workflow):
      store.groupStore.remove(workflow)
    }
  }

  private func handleToolbarAction(_ action: MainViewToolbar.Action) {
    switch action {
    case .add:
      let workflow = Workflow.empty()
      store.groupStore.add(workflow)
      workflowIds = [workflow.id]
      DispatchQueue.main.async {
        focus = .detail(.info(workflow))
      }
    }
  }

  private func handleDetailToolbarAction(_ action: DetailToolbar.Action) {
    switch action {
    case .addCommand:
      guard !selectedWorkflows.isEmpty else { return }

      let command: Command = .empty(.application)
      selectedWorkflows[0].commands.append(command)
      detailViewSheet = .edit(command)
    }
  }

  private func handleDetailAction(_ action: DetailView.Action) -> Void {
    switch action {
    case .workflow(let detailAction):
      switch detailAction {
      case .workflow(let workflowAction):
        switch workflowAction {
        case .commandView(let commandViewAction):
          switch commandViewAction {
          case .commandAction(let commandAction):
            switch commandAction {
            case .edit:
              break
            case .run:
              break
            case .reveal:
              break
            }
          }
        }
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var store = Saloon()
  static var previews: some View {
    ContentView(store: store)
      .frame(width: 960, height: 480)
  }
}
