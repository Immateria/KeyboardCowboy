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

  private(set) var context: ViewKitFeatureContext

  private var coreController: CoreController?
  private var settingsController: SettingsController?
  private var subscriptions = Set<AnyCancellable>()

  @Published var state: ApplicationState = .launching(LaunchView())

  init() {
    let configuration = Configuration.Storage()
    self.storageController = Self.factory.storageController(
      path: configuration.path,
      fileName: configuration.fileName)

    do {
      let groups = try storageController.load()
      let groupsController = Self.factory.groupsController(groups: groups)
      let coreController = Self.factory.coreController(
        disableKeyboardShortcuts: launchArguments.isEnabled(.disableKeyboardShortcuts),
        groupsController: groupsController)

      let context = FeatureFactory(coreController: coreController).featureContext()
      let viewKitContext = context.viewKitContext()

      self.context = viewKitContext
      super.init(groups: groups, context: viewKitContext)

      observeNotifications()
      subscribe(context)

      self.state = .content(MainView(store: self, groupController: viewKitContext.groups))
    } catch let error {
      AppDelegateErrorController.handle(error)
      self.context = ViewKitFeatureContext.preview()
      super.init(groups: [], context: context)
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
    context.groups.subject
      .receive(on: DispatchQueue.main)
      .sink { groups in
        self.groups = groups
      }.store(in: &subscriptions)

    context.groups.subject
      .debounce(for: 0.5, scheduler: RunLoop.main)
      .removeDuplicates()
      .receive(on: DispatchQueue.global(qos: .userInitiated))
      .sink { groups in
        self.saveGroupsToDisk(groups)
      }
      .store(in: &subscriptions)

    UserDefaults.standard.publisher(for: \.groupSelection).sink { newValue in
      guard let newValue = newValue else {
        return
      }
      self.selectedGroup = self.groups.first(where: { $0.id == newValue })
    }.store(in: &subscriptions)

    UserDefaults.standard.publisher(for: \.workflowSelection).sink { newValue in
      guard let newValue = newValue else {
        self.selectedWorkflow = nil
        return
      }
      self.selectedWorkflow = self.groups.flatMap({ $0.workflows }).first(where: { $0.id == newValue })
    }.store(in: &subscriptions)
  }

  private func saveGroupsToDisk(_ groups: [ModelKit.Group]) {
    do {
      try storageController.save(groups)
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
