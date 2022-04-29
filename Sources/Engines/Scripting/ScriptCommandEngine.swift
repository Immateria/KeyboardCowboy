import Foundation

final class ScriptCommandEngine {
  private struct Plugins {
    let appleScript = AppleScriptPlugin()
    let shellScript = ShellScriptPlugin()
  }

  private let plugins = Plugins()


  func run(_ command: ScriptCommand) async throws {
    switch command {
    case .appleScript(let id, _, _, let source):
      switch source {
      case .path(let path):
        try plugins.appleScript.executeScript(at: path, withId: id)
      case .inline(let script):
        try plugins.appleScript.execute(script, withId: id)
      }
    case .shell(_, _, _, let source):
      switch source {
      case .path(let path):
        try plugins.shellScript.executeScript(at: path)
      case .inline:
        break
      }
    }
  }
}
