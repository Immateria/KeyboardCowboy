import SwiftUI
import ViewKit
import ModelKit

@main
struct KeyboardCowboyApp: App {
  @StateObject private var store = Saloon()
  @Environment(\.scenePhase) var scenePhase

  var body: some Scene {
    WindowGroup {
      store.state.currentView
        .frame(minWidth: 800, minHeight: 520)
        .onChange(of: scenePhase, perform: { phase in
          if phase == .active {
            store.load()
          }
        })
    }
    .windowToolbarStyle(UnifiedWindowToolbarStyle())
    .commands {
      KeyboardCowboyCommands(groupStore: store.groupStore,
                             workflowStore: store.workflowStore,
                             context: store.context!)
    }

    Settings {
      KeyboardCowboySettingsView()
    }
  }
}
