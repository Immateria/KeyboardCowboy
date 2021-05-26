@testable import LogicFramework
@testable import ModelKit
import Apps
import Foundation
import SnapshotTesting
import XCTest

class OpenCommandTests: XCTestCase {
  func testJSONEncoding() throws {
    assertSnapshot(matching: try ModelFactory().openCommand(
                    id: "foobar", application: Application.empty(id: "foobar"))
                    .toString(), as: .dump)
  }

  func testJSONDecoding() throws {
    let id = UUID().uuidString
    let subject = ModelFactory().openCommand(id: id, application: Application.finder(id: id))
    let json: [String: Any] = [
      "id": subject.id,
      "application": [
        "id": subject.id,
        "bundleName": "Finder",
        "bundleIdentifier": "com.apple.finder",
        "path": "/System/Library/CoreServices/Finder.app"
      ],
      "path": "~/Desktop/new_real_final_draft_Copy_42.psd"
    ]
    XCTAssertEqual(try OpenCommand.decode(from: json), subject)
  }

  func testIsUrl() {
    XCTAssertTrue(OpenCommand(path: "https://www.github.com/").isUrl)
    XCTAssertTrue(OpenCommand(path: "ftp://hostname.com").isUrl)
    XCTAssertFalse(OpenCommand(path: "file://").isUrl)
    XCTAssertFalse(OpenCommand(path: "~/.gitconfig").isUrl)
  }
}
