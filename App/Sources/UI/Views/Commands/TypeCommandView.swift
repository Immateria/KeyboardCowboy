import SwiftUI

struct TypeCommandView: View {
  enum Action {
    case updateName(newName: String)
    case updateSource(newInput: String)
    case updateMode(newMode: TypeCommand.Mode)
    case commandAction(CommandContainerAction)
  }
  @State var metaData: CommandViewModel.MetaData
  @State var model: CommandViewModel.Kind.TypeModel
  private let debounce: DebounceManager<String>
  private let onAction: (Action) -> Void

  init(_ metaData: CommandViewModel.MetaData,
       model: CommandViewModel.Kind.TypeModel,
       onAction: @escaping (Action) -> Void) {
    _metaData = .init(initialValue: metaData)
    _model = .init(initialValue: model)
    debounce = DebounceManager(for: .milliseconds(500)) { newInput in
      onAction(.updateSource(newInput: newInput))
    }
    self.onAction = onAction
  }

  var body: some View {
    CommandContainerView(
      $metaData,
      icon: { metaData in
        ZStack {
          Rectangle()
            .fill(Color(.controlAccentColor).opacity(0.375))
            .cornerRadius(8, antialiased: false)
          RegularKeyIcon(letter: "(...)", width: 24, height: 24)
            .frame(width: 16, height: 16)
        }
      }, content: { metaData in
        AppTextEditor(text: $model.input, placeholder: "Enter text...", onCommandReturnKey: nil)
          .onChange(of: model.input) { debounce.send($0) }
      }, subContent: { _ in
        TypeCommandModeView(mode: model.mode) { newMode in
          onAction(.updateMode(newMode: newMode))
        }
      }, onAction: { onAction(.commandAction($0)) })
  }
}

fileprivate struct TypeCommandModeView: View {
  @State var mode: TypeCommand.Mode
  private let onAction: (TypeCommand.Mode) -> Void

  init(mode: TypeCommand.Mode, onAction: @escaping (TypeCommand.Mode) -> Void) {
    _mode = .init(initialValue: mode)
    self.onAction = onAction
  }

  var body: some View {
    Menu(content: {
      ForEach(TypeCommand.Mode.allCases) { mode in
        Button(action: {
          self.mode = mode
          onAction(mode)
        }, label: { Text(mode.rawValue) })
      }
    }, label: {
      Text(mode.rawValue)
        .font(.caption)
    })
    .menuStyle(AppMenuStyle(.init(nsColor: .systemGray, grayscaleEffect: false)))
  }
}

struct TypeCommandView_Previews: PreviewProvider {
  static let command = DesignTime.typeCommand
  static var previews: some View {
    TypeCommandView(command.model.meta, 
                    model: command.kind) { _ in }
      .designTime()
      .frame(idealHeight: 120, maxHeight: 180)
  }
}

