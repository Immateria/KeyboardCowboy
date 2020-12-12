import ModelKit
import SwiftUI

struct DetailToolbarConfig {
  var showSearch: Bool = false
  var searchQuery: String = ""
}

struct DetailView: View {
  @AppStorage("groupSelection") var groupSelection: String?
  @State private var sheet: CommandListView.Sheet?
  @State private var config = DetailToolbarConfig()
  @State private var isDropping: Bool = false
  let context: ViewKitFeatureContext
  let workflow: Workflow

  var body: some View {
    ScrollView {
      VStack {
        VStack {
          WorkflowView(workflow, workflowController: context.workflow)
          KeyboardShortcutList(workflow: workflow,
                               performAction: context.keyboardsShortcuts.perform(_:))
            .cornerRadius(8)
        }.padding()
      }.background(Color(.textBackgroundColor))

      VStack {
        CommandListView(workflow: workflow,
                        perform: context.commands.perform(_:),
                        receive: { sheet = $0 })
      }.onDrop($isDropping) { urls in
        context.commands.perform(.drop(urls, workflow))
      }.overlay(
        RoundedRectangle(cornerRadius: 8)
          .stroke(Color.accentColor, lineWidth: isDropping ? 5 : 0)
          .padding(4)
      )
    }.toolbar(content: {
      DetailViewToolbar(
        config: $config,
        sheet: $sheet,
        workflowName: workflow.name,
        searchController: context.search)
    })
    .background(gradient)
    .sheet(item: $sheet, content: { receive($0) })
  }
}

// MARK: Extensions

extension DetailView {
  var gradient: some View {
    LinearGradient(
      gradient: Gradient(
        stops: [
          .init(color: Color(.windowBackgroundColor).opacity(0.25), location: 0.8),
          .init(color: Color(.gridColor).opacity(0.75), location: 1.0),
        ]),
      startPoint: .top,
      endPoint: .bottom)
  }

  @ViewBuilder
  func receive(_ action: CommandListView.Sheet) -> some View {
    switch action {
    case .create(let command):
      EditCommandView(applicationProvider: context.applicationProvider, openPanelController: context.openPanel,
                      saveAction: { newCommand in
                        context.commands.perform(.create(newCommand, in: workflow))
                        sheet = nil
                      },
                      cancelAction: { sheet = nil },
                      selection: command,
                      command: command)
    case .edit(let command):
      EditCommandView(applicationProvider: context.applicationProvider, openPanelController: context.openPanel,
                      saveAction: { command in
                        context.commands.perform(.edit(command, in: workflow))
                        sheet = nil
                      },
                      cancelAction: { sheet = nil },
                      selection: command,
                      command: command)
    }
  }
}

struct DetailViewPlaceHolder: View {
  var body: some View {
    Text("Select a workflow")
  }
}
