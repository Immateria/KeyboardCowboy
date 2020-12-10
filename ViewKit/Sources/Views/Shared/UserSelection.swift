import SwiftUI
import ModelKit

public class UserSelection {
  @Published public var group: ModelKit.Group? {
    didSet { print("didSet.group") }
  }
  @Published public var workflow: Workflow? {
    didSet { print("didSet.workflow") }
  }

  public init(group: ModelKit.Group? = nil, workflow: ModelKit.Workflow? = nil) {
    self.workflow = workflow
  }
}
