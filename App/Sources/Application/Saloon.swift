import Combine
import Foundation
import LogicFramework
import ModelKit
import ViewKit
import SwiftUI

/*
 This type alias exists soley to restore some order to all the chaos.
 The joke was simply too funny not to pass on, I apologize to future-self
 or any other poor soul that will get confused because of this reckless
 creative naming. Just know that at the time,
 it made me fill up with the giggles.

 Loads of love, zenangst <3
 */
typealias KeyboardCowboyStore = Saloon

class Saloon: ViewKitStore {
  enum ApplicationState {
    case launching(LaunchView)
    case needsPermission(PermissionsView)
    case content(MainView)

    var currentView: AnyView {
      switch self {
      case .launching(let view):
        return view.erase()
      case .needsPermission(let view):
        return view.erase()
      case .content(let view):
        return view.erase()
      }
    }
  }

  private static let factory = ControllerFactory()

  private let storageController: StorageControlling

  private(set) var context: FeatureContext?
  private(set) var groupStore: GroupStore
  private(set) var workflowStore: WorkflowStore

  private var coreController: CoreController?
  private var settingsController: SettingsController?
  private var subscriptions = Set<AnyCancellable>()

  @Published var state: ApplicationState = .launching(LaunchView())

  init() {
    let groupStore = GroupStore(group: nil)
    let workflowStore = WorkflowStore(workflow: nil)
    let configuration = Configuration.Storage()

    self.groupStore = groupStore
    self.workflowStore = workflowStore
    self.storageController = Self.factory.storageController(
      path: configuration.path,
      fileName: configuration.fileName)

    super.init(groups: [])

    do {
      let groups = try storageController.load()
      let groupsController = Self.factory.groupsController(groups: groups)
      let coreController = Self.factory.coreController(
        disableKeyboardShortcuts: launchArguments.isEnabled(.disableKeyboardShortcuts),
        groupsController: groupsController)
      let context = FeatureFactory(coreController: coreController)
        .featureContext(groupStore: groupStore,
                        workflowStore: workflowStore)

      groupStore.group = groups.first
      workflowStore.workflow = groups.first?.workflows.first

      observeNotifications()
      subscribe(context)
      state = .content(context.factory.mainView(store: self))
      self.context = context
      self.groups = groups
    } catch let error {
      AppDelegateErrorController.handle(error)
    }
  }

  func load() {
    self.settingsController = SettingsController(userDefaults: .standard)
  }

  private func observeNotifications() {
    NotificationCenter.default.addObserver(self, selector: #selector(enableHotKeys),
                                           name: AppDelegate.enableNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(disableHotKeys),
                                           name: AppDelegate.disableNotification, object: nil)
  }

  private func subscribe(_ context: FeatureContext) {
    context.groupsFeature.subject
      .debounce(for: 0.5, scheduler: RunLoop.main)
      .throttle(for: 2.0, scheduler: RunLoop.main, latest: true)
      .removeDuplicates()
      .receive(on: DispatchQueue.global(qos: .userInitiated))
      .sink { groups in
        self.saveGroupsToDisk(groups)
        DispatchQueue.main.async {
          self.groups = groups
        }
      }
      .store(in: &subscriptions)
  }

  private func saveGroupsToDisk(_ groups: [ModelKit.Group]) {
    do {
      try storageController.save(groups)
      DispatchQueue.main.async {
        self.groups = groups
      }
    } catch let error {
      AppDelegateErrorController.handle(error)
    }
  }

  // MARK: Notifications

  @objc private func enableHotKeys() {
    if !launchArguments.isEnabled(.disableKeyboardShortcuts) {
      coreController?.disableKeyboardShortcuts = false
    }
  }

  @objc private func disableHotKeys() {
    if !launchArguments.isEnabled(.disableKeyboardShortcuts) {
      coreController?.disableKeyboardShortcuts = true
    }
  }
}
