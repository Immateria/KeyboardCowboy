import Apps
import BridgeKit
import Combine
import Foundation
import LogicFramework
import ModelKit
import ViewKit
import SwiftUI
import Sparkle

/*
 This type alias exists soley to restore some order to all the chaos.
 The joke was simply too funny not to pass on, I apologize to future-self
 or any other poor soul that will get confused because of this reckless
 creative naming. Just know that at the time,
 it made me fill up with the giggles.

 Loads of love, zenangst <3
 */
typealias KeyboardCowboyStore = Saloon

let isRunningPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
let isRunningTests = NSClassFromString("XCTest") != nil
let bundleIdentifier = Bundle.main.bundleIdentifier!

class Saloon: ViewKitStore, MenubarControllerDelegate {
  @Environment(\.scenePhase) private var scenePhase
  private static let factory = ControllerFactory.shared

  private let builtInController: BuiltInCommandController
  private let storageController: StorageControlling
  private let hudFeatureController = HUDFeatureController()
  private let pathFinderController = PathFinderController()

  private var applicationTrigger: ApplicationTriggerControlling?
  private var coreController: CoreControlling?
  private var featureContext: FeatureContext?
  private var keyboardShortcutWindowController: NSWindowController?
  private var loaded: Bool = false
  private var menuBarController: MenubarController?
  private var quickRunFeatureController: QuickRunFeatureController?
  private var quickRunWindowController: NSWindowController?
  private var settingsController: SettingsController?
  private var subscriptions = Set<AnyCancellable>()
  private var state: ApplicationState = .initial
  private var wizardStore = WizardStore()

  private weak var mainWindow: NSWindow?

  @Published var view: ApplicationView = .hidden

  init() {
    MacOSWorkarounds.installMacTouchBarHack
    Debug.isEnabled = launchArguments.isEnabled(.debug)
    let configuration = Configuration.Storage()
    self.storageController = Self.factory.storageController(
      path: configuration.path,
      fileName: configuration.fileName)
    self.builtInController = BuiltInCommandController()

    do {
      super.init(context: .preview())

      if isRunningTests || isRunningPreview { return }

      let installedApplications = ApplicationController.loadApplications()
      IconController.shared.applications = installedApplications

      if !wizardStore.hasFinishedWizard {
        wizardStore.$finishedWizard
          .dropFirst()
          .sink { value in
            if value {
              do {
                if let groups = self.wizardStore.postConfiguration(installedApplications) {
                  try self.storageController.save(groups)
                }
                try self.configure(installedApplications)
                self.set(.launched)
              } catch let error {
                self.handle(error)
              }
            }
          }.store(in: &subscriptions)

        self.view = .wizard(WizardView(openPanel: OpenPanelViewController().erase(), store: wizardStore))
      } else {
        try self.configure(installedApplications)
      }
    } catch let error {
      self.handle(error)
    }
  }

  // MARK: Public methods

  func scenePhaseChanged(_ phase: ScenePhase) {
    if case .active = phase, state != .launched {
      set(.launched)
    }
  }

  // MARK: Private methods

  private func configure(_ installedApplications: [Application]) throws {
    self.subscriptions = []
    var groups = try storageController.load()
    pathFinderController.patch(&groups, applications: installedApplications)
    let groupsController = Self.factory.groupsController(groups: groups)
    let hotKeyController = try Self.factory.hotkeyController()

    let coreController = Self.factory.coreController(
      launchArguments.isEnabled(.disableKeyboardShortcuts) ? .disabled : .enabled,
      bundleIdentifier: bundleIdentifier,
      builtInCommandController: builtInController,
      groupsController: groupsController,
      hotKeyController: hotKeyController,
      installedApplications: installedApplications
    )

    self.applicationTrigger = Self.factory.applicationTriggerController()

    self.coreController = coreController

    let context = FeatureFactory(coreController: coreController).featureContext(
      keyInputSubjectWrapper: Self.keyInputSubject)
    let viewKitContext = context.viewKitContext(keyInputSubjectWrapper: Self.keyInputSubject)

    self.context = viewKitContext
    self.featureContext = context
    self.groups = groups
    self.quickRunFeatureController = QuickRunFeatureController(commandController: coreController.commandController)
    self.subscribe(to: NSApplication.shared)
    self.subscribe(to: NSWorkspace.shared)
    self.subscribe(to: context)
  }

