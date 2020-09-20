import Carbon
import Cocoa

public protocol RebindingControlling {
  init() throws
  func monitor(_ workflows: [Workflow])
  func callback(_ type: CGEventType, _ cgEvent: CGEvent) -> Unmanaged<CGEvent>?
}

enum RebindingControllingError: Error {
  case unableToCreateMachPort
  case unableToCreateRunLoopSource
}

final class RebindingController: RebindingControlling {
  static var workflows = [Workflow]()
  private static var cache = [String: Int]()
  private var machPort: CFMachPort!
  private var runLoopSource: CFRunLoopSource!

  required init() throws {
    self.machPort = try createMachPort()
    self.runLoopSource = try createRunLoopSource()
    Self.cache = KeyCodeMapper().hashTable()
    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
  }

  func monitor(_ workflows: [Workflow]) {
    Self.workflows = workflows
  }

  private func createMachPort() throws -> CFMachPort? {
    let tap: CGEventTapLocation = .cgSessionEventTap
    let place: CGEventTapPlacement = .headInsertEventTap
    let options: CGEventTapOptions = .defaultTap
    let mask: CGEventMask = 1 << CGEventType.keyDown.rawValue
      | 1 << CGEventType.keyUp.rawValue
    let userInfo: UnsafeMutableRawPointer = Unmanaged.passUnretained(self).toOpaque()
    guard let machPort = CGEvent.tapCreate(
            tap: tap,
            place: place,
            options: options,
            eventsOfInterest: mask,
            callback: eventTapCallback,
            userInfo: userInfo) else {
      throw RebindingControllingError.unableToCreateMachPort
    }
    return machPort
  }

  private func createRunLoopSource() throws -> CFRunLoopSource {
    guard let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, machPort, 0) else {
      throw RebindingControllingError.unableToCreateRunLoopSource
    }
    return runLoopSource
  }

  func callback(_ type: CGEventType, _ event: CGEvent) -> Unmanaged<CGEvent>? {
    let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
    let workflows = Self.workflows
    var result: Unmanaged<CGEvent>? = Unmanaged.passRetained(event)

    for workflow in workflows {
      guard let keyboardShortcut = workflow.keyboardShortcuts.last,
            let shortcutKeyCode = Self.cache[keyboardShortcut.key.uppercased()] else { continue }

      guard keyCode == shortcutKeyCode else { continue }

      var modifiersMatch: Bool = true

      if let modifiers = keyboardShortcut.modifiers {
        modifiersMatch = eventFlagsMatchModifiers(event.flags, modifiers: modifiers)
      } else {
        modifiersMatch = event.flags.isDisjoint(with: [
          .maskControl, .maskCommand, .maskAlternate, .maskShift
        ])
      }

      guard modifiersMatch else { continue }

      for case .keyboard(let shortcut) in workflow.commands {
        guard let shortcutKeyCode = Self.cache[shortcut.keyboardShortcut.key.uppercased()] else {
          continue
        }
        if let cgKeyCode = CGKeyCode(exactly: shortcutKeyCode),
           let source = CGEventSource(stateID: .privateState),
           let newEvent = CGEvent(keyboardEventSource: source,
                                  virtualKey: cgKeyCode,
                                  keyDown: type == .keyDown) {
          newEvent.post(tap: .cghidEventTap)
        }
        result = nil
      }
    }

    return result
  }

  private func eventFlagsMatchModifiers(_ flags: CGEventFlags, modifiers: [ModifierKey]) -> Bool {
    var collectedModifiers = Set<ModifierKey>()

    if flags.contains(.maskShift) { collectedModifiers.insert(.shift) }

    if flags.contains(.maskControl) { collectedModifiers.insert(.control) }

    if flags.contains(.maskAlternate) { collectedModifiers.insert(.option) }

    if flags.contains(.maskCommand) { collectedModifiers.insert(.command) }

    if flags.contains(.maskSecondaryFn) { collectedModifiers.insert(.function) }

    let modifierSet = Set<ModifierKey>(modifiers)
    return collectedModifiers == modifierSet
  }
}

private func eventTapCallback(_ proxy: CGEventTapProxy, _ type: CGEventType, _ event: CGEvent,
                              _ userInfo: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
  guard let handler = userInfo?.assumingMemoryBound(to: RebindingController.self) else {
    return Unmanaged.passUnretained(event)
  }
  return handler.pointee.callback(type, event)
}
