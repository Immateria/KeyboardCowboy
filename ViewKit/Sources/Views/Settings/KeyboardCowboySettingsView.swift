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
    .background(
      KeyboardView(width: 650 * 2)
        .rotation3DEffect(.degrees(50), axis: (x: 1, y: 0, z: 0))
        .rotationEffect(.degrees(-15))
        .offset(x: 0, y: 175)
        .mask(gradient)
        .opacity(1.0)
    )
  }

  var gradient: some View {
    LinearGradient(
      gradient: Gradient(
        stops: [
          .init(color: Color.black.opacity(0.1), location: 0.8),
          .init(color: Color.black.opacity(0.5), location: 1.0),
        ]),
      startPoint: .top,
      endPoint: .bottom)
  }
}

struct KeyboardCowboySettingsView_Previews: PreviewProvider {
  static var previews: some View {
    testPreview.previewAllColorSchemes()
  }

  static var testPreview: some View {
    KeyboardCowboySettingsView(context: ViewKitFeatureContext.preview())
  }
}
