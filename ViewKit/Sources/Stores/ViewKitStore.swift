import ModelKit
import SwiftUI

open class ViewKitStore: ObservableObject {
  @Published public var groups: [ModelKit.Group]

  public init(groups: [ModelKit.Group] = []) {
    self.groups = groups
  }
}
