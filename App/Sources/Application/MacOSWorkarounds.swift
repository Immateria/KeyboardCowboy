import Cocoa
import InterposeKit
import OSLog

/// Hack tow work around Assertion failure in -[NSTouchBarLayout setLeadingWidgetWidth:], NSTouchBarLayout.m:78
/// This sometimes happens when macOS restores a window.
/// This even runs if there is no OS-level touch bar.
/// Reference: https://gist.github.com/steipete/aa76f34c39b76e2f3fd284f4af18b919
class MacOSWorkarounds {
  static let logger = Logger(subsystem: "MacOSWorkarounds", category: "MacOSWorkarounds")

  static let installMacTouchBarHack: Void = {
    do {
      guard let klass = NSClassFromString("NSTouchBarLayout") else { return }
      _ = try Interpose(klass) { builder in
        try builder.hook(
          "setLeadingWidgetWidth:",
          methodSignature: (@convention(c) (AnyObject, Selector, CGFloat) -> Void).self,
          hookSignature: (@convention(block) (AnyObject, CGFloat) -> Void).self) { store in { innerSelf, width in
            var newWidth = width
            if width < 0 {
              logger.warning("Applying workaround for NSTouchBarLayout crash.")
              newWidth = 0
            }
            store.original(innerSelf, store.selector, newWidth)
          }
        }
      }
    } catch {
      logger.error("Failed to install workaround for touch bar crash: \(String(describing: error)).")
    }
  }()

  /// Check all available windows for `NaN` values on the windows origins
  ///  Fixes *** Assertion failure in +[NSToolbarView newViewForToolbar:inWindow:attachedToEdge:], NSToolbarView.m:282
  static func avoidNaNOrigins(_ windows: [NSWindow]) {
    guard let mainScreen = NSScreen.main else { return }

    windows.forEach { window in
      if window.frame.origin.x.isNaN || window.frame.origin.y.isNaN {
        let startX = window.frame.size == .zero
          ? mainScreen.frame.size.width / 4
          : mainScreen.frame.size.width / 2

        let startY = window.frame.size == .zero
          ? mainScreen.frame.size.height / 4
          : mainScreen.frame.size.height / 2

        let x = startX - window.frame.size.width / 2
        let y = startY - window.frame.size.height / 2
        let origin = CGPoint(x: x, y: y)

        window.setFrameOrigin(origin)

        DispatchQueue.main.async {
          window.center()
        }
      }
    }
  }
}
