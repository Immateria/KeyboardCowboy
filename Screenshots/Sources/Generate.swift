import Cocoa
import SwiftUI
@testable import Keyboard_Cowboy
import XCTest

class Generator {
  static func execute<Content: View>(_ rootView: Content,
                                     name: String,
                                     size: CGSize) -> XCTestExpectation {
    let viewController = NSHostingController(rootView: rootView)
    viewController.view.frame.size = size
    let window = FloatingWindow(contentRect: .init(origin: .zero, size: size))
    let windowController = NSWindowController(window: window)
    viewController.view.frame = CGRect(origin: .zero, size: size)
    windowController.contentViewController = viewController
    window.minSize = size
    windowController.showWindow(nil)

    let expectation = XCTestExpectation(description: "Wait for expectation")
    DispatchQueue.main.async {
      guard let cgImage = CGWindowListCreateImage(.zero, [.optionIncludingWindow],
                                                  CGWindowID(window.windowNumber), [.boundsIgnoreFraming]) else {
        XCTFail("Unable to create image")
        return
      }

      guard let data = NSBitmapImageRep(cgImage: cgImage).representation(using: .png, properties: [:]) else {
        XCTFail("No data")
        return
      }

      guard var path = ProcessInfo.processInfo.environment["SOURCE_ROOT"] else {
        XCTFail("Couldn't resolve SOURCE_ROOT")
        return
      }

      path.append("/Generated")
      path.append("/\(name).png")

      try? data.write(to: URL(fileURLWithPath: path))
      expectation.fulfill()
    }

    return expectation
  }
}
