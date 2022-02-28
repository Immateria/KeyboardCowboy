import SwiftUI

@main
struct KeyboardCowboy: App {
  @Environment(\.scenePhase) private var scenePhase
  @StateObject var store: Saloon

  init() {
    _store = .init(wrappedValue: Saloon())
  }

  var body: some Scene {
    WindowGroup {
      ContentView(store: store)
    }.onChange(of: scenePhase) { phase in
      guard case .active = phase else { return }
      store.applicationStore.reload()
    }
  }
}