  private func handle(_ error: Error) {
    let permissionController = Self.factory.permissionsController()
    if !permissionController.hasPrivileges() {
      let applicationName = ProcessInfo.processInfo.processName
      let text = """
  \(applicationName) requires access to accessibility.

  To enable this, click on \"Open System Preferences\" on the dialog that just appeared.

  When the setting is enabled, restart \(applicationName) and you should be ready to go.

  If you have already granted permission, try and disable and enable the current
  entry inside the list of applications under "Allow the apps below to control your computer."
  """
      view = .needsPermission(PermissionsView(text: text))
    } else {
      ErrorController.handle(error)
    }
  }

  private func set(_ newState: ApplicationState) {
    switch newState {
    case .initial:
      break
    case .launching:
      state = .launching
    case .launched:
      settingsController = SettingsController(userDefaults: .standard)
      subscribe(to: UserDefaults.standard, context: context)
      subscribe(to: NotificationCenter.default)
      SUUpdater.shared()?.checkForUpdatesInBackground()
      createKeyboardShortcutWindow()
      createQuickRun()
      state = .launched

      MacOSWorkarounds.avoidNaNOrigins(NSApplication.shared.windows)
      NotificationCenter.default
        .publisher(for: .init(ApplicationCommandNotification.keyboardCowboyWasActivate.rawValue))
        .sink { _ in
          self.openMainWindow()
        }
        .store(in: &subscriptions)
    }
  }

  private func createQuickRun() {
    guard let quickRunFeatureController = quickRunFeatureController else { return }

    let window = QuickRunWindow(contentRect: .init(origin: .zero, size: CGSize(width: 300, height: 500)))
    window.minSize.height = 530
    let windowController = QuickRunWindowController(window: window,
                                                    featureController: quickRunFeatureController)
    self.quickRunWindowController = windowController
    self.quickRunFeatureController?.window = window
    builtInController.windowController = windowController
  }

  private func createKeyboardShortcutWindow() {
    let size = CGSize(width: 600, height: 200)
    let window = FloatingWindow(contentRect: .init(origin: .zero, size: size))
    let windowController = NSWindowController(window: window)
    var hudStack = HUDStack(hudProvider: hudFeatureController.erase())
    hudStack.window = window
    windowController.contentViewController = NSHostingController(rootView: hudStack.frame(width: size.width))
    windowController.window = window
    window.minSize = size

    coreController?.publisher.sink(receiveValue: { newValue in
      self.hudFeatureController.state = newValue
      windowController.showWindow(nil)
    }).store(in: &subscriptions)

    window.setFrameOrigin(.zero)

    self.keyboardShortcutWindowController = windowController
  }

  private func subscribe(to application: NSApplication) {
    application.publisher(for: \.isRunning)
      .filter { $0 == true }
      .sink { [weak self] _ in
        self?.set(.launching)
        if UserDefaults.standard.openWindowOnLaunch ||
            launchArguments.isEnabled(.openWindowAtLaunch) {
          self?.openMainWindow()
        } else {
          NSApp.setActivationPolicy(UserDefaults.standard.hideDockIcon ? .accessory : .regular)
        }
      }.store(in: &subscriptions)

    application.publisher(for: \.mainWindow)
      .compactMap { $0 }
      .sink { [weak self] in
        self?.mainWindow = $0
        MacOSWorkarounds.avoidNaNOrigins([$0])
      }.store(in: &subscriptions)

    application.publisher(for: \.keyWindow)
      .compactMap { $0 }
      .sink {
        MacOSWorkarounds.avoidNaNOrigins([$0])
      }.store(in: &subscriptions)
  }

  private func subscribe(to workspace: NSWorkspace) {
    workspace
      .publisher(for: \.frontmostApplication)
      .filter { $0?.bundleIdentifier != bundleIdentifier }
      .sink { _ in
        if !launchArguments.isEnabled(.openWindowAtLaunch) {
          if UserDefaults.standard.hideDockIcon && self.mainWindow == nil {
            NSApp.setActivationPolicy(.accessory)
          }
        }
      }.store(in: &subscriptions)
  }

