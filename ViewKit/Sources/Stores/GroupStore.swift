import ModelKit
import SwiftUI

public class GroupStore: ObservableObject {
  @Published public var group: ModelKit.Group? {
    willSet {
      if newValue == nil {
        
      }
    }
    didSet { Swift.print("did set group: \(group?.id)") }
  }

  public init(group: ModelKit.Group?) {
    self.group = group
  }
}
