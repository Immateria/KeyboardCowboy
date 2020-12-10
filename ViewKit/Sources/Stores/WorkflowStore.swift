import ModelKit
import SwiftUI

public class WorkflowStore: ObservableObject {
  @Published public var workflow: ModelKit.Workflow?

  public init(workflow: ModelKit.Workflow?) {
    self.workflow = workflow
  }
}
