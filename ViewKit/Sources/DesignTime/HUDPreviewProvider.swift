import ModelKit

final class HUDPreviewProvider: StateController {
  var state: [KeyboardShortcut] = [
    KeyboardShortcut(key: "A", modifiers: [.function, .shift]),
    KeyboardShortcut(key: "T", modifiers: [.shift]),
    KeyboardShortcut(key: "Open Terminal", modifiers: [])
  ]
}
