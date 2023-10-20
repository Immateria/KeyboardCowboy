import Bonzai
import Foundation

final class ContentModelMapper {
  func map(_ workflow: Workflow) -> ContentViewModel {
    workflow.asViewModel(nil)
  }
}

private extension Array where Element == Workflow {
  func asViewModels(_ groupName: String?) -> [ContentViewModel] {
    var viewModels = [ContentViewModel]()
    viewModels.reserveCapacity(self.count)
    for (offset, model) in self.enumerated() {
      viewModels.append(model.asViewModel(offset == 0 ? groupName : nil))
    }
    return viewModels
  }
}

private extension Array where Element == KeyShortcut {
  var binding: String? {
    if count == 1, let firstMatch = first {
      let key: String = firstMatch.key.count == 1
      ? firstMatch.key.uppercaseFirstLetter()
      : firstMatch.key
      return "\(firstMatch.modifersDisplayValue)\(key)"
    } else if count > 1 {
      return compactMap {
        let key: String = $0.key.count == 1 ? $0.key.uppercaseFirstLetter() : $0.key
        return $0.modifersDisplayValue + key
      }.joined(separator: ",")
    }
    return nil
  }
}

private extension String {
    func uppercaseFirstLetter() -> String {
        guard let firstCharacter = self.first else {
            return self
        }
        let uppercaseFirstCharacter = String(firstCharacter).uppercased()
        let remainingString = String(self.dropFirst())
        return uppercaseFirstCharacter + remainingString
    }
}

private extension Workflow {
  func asViewModel(_ groupName: String?) -> ContentViewModel {
    let commandCount = commands.count
    let binding: String?
    if let trigger, let triggerBinding = trigger.binding {
      binding = triggerBinding
    } else {
      binding = nil
    }

    return ContentViewModel(
      id: id,
      groupName: groupName,
      name: name,
      images: commands.images(limit: 3),
      overlayImages: commands.overlayImages(limit: 3),
      binding: binding,
      badge: commandCount > 1 ? commandCount : 0,
      badgeOpacity: commandCount > 1 ? 1.0 : 0.0,
      isEnabled: isEnabled)
  }
}

private extension Workflow.Trigger {
  var binding: String? {
    switch self {
    case .keyboardShortcuts(let trigger):
      return trigger.shortcuts.binding
    case .application:
      return nil
    }
  }
}

private extension Array where Element == Command {
  func overlayImages(limit: Int) -> [ContentViewModel.ImageModel] {
    var images = [ContentViewModel.ImageModel]()

    for (offset, element) in self.enumerated() where element.isEnabled {
      if offset == limit { break }
      let convertedOffset = Double(offset)

      switch element {
      case .open(let command):
        if let application = command.application {
          images.append(ContentViewModel.ImageModel(
            id: command.id,
            offset: convertedOffset,
            kind: .icon(.init(bundleIdentifier: application.bundleIdentifier,
                              path: application.path))))
        }
      default:
        continue
      }
    }

    return images
  }

  func images(limit: Int) -> [ContentViewModel.ImageModel] {
    var images = [ContentViewModel.ImageModel]()
    for (offset, element) in self.reversed().enumerated() where element.isEnabled {
      // Don't render icons for commands that are not enabled.
      if !element.isEnabled { continue }

      if offset == limit { break }

      let convertedOffset = Double(offset)
      switch element {
      case .application(let command):
        images.append(
          ContentViewModel.ImageModel(
            id: command.id,
            offset: convertedOffset,
            kind: .icon(.init(bundleIdentifier: command.application.bundleIdentifier,
                              path: command.application.path)))
        )
      case .menuBar(let command):
        let path = "/System/Library/PreferencePanes/Appearance.prefPane"
        images.append(
          ContentViewModel.ImageModel(
            id: command.id,
            offset: convertedOffset,
            kind: .icon(.init(bundleIdentifier: path, path: path)))
        )
      case .builtIn:
        continue
      case .keyboard(let keyCommand):
        if let keyboardShortcut = keyCommand.keyboardShortcuts.first {
          images.append(.init(id: keyboardShortcut.id, offset: convertedOffset,
                              kind: .command(.keyboard(.init(id: keyCommand.id, keys: [keyboardShortcut])))))
        }
      case .open(let command):
        let path: String
        if command.isUrl {
          path = "/System/Library/SyncServices/Schemas/Bookmarks.syncschema/Contents/Resources/com.apple.Bookmarks.icns"
        } else {
          path = command.path
        }

        images.append(
          ContentViewModel.ImageModel(
            id: command.id,
            offset: convertedOffset,
            kind: .icon(.init(bundleIdentifier: path, path: path)))
        )
      case .script(let script):
        switch script.source {
        case .inline(let source):
          images.append(.init(id: script.id,
                              offset: convertedOffset,
                              kind: .command(.script(.init(id: script.id, source: .inline(source), scriptExtension: script.kind)))))
        case .path(let source):
          images.append(.init(id: script.id,
                              offset: convertedOffset,
                              kind: .command(.script(.init(id: script.id, source: .path(source), scriptExtension: script.kind)))))
        }

      case .shortcut(let shortcut):
        images.append(.init(id: shortcut.id,
                            offset: convertedOffset,
                            kind: .command( .shortcut(.init(id: shortcut.id, shortcutIdentifier: shortcut.shortcutIdentifier)))))
      case .type(let type):
        images.append(
          .init(id: type.id,
                offset: convertedOffset,
                kind: .command(.type(.init(id: type.id, mode: type.mode, input: type.input)))
               )
        )
      case .systemCommand(let command):
        let path: String
        switch command.kind {
        case .applicationWindows:
          path = "/System/Applications/Mission Control.app/Contents/Resources/AppIcon.icns"
        case .moveFocusToNextWindowFront:
          path = "/System/Library/CoreServices/WidgetKit Simulator.app/Contents/Resources/AppIcon.icns"
        case .moveFocusToPreviousWindowFront:
          path = "/System/Library/CoreServices/WidgetKit Simulator.app/Contents/Resources/AppIcon.icns"
        case .moveFocusToNextWindow, .moveFocusToNextWindowGlobal:
          path = "/System/Library/CoreServices/WidgetKit Simulator.app/Contents/Resources/AppIcon.icns"
        case .moveFocusToPreviousWindow, .moveFocusToPreviousWindowGlobal:
          path = "/System/Library/CoreServices/WidgetKit Simulator.app/Contents/Resources/AppIcon.icns"
        case .missionControl:
          path = "/System/Applications/Mission Control.app/Contents/Resources/AppIcon.icns"
        case .showDesktop:
          path = "/System/Library/CoreServices/Dock.app/Contents/Resources/Dock.icns"
        }
        images.append(
          ContentViewModel.ImageModel(
            id: command.id,
            offset: convertedOffset,
            kind: .icon(.init(bundleIdentifier: path, path: path)))
        )
      case .windowManagement(let command):
        let path: String = "/System/Applications/Mission Control.app/Contents/Resources/AppIcon.icns"
        images.append(
          ContentViewModel.ImageModel(
            id: command.id,
            offset: convertedOffset,
            kind: .icon(.init(bundleIdentifier: path, path: path)))
        )
      }
    }

    return images.reversed()
  }
}
