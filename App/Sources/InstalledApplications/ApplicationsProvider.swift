import Apps
import Combine
import LogicFramework
import ModelKit
import ViewKit

final class ApplicationsProvider: StateController {
  @Published var state: [Application] = []

  init(applications: [Application]) {
    self.state = applications
  }
}
