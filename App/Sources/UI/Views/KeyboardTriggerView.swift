import SwiftUI

struct KeyboardTriggerView: View {
  private let data: DetailViewModel
  private let namespace: Namespace.ID
  private let onAction: (SingleDetailView.Action) -> Void
  private let trigger: DetailViewModel.KeyboardTrigger
  private let focus: FocusState<AppFocus?>.Binding
  private let keyboardShortcutSelectionManager: SelectionManager<KeyShortcut>

  @State private var passthrough: Bool

  init(namespace: Namespace.ID,
       focus: FocusState<AppFocus?>.Binding,
       data: DetailViewModel,
       trigger: DetailViewModel.KeyboardTrigger,
       keyboardShortcutSelectionManager: SelectionManager<KeyShortcut>,
       onAction: @escaping (SingleDetailView.Action) -> Void) {
    self.namespace = namespace
    self.focus = focus
    self.data = data
    self.trigger = trigger
    self.onAction = onAction
    self.keyboardShortcutSelectionManager = keyboardShortcutSelectionManager
    _passthrough = .init(initialValue: trigger.passthrough)
  }

  var body: some View {
    HStack {
      Button(action: {
        onAction(.removeTrigger(workflowId: data.id))
      },
             label: { Image(systemName: "xmark") })
      .buttonStyle(.appStyle)
      Label("Keyboard Shortcuts sequence:", image: "")
        .padding(.trailing, 12)
      Spacer()
      Toggle("Passthrough", isOn: $passthrough)
        .font(.caption)
        .onChange(of: passthrough) { newValue in
          onAction(.togglePassthrough(workflowId: data.id, newValue: newValue))
        }
    }
    .padding([.leading, .trailing], 8)

    WorkflowShortcutsView(focus, data: trigger.shortcuts, selectionManager: keyboardShortcutSelectionManager) { keyboardShortcuts in
      onAction(.updateKeyboardShortcuts(workflowId: data.id, keyboardShortcuts: keyboardShortcuts))
    }
    .matchedGeometryEffect(id: "workflow-triggers", in: namespace)
  }
}
