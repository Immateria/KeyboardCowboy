import SwiftUI

public struct KeyboardCowboySettingsView: View {
  private enum Tabs: Hashable {
    case general, keyboard
  }

  private let context: ViewKitFeatureContext

  public init(context: ViewKitFeatureContext) {
    self.context = context
  }

  public var body: some View {
    TabView {
      GeneralSettings(openPanelController: context.openPanel)
        .tag(Tabs.general)
      KeyboardSettings()
        .tag(Tabs.general)
    }
    .frame(width: 650, alignment: .topLeading)
  }
}

struct KeyboardCowboySettingsView_Previews: PreviewProvider {
  static var previews: some View {
    KeyboardCowboySettingsView(context: ViewKitFeatureContext.preview())
  }
}
