import Combine
import Foundation
import ModelKit
import ViewKit

final class HUDFeatureController: StateController {
  @Published var state = [ModelKit.KeyboardShortcut]()

  func receive(_ newState: State) {
    state = newState
    objectWillChange.send()
  }
}
