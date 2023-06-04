import SwiftUI
import UniformTypeIdentifiers

struct GroupDebounce: DebounceSnapshot {
  let groups: Set<GroupViewModel.ID>
}

struct GroupsView: View {
  @Environment(\.controlActiveState) var controlActiveState

  enum Action {
    case openScene(AppScene)
    case selectGroups(Set<GroupViewModel.ID>)
    case moveGroups(source: IndexSet, destination: Int)
    case moveWorkflows(workflowIds: Set<ContentViewModel.ID>, groupId: GroupViewModel.ID)
    case copyWorkflows(workflowIds: Set<ContentViewModel.ID>, groupId: GroupViewModel.ID)
    case removeGroups(Set<GroupViewModel.ID>)
  }

  var namespace: Namespace.ID

  @EnvironmentObject private var publisher: GroupsPublisher
  @EnvironmentObject private var contentPublisher: ContentPublisher

  @ObservedObject var selectionManager: SelectionManager<GroupViewModel>

  private var focusPublisher = FocusPublisher<GroupViewModel>()
  private var focus: FocusState<AppFocus?>.Binding

  @State private var dropDestination: Int?

  private let debounceSelectionManager: DebounceManager<GroupDebounce>
  private let moveManager: MoveManager<GroupViewModel> = .init()
  private let onAction: (Action) -> Void

  init(_ focus: FocusState<AppFocus?>.Binding,
       namespace: Namespace.ID,
       selectionManager: SelectionManager<GroupViewModel>,
       onAction: @escaping (Action) -> Void) {
    self.focus = focus
    _selectionManager = .init(initialValue: selectionManager)
    self.onAction = onAction
    self.namespace = namespace
    self.debounceSelectionManager = .init(.init(groups: selectionManager.selections),
                                          milliseconds: 100,
                                          onUpdate: { snapshot in
      onAction(.selectGroups(snapshot.groups))
    })
  }

  @ViewBuilder
  var body: some View {
    GroupsListView(focus,
                   namespace: namespace,
                   focusPublisher: focusPublisher,
                   selectionManager: selectionManager, onAction: onAction)
    .focused(focus, equals: .groups)
  }

  private func overlayView() -> some View {
    VStack(spacing: 0) {
      LinearGradient(stops: [
        Gradient.Stop.init(color: .clear, location: 0),
        Gradient.Stop.init(color: .black.opacity(0.25), location: 0.25),
        Gradient.Stop.init(color: .black.opacity(0.75), location: 0.5),
        Gradient.Stop.init(color: .black.opacity(0.25), location: 0.75),
        Gradient.Stop.init(color: .clear, location: 1),
      ],
                     startPoint: .leading,
                     endPoint: .trailing)
      .frame(height: 1)
    }
    .allowsHitTesting(false)
    .shadow(color: Color(.black).opacity(0.25), radius: 2, x: 0, y: -2)
  }
}

struct GroupsView_Provider: PreviewProvider {
  @Namespace static var namespace
  @FocusState static var focus: AppFocus?
  static var previews: some View {
    GroupsView($focus, namespace: namespace,
               selectionManager: .init(),
               onAction: { _ in })
      .designTime()
  }
}

