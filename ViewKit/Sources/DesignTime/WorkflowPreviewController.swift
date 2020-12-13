import ModelKit

final class WorkflowPreviewController: ViewController {
  var state: Workflow = ModelKit.Workflow.empty()
  func perform(_ action: WorkflowList.Action) {}
}
