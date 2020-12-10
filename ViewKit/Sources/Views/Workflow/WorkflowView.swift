import SwiftUI
import ModelKit

struct WorkflowConfig {
  var name: String
}

public struct WorkflowView: View {
  @State var config: WorkflowConfig

  public var body: some View {
    TextField("", text: $config.name)
  }
}

// MARK: - Previews

struct WorkflowView_Previews: PreviewProvider, TestPreviewProvider {
  static var previews: some View {
    testPreview.previewAllColorSchemes()
  }

  static var testPreview: some View {
    DesignTimeFactory().workflowDetail(
      .constant(ModelFactory().workflowDetail()),
      group: .constant(ModelFactory().groupList().first!))
      .frame(height: 668)
  }
}
