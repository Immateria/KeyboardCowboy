import Combine
import ModelKit
import SwiftUI

final public class WizardStore {
  @AppStorage("hasFinishedWizard") private(set) public var hasFinishedWizard: Bool = false
  @Published public var finishedWizard: Bool = false
  private var configuration: SetupView.Configuration = .skip

  public init() {}

  func receive(_ configuration: SetupView.Configuration) {
    self.configuration = configuration
    hasFinishedWizard = true
    finishedWizard = true
  }

  public func postConfiguration(_ applications: [Application]) -> [ModelKit.Group]? {
    switch configuration {
    case .empty:
      return []
    case .examples:
      return WizardGroupExamples.groups(applications)
    case .skip:
      return nil
    }
  }
}
