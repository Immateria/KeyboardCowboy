import SwiftUI

struct AppSymbol: View {
  @Environment(\.colorScheme) var colorScheme
  private var invertedColorScheme: ColorScheme {
    colorScheme == .dark ? .light : .dark
  }

  var body: some View {
    ZStack {
      appOutline()
        .background(Color.pink)
        .cornerRadius(8.0)
        .rotationEffect(.degrees(-30))
        .offset(x: -4, y: -1)

      appOutline()
        .background(RegularKeyIcon(letter: "").colorScheme(colorScheme))
        .cornerRadius(8.0)
        .rotationEffect(.degrees(-10))
        .offset(x: -1, y: -1)

      appOutline()
        .background(RegularKeyIcon(letter: "").colorScheme(invertedColorScheme))
        .cornerRadius(8.0)
        .rotationEffect(.degrees(10))
        .offset(x: 4, y: 4)
    }
  }

  @ViewBuilder
  func appOutline() -> some View {
    ZStack {
      RoundedRectangle(cornerRadius: 8)
        .stroke(Color(.textBackgroundColor))

      GeometryReader { proxy in
        // Horizontal lines

        Path { path in
          path.move(to: CGPoint(x: 2, y: 2))
          path.addLine(to: CGPoint(x: proxy.size.width - 2,
                                   y: proxy.size.height - 2))
        }.stroke(Color(.textBackgroundColor).opacity(0.4), lineWidth: 0.25)

        Path { path in
          path.move(to: CGPoint(x: 2, y: proxy.size.width - 2))
          path.addLine(to: CGPoint(x: proxy.size.width - 2,
                                   y: 2))
        }.stroke(Color(.textBackgroundColor).opacity(0.4), lineWidth: 0.25)

        Path { path in
          path.move(to: CGPoint(x: 0, y: proxy.size.height * 0.25))
          path.addLine(to: CGPoint(x: proxy.size.width,
                                   y: proxy.size.height * 0.25))
        }.stroke(Color(.textBackgroundColor).opacity(0.4), lineWidth: 0.25)

        Path { path in
          path.move(to: CGPoint(x: 0, y: proxy.size.height * 0.5))
          path.addLine(to: CGPoint(x: proxy.size.width,
                                   y: proxy.size.height * 0.5))
        }.stroke(Color(.textBackgroundColor).opacity(0.4), lineWidth: 0.25)

        Path { path in
          path.move(to: CGPoint(x: 0, y: proxy.size.height * 0.75))
          path.addLine(to: CGPoint(x: proxy.size.width,
                                   y: proxy.size.height * 0.75))
        }.stroke(Color(.textBackgroundColor).opacity(0.4), lineWidth: 0.25)

        // Vertical lines

        Path { path in
          path.move(to: CGPoint(x: proxy.size.height * 0.25, y: 2))
          path.addLine(to: CGPoint(x: proxy.size.height * 0.25,
                                   y: proxy.size.height))
        }.stroke(Color(.textBackgroundColor).opacity(0.4), lineWidth: 0.25)

        Path { path in
          path.move(to: CGPoint(x: proxy.size.height * 0.5, y: 2))
          path.addLine(to: CGPoint(x: proxy.size.height * 0.5,
                                   y: proxy.size.height))
        }.stroke(Color(.textBackgroundColor).opacity(0.4), lineWidth: 0.25)

        Path { path in
          path.move(to: CGPoint(x: proxy.size.height * 0.75, y: 2))
          path.addLine(to: CGPoint(x: proxy.size.height * 0.75,
                                   y: proxy.size.height))
        }.stroke(Color(.textBackgroundColor).opacity(0.4), lineWidth: 0.25)


      }

      Circle()
        .stroke(Color(.textBackgroundColor), lineWidth: 0.25)
        .frame(width: 30, height: 30)
        .opacity(0.6)

      Circle()
        .stroke(Color(.textBackgroundColor), lineWidth: 0.25)
        .frame(width: 24, height: 24)
        .opacity(0.4)

      Circle()
        .stroke(Color(.textBackgroundColor), lineWidth: 0.25)
        .frame(width: 12, height: 12)
        .opacity(0.4)

    }
  }
}

struct AppSymbol_Previews: PreviewProvider {
  static var previews: some View {
    testPreview.previewAllColorSchemes()
  }

  static var testPreview: some View {
      ZStack {
        AppSymbol()
          .background(Color.red)
          .cornerRadius(8.0)
          .rotationEffect(.degrees(-20))
          .offset(x: -2, y: -2)

        AppSymbol()
          .background(Color.red)
          .cornerRadius(8.0)
          .rotationEffect(.degrees(-10))
          .offset(x: -1, y: -1)

        AppSymbol()
          .background(Color.red)
          .cornerRadius(8.0)
      }
      .padding()
      .frame(width: 64, height: 64)
    }
}
