import Foundation
import LogicFramework
import ModelKit
import ViewKit
import SwiftUI

class FeatureContext {
  let applicationProvider: ApplicationsProvider
  let commandFeature: CommandsFeatureController
  let factory: ViewFactory
  let groupsFeature: GroupsFeatureController
  let keyboardFeature: KeyboardShortcutsFeatureController
  let searchFeature: SearchFeatureController
  let workflowFeature: WorkflowFeatureController

  init(applicationProvider: ApplicationsProvider,
       commandFeature: CommandsFeatureController,
       factory: ViewFactory,
       groupsFeature: GroupsFeatureController,
       keyboardFeature: KeyboardShortcutsFeatureController,
       searchFeature: SearchFeatureController,
       workflowFeature: WorkflowFeatureController) {
    self.applicationProvider = applicationProvider
    self.commandFeature = commandFeature
    self.factory = factory
    self.groupsFeature = groupsFeature
    self.keyboardFeature = keyboardFeature
    self.searchFeature = searchFeature
    self.workflowFeature = workflowFeature
  }
}

final class FeatureFactory {
  private let coreController: CoreControlling
  private var groupsController: GroupsControlling {
    coreController.groupsController
  }
  private var installedApplications: [Application] {
    coreController.installedApplications
  }

  init(coreController: CoreControlling) {
    self.coreController = coreController
  }

  static func menuBar() -> MenubarController {
    MenubarController()
  }

  func featureContext(groupStore: GroupStore, workflowStore: WorkflowStore) -> FeatureContext {
    let applicationProvider = ApplicationsProvider(applications: coreController.installedApplications)
    let commandsController = commandsFeature(commandController: coreController.commandController)
    let groupFeatureController = groupFeature(groupStore: groupStore, workflowStore: workflowStore)
    let keyboardController = keyboardShortcutFeature()
    let searchController = searchFeature()
    let workflowController = workflowFeature()

    workflowController.delegate = groupFeatureController
    keyboardController.delegate = workflowController
    commandsController.delegate = workflowController

    let factory = AppViewFactory(applicationProvider: applicationProvider.erase(),
                                 commandController: commandsController.erase(),
                                 groupController: groupFeatureController.erase(),
                                 keyboardShortcutController: keyboardController.erase(),
                                 openPanelController: OpenPanelViewController().erase(),
                                 searchController: searchController.erase(),
                                 workflowController: workflowController.erase(),
                                 groupStore: groupStore,
                                 workflowStore: workflowStore)

    return FeatureContext(applicationProvider: applicationProvider,
            commandFeature: commandsController,
            factory: factory,
            groupsFeature: groupFeatureController,
            keyboardFeature: keyboardController,
            searchFeature: searchController,
            workflowFeature: workflowController)
  }

  func groupFeature(groupStore: GroupStore, workflowStore: WorkflowStore) -> GroupsFeatureController {
    GroupsFeatureController(
      groupsController: groupsController,
      applications: installedApplications
    )
  }

  func workflowFeature() -> WorkflowFeatureController {
    WorkflowFeatureController(
      state: Workflow(
        id: "", name: "",
        keyboardShortcuts: [], commands: []),
      applications: installedApplications,
      groupsController: groupsController)
  }

  func keyboardShortcutFeature() -> KeyboardShortcutsFeatureController {
    KeyboardShortcutsFeatureController(groupsController: groupsController)
  }

  func commandsFeature(commandController: CommandControlling) -> CommandsFeatureController {
    CommandsFeatureController(
      commandController: commandController,
      groupsController: groupsController,
      installedApplications: installedApplications)
  }

  func searchFeature() -> SearchFeatureController {
    let root = SearchRootController(groupsController: groupsController,
                                    groupSearch: SearchGroupsController())
    let feature = SearchFeatureController(searchController: root,
                                          groupController: groupsController,
                                          query: .constant(""))
    return feature
  }
}
