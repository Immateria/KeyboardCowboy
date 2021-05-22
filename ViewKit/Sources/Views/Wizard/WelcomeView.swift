import SwiftUI

struct WelcomeView: View {
  @Environment(\.colorScheme) var colorScheme
  private var invertedColorScheme: ColorScheme {
    colorScheme == .dark ? .light : .dark
  }
  private let letters: [Letter] = Array("Welcome")
    .compactMap(String.init)
    .compactMap({ Letter(string: $0) })

  private let action: () -> Void

  public init(action: @escaping () -> Void) {
    self.action = action
  }

  public var body: some View {
    VStack(spacing: 0) {
        VStack {
          Image("ApplicationIcon")
            .resizable()
            .frame(width: 128, height: 128)
          HStack(spacing: 9) {
            ForEach(letters) { letter in
              RegularKeyIcon(letter: letter.string)
                .colorScheme(invertedColorScheme)
                .frame(width: 36, height: 36)
            }
          }
        }
        .padding(.top, 20)
        .padding([.leading, .trailing, .bottom])

      Divider()

      VStack {
        Text("Before we get started, let's go over a few things so that the application\nis configured just the way you want it.")
          .padding()
          .fixedSize(horizontal: false, vertical: true)
        Spacer()
        Button("Get started", action: action)
          .keyboardShortcut(.defaultAction)
      }
      .padding([.leading, .trailing, .bottom], 30)
    }
    .frame(width: 620, height: 360)
  }
}

struct WelcomeView_Previews: PreviewProvider, TestPreviewProvider {
  static var previews: some View {
    testPreview.previewAllColorSchemes()
  }

  static var testPreview: some View {
    WelcomeView {}
  }
}
