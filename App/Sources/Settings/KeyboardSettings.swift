import SwiftUI
import ViewKit

struct KeyboardSettings: View {
  @AppStorage("keyboardResetDelay") var keyboardResetDelay: TimeInterval = 2

  let formatter: NumberFormatter

  init() {
    self.formatter = NumberFormatter()
    self.formatter.numberStyle = .decimal
  }

  var body: some View {
    Form {
      HStack(alignment: .center) {
        Text("Keyboard Sequence reset:")
        VStack(spacing: -5) {
          Slider(value: $keyboardResetDelay, in: 0.5...5,
                 step: 0.5,
                 minimumValueLabel: Text("0.5"),
                 maximumValueLabel: Text("5"),
                 label: {})
          Text("\(formatter.string(from: NSNumber(value: keyboardResetDelay)) ?? "")")
        }
      }
      .padding([.top, .trailing, .bottom])
      .padding(.leading, 185)
    }.tabItem {
      Label("Keyboard", image: "KeyboardSettings")
    }
  }
}

struct KeyboardSettings_Previews: PreviewProvider {
  static var previews: some View {
    KeyboardSettings()

  }
}
