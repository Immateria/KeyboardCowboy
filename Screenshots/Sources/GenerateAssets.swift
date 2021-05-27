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

  func testGenerateKeyboardImage() {
    wait(for: [
      Generator.execute(KeyboardView(width: 400)
                          .rotation3DEffect(.degrees(50), axis: (x: 1, y: 0, z: 0))
                          .frame(width: 512, height: 150, alignment: .center)
                          .preferredColorScheme(.dark)
                        ,
                        name: "Keyboard-Dark",
                        size: CGSize(width: 512, height: 150)),
      Generator.execute(KeyboardView(width: 800)
                          .rotation3DEffect(.degrees(50), axis: (x: 1, y: 0, z: 0))
                          .frame(width: 1024, height: 300, alignment: .center)
                          .preferredColorScheme(.dark),
                        name: "Keyboard-Dark@2x",
                        size: CGSize(width: 1024, height: 300)),

      Generator.execute(KeyboardView(width: 400)
                          .rotation3DEffect(.degrees(50), axis: (x: 1, y: 0, z: 0))
                          .frame(width: 512, height: 150, alignment: .center)
                          .preferredColorScheme(.light)
                        ,
                        name: "Keyboard-Light",
                        size: CGSize(width: 512, height: 150)),
      Generator.execute(KeyboardView(width: 800)
                          .rotation3DEffect(.degrees(50), axis: (x: 1, y: 0, z: 0))
                          .frame(width: 1024, height: 300, alignment: .center)
                          .preferredColorScheme(.light),
                        name: "Keyboard-Light@2x",
                        size: CGSize(width: 1024, height: 300))
    ], timeout: 10)
  }

  func testGenerateMenubarIcons() {
    wait(for: [
      Generator.execute(MenubarIcon(color: Color(.textColor), size: CGSize(width: 11, height: 11)).preferredColorScheme(.light),
                        name: "MenubarIcon-Light",
                        size: CGSize(width: 11, height: 11)),
      Generator.execute(MenubarIcon(color: Color(.textColor), size: CGSize(width: 22, height: 22)).preferredColorScheme(.light),
                        name: "MenubarIcon-Light@2x",
                        size: CGSize(width: 22, height: 22)),

      Generator.execute(MenubarIcon(color: Color(.textColor), size: CGSize(width: 11, height: 11)).preferredColorScheme(.dark),
                        name: "MenubarIcon-Dark",
                        size: CGSize(width: 11, height: 11)),
      Generator.execute(MenubarIcon(color: Color(.textColor), size: CGSize(width: 22, height: 22)).preferredColorScheme(.dark),
                        name: "MenubarIcon-Dark@2x",
                        size: CGSize(width: 22, height: 22)),

      Generator.execute(MenubarIcon(color: Color.accentColor, size: CGSize(width: 11, height: 11)).preferredColorScheme(.light),
                        name: "MenubarIcon-Light-Active",
                        size: CGSize(width: 11, height: 11)),
      Generator.execute(MenubarIcon(color: Color.accentColor, size: CGSize(width: 22, height: 22)).preferredColorScheme(.light),
                        name: "MenubarIcon-Light-Active@2x",
                        size: CGSize(width: 22, height: 22)),

      Generator.execute(MenubarIcon(color: Color.accentColor, size: CGSize(width: 11, height: 11)).preferredColorScheme(.dark),
                        name: "MenubarIcon-Dark-Active",
                        size: CGSize(width: 11, height: 11)),
      Generator.execute(MenubarIcon(color: Color.accentColor, size: CGSize(width: 22, height: 22)).preferredColorScheme(.dark),
                        name: "MenubarIcon-Dark-Active@2x",
                        size: CGSize(width: 22, height: 22)),
    ], timeout: 10)
  }
}
