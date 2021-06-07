@testable import Keyboard_Cowboy
@testable import ViewKit
import ModelKit
import Cocoa
import Foundation
import SwiftUI
import XCTest

private extension ColorScheme {
  var name: String {
    switch self {
    case .dark:
      return "Dark"
    case .light:
      return "Light"
    @unknown default:
      fatalError("Unsupported color scheme")
    }
  }
}

class GenerateAssets: XCTestCase {
  private func iterate(_ handler: (Int, ColorScheme, String) -> Void) {
    for colorScheme in ColorScheme.allCases {
      for x in 1...2 {
        handler(x, colorScheme, x > 1 ? "@2x" : "")
      }
    }
  }

  func testGenerateKeyboardSettingsIcon() throws {
    var expectations = [XCTestExpectation]()

    iterate { x, colorScheme, suffix in
      let size: CGFloat = 48 * CGFloat(x)
      let name = "KeyboardSettings-\(colorScheme.name)\(suffix)"
      let view = CommandKeyIcon().preferredColorScheme(colorScheme).frame(height: size)
      expectations.append(Generator.execute(view, name: name, size: CGSize(width: size, height: size)))
    }

    wait(for: expectations, timeout: 10.0)
  }

  func testGenerateKeyboardImage() {
    var expectations = [XCTestExpectation]()

    iterate { x, colorScheme, suffix in
      let size = CGSize(width: 512 * CGFloat(x), height: 150 * CGFloat(x))
      expectations.append(
        Generator.execute(KeyboardView(width: 400 * CGFloat(x))
                            .rotation3DEffect(.degrees(50), axis: (x: 1, y: 0, z: 0))
                            .frame(width: size.width, height: size.height,
                                   alignment: .center)
                            .preferredColorScheme(colorScheme),
                          name: "Keyboard-\(colorScheme.name)\(suffix)",
                          size: size)
        )
    }

    wait(for: expectations, timeout: 10.0)
  }

  func testGenerateMenubarIcons() {
    var expectations = [XCTestExpectation]()

    iterate { x, colorScheme, suffix in
      let size = CGSize(width: 11 * CGFloat(x), height: 11 * CGFloat(x))
      expectations.append(contentsOf: [
        Generator.execute(
          MenubarIcon(color: Color(.textColor), size: size).preferredColorScheme(colorScheme),
          name: "MenubarIcon-\(colorScheme)\(suffix)",
          size: size),

        Generator.execute(
          MenubarIcon(color: Color.accentColor, size: size).preferredColorScheme(colorScheme),
          name: "MenubarIcon-\(colorScheme)-Active\(suffix)",
          size: size)
      ])
    }

    wait(for: expectations, timeout: 10.0)
  }

  func testGenerateKeyboardShortcutAsset() {
    var expectations = [XCTestExpectation]()

    iterate { x, colorScheme, suffix in

      let hudProvider = HUDPreviewProvider()
      hudProvider.state = [
        ModelKit.KeyboardShortcut(key: "A", modifiers: [.function, .shift]),
        ModelKit.KeyboardShortcut(key: "F", modifiers: []),
        ModelKit.KeyboardShortcut(key: "Open Terminal", modifiers: [])
      ]

      let size = CGSize(width: 500 * CGFloat(x),
                        height: 500 * CGFloat(x))
      let view = HUDStack(hudProvider: hudProvider.erase(),
                          height: 32 * CGFloat(x))
        .preferredColorScheme(colorScheme)

      expectations.append(
        Generator.execute(view,
                          name: "KeyboardShortcuts-\(colorScheme.name)\(suffix)",
                          size: size)
      )
    }

    wait(for: expectations, timeout: 10.0)
  }
}
