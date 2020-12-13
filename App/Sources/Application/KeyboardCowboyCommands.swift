import SwiftUI
import ModelKit
import ViewKit

struct KeyboardCowboyCommands: Commands {
  let store: Saloon

  private var firstResponder: NSResponder? { NSApp.keyWindow?.firstResponder }

  var body: some Commands {
    CommandGroup(replacing: CommandGroupPlacement.pasteboard, addition: {
      Button("Copy") {
        firstResponder?.tryToPerform(#selector(NSText.copy(_:)), with: nil)
      }.keyboardShortcut("c", modifiers: [.command])

      Button("Paste") {
        firstResponder?.tryToPerform(#selector(NSText.paste(_:)), with: nil)
      }.keyboardShortcut("v", modifiers: [.command])

      Button("Delete") {
        firstResponder?.tryToPerform(#selector(NSText.delete(_:)), with: nil)
      }.keyboardShortcut(.delete, modifiers: [])

      Button("Select All") {
        firstResponder?.tryToPerform(#selector(NSText.selectAll(_:)), with: nil)
      }.keyboardShortcut("a", modifiers: [.command])
    })

    CommandGroup(replacing: CommandGroupPlacement.newItem, addition: {
      if let group = store.selectedGroup {
        Button("New Workflow") {
          store.context.workflow.perform(.create(groupId: group.id))
        }.keyboardShortcut("n", modifiers: [.command])
      }

      if store.selectedWorkflow != nil {
        Button("New Keyboard shortcut") {
          store.context.keyboardsShortcuts.perform(
            .create(ModelKit.KeyboardShortcut.empty(), offset: 999, in: store.context.workflow.state))
        }.keyboardShortcut("k", modifiers: [.command])

        Button("New Command") {
          store.context.commands.perform(.create(Command.application(.empty()), in: store.context.workflow.state))
        }.keyboardShortcut("n", modifiers: [.control, .option, .command])
      }
      Button("New Group") {
        store.context.groups.perform(.createGroup)
      }.keyboardShortcut("N", modifiers: [.command])
    })

    CommandGroup(after: CommandGroupPlacement.toolbar, addition: {
      Button("Toggle Sidebar") {
        firstResponder?.tryToPerform(
          #selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
      }.keyboardShortcut("S")
    })
  }
}
