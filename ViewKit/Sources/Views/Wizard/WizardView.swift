import SwiftUI

public struct WizardView: View {
  enum CurrentView {
    case welcome
    case general
    case keyboard
    case setup
  }

  @State var state: CurrentView = .setup
  @Environment(\.colorScheme) var colorScheme

  private let openPanel: OpenPanelController
  private let store: WizardStore

  public init(openPanel: OpenPanelController, store: WizardStore) {
    self.openPanel = openPanel
    self.store = store
  }

  public var body: some View {
    VStack {
      switch state {
      case .welcome:
        WelcomeView {
          withAnimation {
            state = .general
          }
        }
        .frame(width: 620, height: 360)
      case .general:
        VStack {
          Text("General")
            .font(.largeTitle)
          GeneralSettings(openPanelController: openPanel)

          Button("Continue", action: {
            state = .keyboard
          }).keyboardShortcut(.defaultAction)
        }
        .frame(width: 620, height: 360)
      case .keyboard:
        VStack {
          Text("Keyboard Settings")
            .font(.largeTitle)
          KeyboardSettings()
          Button("Continue", action: {
            state = .setup
          }).keyboardShortcut(.defaultAction)
        }
        .frame(width: 620, height: 240)
      case .setup:
        VStack {
          Text("Setup")
            .font(.largeTitle)
          SetupView { configuration in
            store.receive(configuration)
          }
        }
        .frame(width: 620, height: 240)
      }
    }
    .background(gradient)
  }

  var gradient: some View {
    let stops: [Gradient.Stop] = colorScheme == .light
    ? [
      .init(color: Color(.windowBackgroundColor).opacity(0.25), location: 0.0),
      .init(color: Color(.windowFrameTextColor).opacity(0.3), location: 1.0),
    ]
    : [
      .init(color: Color(.windowFrameTextColor).opacity(0.2), location: 0.25),
      .init(color: Color(.windowBackgroundColor).opacity(0.25), location: 0.75),
    ]

    return LinearGradient(
      gradient: Gradient(stops: stops),
      startPoint: .top,
      endPoint: .bottom)
  }
}

struct WizardView_Previews: PreviewProvider, TestPreviewProvider {
  static var previews: some View {
    testPreview.previewAllColorSchemes()
  }

  static var testPreview: some View {
    WizardView(openPanel: ViewKitFeatureContext.preview().openPanel, store: WizardStore())
  }
}

struct Letter: Identifiable {
  let id: String = UUID().uuidString
  let string: String
}
