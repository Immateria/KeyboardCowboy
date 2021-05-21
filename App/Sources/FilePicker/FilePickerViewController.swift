import ViewKit
import LogicFramework
import Combine
import Cocoa

final class OpenPanelViewController: NSObject, ViewController, NSOpenSavePanelDelegate {

  @Published var state: String = ""
  var fileExtension: String?

  func perform(_ action: OpenPanelAction) {
    let panel = NSOpenPanel()
    panel.delegate = self
    panel.resolvesAliases = true
    let responseHandler: (String) -> Void

    switch action {
    case .selectFile(let fileType, let handler):
      fileExtension = fileType
      panel.allowsOtherFileTypes = fileType != nil
      responseHandler = handler
      panel.canChooseFiles = true
      panel.canChooseDirectories = true
    case .selectFolder(let handler):
      panel.canChooseFiles = false
      panel.canChooseDirectories = true
      responseHandler = handler
    }

    let response = panel.runModal()

    guard response == .OK,
          let path = panel.url?.path else { return }

    responseHandler(path)
  }

  // MARK: NSOpenSavePanelDelegate

  func panel(_ sender: Any, shouldEnable url: URL) -> Bool {
    guard let fileExtension = fileExtension else { return true }

    let pathExtension = (url.path as NSString).pathExtension

    return pathExtension.isEmpty || pathExtension == fileExtension
  }
}