  private func subscribe(to context: FeatureContext) {
    context.groups.subject
      .removeDuplicates()
      .receive(on: DispatchQueue.main)
      .sink { groups in
        self.groups = groups
        self.quickRunFeatureController?.storage = self.groups
          .flatMap({ $0.workflows })
          .filter({ $0.isEnabled })

        if let selectedGroup = self.selectedGroup,
           let group =  groups.first(where: { $0.id == selectedGroup.id }) {
          self.context.workflows.perform(.set(group: group))
        }
      }.store(in: &subscriptions)

    context.groups.subject
      .dropFirst()
      .debounce(for: 1.0, scheduler: RunLoop.current)
      .removeDuplicates()
      .receive(on: DispatchQueue.global(qos: .userInitiated))
      .sink { groups in
        self.applicationTrigger?.receive(groups)
        self.saveGroupsToDisk(groups)
      }
      .store(in: &subscriptions)
  }

  private func subscribe(to userDefaults: UserDefaults,
                         context: ViewKitFeatureContext) {
    userDefaults.publisher(for: \.groupSelection)
      .compactMap({ $0 })
      .sink { newValue in
      if let newGroup = self.groups.first(where: { $0.id == newValue }) {
        self.selectedGroup = newGroup
        context.workflows.perform(.set(group: newGroup))
      }
    }.store(in: &subscriptions)

    userDefaults.publisher(for: \.workflowSelection).sink { newValue in
      guard let newValue = newValue else {
        self.selectedWorkflow = nil
        return
      }
      let selectedWorkflow = self.groups.flatMap({ $0.workflows }).first(where: { $0.id == newValue })
      if let selectedWorkflow = selectedWorkflow {
        context.workflow.perform(.set(workflow: selectedWorkflow))
      }
      self.selectedWorkflow = selectedWorkflow
    }.store(in: &subscriptions)

    userDefaults.publisher(for: \.hideMenuBarIcon).sink { newValue in
      if newValue {
        self.menuBarController = nil
        return
      }
      self.menuBarController = MenubarController()
      self.menuBarController?.delegate = self
    }.store(in: &subscriptions)
  }

  private func subscribe(to notificationCenter: NotificationCenter) {
    notificationCenter.publisher(for: HotKeyNotification.enableHotKeys.notification).sink { _ in
      if !launchArguments.isEnabled(.disableKeyboardShortcuts) {
        self.coreController?.setState(.enabled)
      }
    }.store(in: &subscriptions)

    notificationCenter.publisher(for: HotKeyNotification.enableRecordingHotKeys.notification).sink { _ in
      self.coreController?.setState(.recording)
    }.store(in: &subscriptions)

    notificationCenter.publisher(for: HotKeyNotification.disableHotKeys.notification).sink { _ in
      if !launchArguments.isEnabled(.disableKeyboardShortcuts) {
        self.coreController?.setState(.disabled)
      }
    }.store(in: &subscriptions)
  }

  private func saveGroupsToDisk(_ groups: [ModelKit.Group]) {
    do {
      try storageController.save(groups)
    } catch let error {
      ErrorController.handle(error)
      NSApp.setActivationPolicy(.regular)
      NSApp.activate(ignoringOtherApps: true)
    }
  }

  private func createContentView() {
    guard !isRunningPreview else { return }
    view = .content(MainView(store: self, groupController: context.groups))
  }

  func openMainWindow() {
    let quickRunIsOpen = quickRunWindowController?.window?.isVisible == true
    if !quickRunIsOpen {
      createContentView()
      NSWorkspace.shared.open(Bundle.main.bundleURL)
      mainWindow?.orderFrontRegardless()
    }
  }

  // MARK: MenubarControllerDelegate
  func menubarController(_ controller: MenubarController, didTapOpenApplication openApplicationMenuItem: NSMenuItem) {
    quickRunWindowController?.close()
    openMainWindow()
  }
}
