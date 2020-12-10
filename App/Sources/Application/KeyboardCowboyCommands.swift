import SwiftUI
import ModelKit
import ViewKit

struct KeyboardCowboyCommands: Commands {
  @ObservedObject var groupStore: GroupStore
  @ObservedObject var workflowStore: WorkflowStore
  let context: FeatureContext

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
      if let group = groupStore.group {
        Button("New Workflow") {
          context.workflowFeature.perform(.createWorkflow(in: group))
        }.keyboardShortcut("n", modifiers: [.command])
      }

      if let workflow = workflowStore.workflow {
        Button("New Keyboard shortcut") {

          context.keyboardFeature.perform(.createKeyboardShortcut(
                                            ModelKit.KeyboardShortcut.empty(),
                                            index: 999,
                                            in: workflow))
        }.keyboardShortcut("k", modifiers: [.command])
      }

      if let workflow = workflowStore.workflow {
        Button("New Command") {
          context.commandFeature.perform(.createCommand(Command.application(.empty()), in: workflow))
        }.keyboardShortcut("n", modifiers: [.control, .option, .command])
      }

      Button("New Group") {
        context.groupsFeature.perform(.createGroup)
      }.keyboardShortcut("N", modifiers: [.command, .shift])
    })

    CommandGroup(after: CommandGroupPlacement.toolbar, addition: {
      Button("Toggle Sidebar") {
        firstResponder?.tryToPerform(
          #selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
      }.keyboardShortcut("S")
    })
  }
}
