import SwiftUI
import ModelKit

protocol KeyView {
  var colorScheme: ColorScheme { get }
}

extension KeyView {
  @ViewBuilder
  func keyBackgroundView(_ height: CGFloat) -> some View {
    ZStack {
      Rectangle()
        .fill(Color.black.opacity( colorScheme == .light ? 0.3 : 0.9 ))
        .cornerRadius(height * 0.1)
        .offset(x: 0, y: 1)
        .blur(radius: 2)
        .scaleEffect(CGSize(width: 0.99, height: 1.0))

      Rectangle()
        .fill(Color.black.opacity( colorScheme == .light ? 0.33 : 0.9 ))
        .cornerRadius(height * 0.1)
        .offset(x: 0, y: height * 0.025)
        .blur(radius: 1.0)
        .scaleEffect(CGSize(width: 0.95, height: 1.0))

      Rectangle()
        .fill(Color(.windowFrameTextColor))
        .cornerRadius(height * 0.1)
        .opacity(0.25)
      Rectangle()
        .fill(Color(.windowBackgroundColor))
        .cornerRadius(height * 0.1)
        .padding(0.1)
    }
  }
}

public struct RegularKeyIcon: View, KeyView {
  @Environment(\.colorScheme) var colorScheme
  var letter: String
  var height: CGFloat
  private let animation = Animation
    .easeInOut(duration: 1.5)
    .repeatForever(autoreverses: true)
  @State var glow: Bool

  public init(letter: String, height: CGFloat = 32, glow: Bool = false) {
    self.letter = letter.uppercased()
    self.height = height
    self._glow = .init(initialValue: glow)
  }

  public var body: some View {
    ZStack {
      keyBackgroundView(height)
        .foregroundColor(Color(.textColor).opacity(0.66))
      letter(height: height)
        .frame(minWidth: height, minHeight: height)
        .fixedSize(horizontal: true, vertical: true)
    }
    .onAppear {
      if glow {
        withAnimation(animation, { glow.toggle() })
      }
    }
  }

  func letter(height: CGFloat) -> some View {
    Text(letter)
      .font(Font.system(size: height * 0.3, weight: .regular, design: .rounded))
      .foregroundColor(.clear)
      .overlay(
        Rectangle()
          .foregroundColor(glow
                            ? Color.accentColor .opacity(0.5)
                            : Color(.textColor).opacity(0.66))
          .mask(
            Text(letter)
              .font(Font.system(size: height * 0.3, weight: .regular, design: .rounded))
          )
      )
      .shadow(color:
                Color(.controlAccentColor).opacity(glow ? 1.0 : 0.0),
              radius: 1,
              y: glow ? 0 : 2
      )
      .padding(.horizontal, height * 0.2)
  }
}

struct RegularKeyIcon_Previews: PreviewProvider, TestPreviewProvider {
  static var previews: some View {
    testPreview.previewAllColorSchemes()
  }

  static var testPreview: some View {
    HStack {
      RegularKeyIcon(letter: "h", height: 80).frame(width: 80, height: 80)
      RegularKeyIcon(letter: "e", height: 80).frame(width: 80, height: 80)
      RegularKeyIcon(letter: "l", height: 80).frame(width: 80, height: 80)
      RegularKeyIcon(letter: "l", height: 80).frame(width: 80, height: 80)
      RegularKeyIcon(letter: "o", height: 80, glow: true).frame(width: 80, height: 80)
    }
    .padding(3)
  }
}
