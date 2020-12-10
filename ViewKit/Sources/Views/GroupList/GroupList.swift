import SwiftUI
import ModelKit

public struct GroupList: View {
  public enum Action {
    case createGroup
    case updateGroup(ModelKit.Group)
    case deleteGroup(ModelKit.Group)
    case moveGroup(from: Int, to: Int)
    case dropFile([URL])
  }

  public enum SheetAction: Identifiable {
    case edit(ModelKit.Group)
    case delete(ModelKit.Group)

    public var id: String { return UUID().uuidString }
  }

  let applicationProvider: ApplicationProvider
  let factory: ViewFactory
  let groupController: GroupController
  let workflowController: WorkflowController
  @StateObject var store: ViewKitStore
  @StateObject var groupStore: GroupStore
  @StateObject var workflowStore: WorkflowStore
  @State private var sheetAction: SheetAction?
  @State private var isDropping: Bool = false

  public var body: some View {
    List {
      ForEach(store.groups, id: \.id) { group in
        NavigationLink(
          destination: factory.workflowList(
            group: Binding<ModelKit.Group>(
              get: { group },
              set: { groupStore.group = $0 }
            ),
            selectedWorkflow: Binding<Workflow?>(
              get: {
                workflowStore.workflow
              }, set: {
                workflowStore.workflow = $0
              })
          ),
          tag: group,
          selection: Binding<ModelKit.Group?>(get: {
            groupStore.group
          }, set: {
            if $0 != nil {
              groupStore.group = $0
            }
          }) ) {
          GroupListCell(
            name: group.name,
            color: group.color,
            symbol: group.symbol,
            count: group.workflows.count,
            editAction: { sheetAction = .edit(group) }
          ).tag(group.id)
        }
        .frame(minHeight: 36)
        .contextMenu {
          Button("Show Info") { sheetAction = .edit(group) }
          Divider()
          Button("Delete", action: onDelete)
        }
      }
      .onInsert(of: []) { _, _ in }
      .onMove(perform: onMove)
    }
    .onDrop($isDropping) { groupController.perform(.dropFile($0)) }
    .border(Color.accentColor, width: isDropping ? 5 : 0)
    .onDeleteCommand(perform: onDelete)
    .toolbar(content: { GroupListToolbar(groupController: groupController) })
    .sheet(item: $sheetAction, content: sheetContent)
  }
}

// MARK: - Subviews

private extension GroupList {
  @ViewBuilder
  func sheetContent(_ action: SheetAction) -> some View {
    switch action {
    case .edit(let group):
      editGroup(group)
    case .delete(let group):
      VStack(spacing: 0) {
        Text("Are you sure you want to delete the group “\(group.name)”?")
          .padding()
        Divider()
        HStack {
          Button("Cancel", action: {
            sheetAction = nil
          }).keyboardShortcut(.cancelAction)
          Button("Delete", action: {
            sheetAction = nil
            groupController.perform(.deleteGroup(group))
          }).keyboardShortcut(.defaultAction)
        }.padding()
      }
    }
  }

  func editGroup(_ group: ModelKit.Group) -> some View {
    EditGroup(
      name: group.name,
      color: group.color,
      symbol: group.symbol,
      bundleIdentifiers: group.rule?.bundleIdentifiers ?? [],
      applicationProvider: applicationProvider.erase(),
      editAction: { name, color, symbol, bundleIdentifers in
        var group = group
        group.name = name
        group.color = color
        group.symbol = symbol

        var rule = group.rule ?? Rule()

        if !bundleIdentifers.isEmpty {
          rule.bundleIdentifiers = bundleIdentifers
          group.rule = rule
        } else {
          group.rule = nil
        }

        groupController.perform(.updateGroup(group))
        sheetAction = nil
      },
      cancelAction: { sheetAction = nil })
  }

  func onMove(indices: IndexSet, offset: Int) {
    for i in indices {
      groupController.action(.moveGroup(from: i, to: offset))()
    }
  }

  func onDelete() {
    if let group = groupStore.group {
      if group.workflows.isEmpty {
        groupController.perform(.deleteGroup(group))
      } else {
        sheetAction = .delete(group)
      }
    }
  }
}

// MARK: - Previews

struct GroupList_Previews: PreviewProvider, TestPreviewProvider {
  static var previews: some View {
    testPreview.previewAllColorSchemes()
  }

  static var testPreview: some View {
    DesignTimeFactory().groupList(store: ViewKitStore(groups: []))
      .frame(width: 300)
  }
}
