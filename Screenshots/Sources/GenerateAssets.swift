@testable import Keyboard_Cowboy
@testable import ViewKit
import Cocoa
import Foundation
import SwiftUI
import XCTest

class GenerateAssets: XCTestCase {
  func testGenerateKeyboardSettingsIcon() throws {
    wait(for: [
      Generator.execute(CommandKeyIcon().preferredColorScheme(.light), name: "KeyboardSettings-Light", size: CGSize(width: 48, height: 48)),
      Generator.execute(CommandKeyIcon().preferredColorScheme(.light), name: "KeyboardSettings-Light@2x", size: CGSize(width: 96, height: 96)),

      Generator.execute(CommandKeyIcon().preferredColorScheme(.dark), name: "KeyboardSettings-Dark", size: CGSize(width: 48, height: 48)),
      Generator.execute(CommandKeyIcon().preferredColorScheme(.dark), name: "KeyboardSettings-Dark@2x", size: CGSize(width: 96, height: 96)),
    ], timeout: 10)
  }
}
