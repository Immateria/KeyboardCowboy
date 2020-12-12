import SwiftUI
import ModelKit

struct WorkflowConfig {
  var name: String {
    get { workflow.name }
    set { workflow.name = newValue }
  }
  private(set) var workflow: Workflow
}

public struct WorkflowView: View {
  let workflowController: WorkflowController
  @State var config: WorkflowConfig

  init(_ workflow: Workflow, workflowController: WorkflowController) {
    _config = .init(initialValue: WorkflowConfig(workflow: workflow))
    self.workflowController = workflowController
  }

  public var body: some View {
    TextField("", text: $config.name, onCommit: {
      workflowController.perform(.update(config.workflow))
    })
      .font(.largeTitle)
      .foregroundColor(.primary)
      .textFieldStyle(PlainTextFieldStyle())
  }
}

// MARK: - Previews

struct WorkflowView_Previews: PreviewProvider, TestPreviewProvider {
  static var previews: some View {
    testPreview.previewAllColorSchemes()
  }

  static var testPreview: some View {
    WorkflowView(ModelFactory().workflowDetail(),
                 workflowController: WorkflowPreviewController().erase())
      .frame(height: 668)
  }
}
