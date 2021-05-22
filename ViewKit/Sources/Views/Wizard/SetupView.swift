import SwiftUI

struct SetupView: View {
  enum Configuration: String, Identifiable {
    var id: String { rawValue }
    case examples
    case empty
    case skip
  }

  let action: (Configuration) -> Void

  @State var configuration: Configuration = .examples

  var body: some View {
    VStack(alignment: .leading) {
      Picker("Configuration", selection: $configuration) {
        Text("Example workflows").tag(Configuration.examples)
        Text("Start with a clean slate").tag(Configuration.empty)
        Text("Skip").tag(Configuration.skip)
      }.pickerStyle(RadioGroupPickerStyle())
    }.padding()

    Button("Done", action: {
      action(configuration)
    })
  }
}
