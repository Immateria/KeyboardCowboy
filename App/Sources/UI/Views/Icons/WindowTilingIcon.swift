import SwiftUI

struct WindowTilingIcon: View {
  let kind: WindowTiling
  let size: CGFloat
  var body: some View {
    Rectangle()
      .fill(
        LinearGradient(stops: [
          .init(color: Color(.systemPurple.blended(withFraction: 0.6, of: .white)!), location: 0.3),
          .init(color: Color(.cyan), location: 0.6),
          .init(color: Color.blue, location: 1.0),
        ], startPoint: .topLeading, endPoint: .bottom)
      )
      .overlay {
        LinearGradient(stops: [
          .init(color: Color(.systemPurple.blended(withFraction: 0.3, of: .white)!), location: 0.5),
          .init(color: Color.blue, location: 1.0),
        ], startPoint: .topTrailing, endPoint: .bottomTrailing)
        .opacity(0.6)
      }
      .overlay {
        LinearGradient(stops: [
          .init(color: Color(.systemOrange.blended(withFraction: 0.3, of: .white)!), location: 0.2),
          .init(color: Color.clear, location: 0.8),
        ], startPoint: .topTrailing, endPoint: .bottomLeading)
      }
      .overlay { iconOverlay().opacity(0.65) }
      .overlay { iconBorder(size) }
      .overlay {
        LinearGradient(stops: [
          .init(color: Color(nsColor: .black.blended(withFraction: 0.2, of: .white)!), location: 0.705),
          .init(color: Color(nsColor: .black.blended(withFraction: 0.5, of: .white)!), location: 0.705),
          .init(color: Color(nsColor: .white), location: 0.8),
        ], startPoint: .top, endPoint: .bottom)
        .mask {
          Image(systemName: "laptopcomputer")
            .resizable()
            .scaledToFit()
            .fontWeight(.thin)
        }
        .shadow(color: Color(nsColor: .black.blended(withFraction: 0.4, of: .black)!), radius: 2, y: 1)
        .frame(width: size * 0.98, height: size)
        .offset(x: size * 0.01, y: size * 0.01)
      }
      .overlay {
        WindowTilingKindView(kind: kind, size: size)
          .frame(width: size * 0.65, height: size * 0.4)
          .offset(y: -size * 0.01)
      }
      .frame(width: size, height: size)
      .fixedSize()
      .iconShape(size)
  }
}

private struct WindowTilingKindView: View {
  let kind: WindowTiling
  let size: CGFloat

  var body: some View {
    let spacing: CGFloat = size * 0.035
    switch kind {
    case .left:
      HStack(spacing: 0) {
        Rectangle().fill(Color.white)
          .iconShape(size * 0.15)
        Rectangle().fill(Color.white)
          .iconShape(size * 0.15)
          .opacity(0.0)
      }
      .padding(size * 0.01)
      .opacity(0.7)
    case .right:
      HStack(spacing: 0) {
        Rectangle().fill(Color.white)
          .iconShape(size * 0.15)
          .opacity(0.0)
        Rectangle().fill(Color.white)
          .iconShape(size * 0.15)
      }
      .padding(size * 0.01)
      .opacity(0.7)
    case .top:
      VStack(spacing: 0) {
        Rectangle().fill(Color.white)
          .iconShape(size * 0.15)
        Rectangle().fill(Color.white)
          .iconShape(size * 0.15)
          .opacity(0.0)
      }
      .padding(size * 0.01)
      .opacity(0.7)
    case .bottom:
      VStack(spacing: 0) {
        Rectangle().fill(Color.white)
          .iconShape(size * 0.15)
          .opacity(0.0)
        Rectangle().fill(Color.white)
          .iconShape(size * 0.15)
      }
      .padding(size * 0.01)
      .opacity(0.7)
    case .topLeft:
      VStack(spacing: 0) {
        HStack(spacing: 0) {
          Rectangle().fill(Color.white)
            .iconShape(size * 0.15)
          Rectangle().fill(Color.white)
            .iconShape(size * 0.15)
            .opacity(0)
        }
        HStack(spacing: 0) {
          Rectangle().fill(Color.white)
            .iconShape(size * 0.15)
            .opacity(0)
          Rectangle().fill(Color.white)
            .iconShape(size * 0.15)
            .opacity(0)
        }
      }
      .padding(size * 0.01)
      .opacity(0.7)
    case .topRight:
      VStack(spacing: 0) {
        HStack(spacing: 0) {
          Rectangle().fill(Color.white)
            .iconShape(size * 0.15)
            .opacity(0)
          Rectangle().fill(Color.white)
            .iconShape(size * 0.15)
        }
        HStack(spacing: 0) {
          Rectangle().fill(Color.white)
            .iconShape(size * 0.15)
            .opacity(0)
          Rectangle().fill(Color.white)
            .iconShape(size * 0.15)
            .opacity(0)
        }
      }
      .padding(size * 0.01)
      .opacity(0.7)
    case .bottomLeft:
      VStack(spacing: 0) {
        HStack(spacing: 0) {
          Rectangle().fill(Color.white)
            .iconShape(size * 0.15)
            .opacity(0)
          Rectangle().fill(Color.white)
            .iconShape(size * 0.15)
            .opacity(0)
        }
        HStack(spacing: 0) {
          Rectangle().fill(Color.white)
            .iconShape(size * 0.15)
          Rectangle().fill(Color.white)
            .iconShape(size * 0.15)
            .opacity(0)
        }
      }
      .padding(size * 0.01)
      .opacity(0.7)
    case .bottomRight:
      VStack(spacing: 0) {
        HStack(spacing: 0) {
          Rectangle().fill(Color.white)
            .iconShape(size * 0.15)
            .opacity(0)
          Rectangle().fill(Color.white)
            .iconShape(size * 0.15)
            .opacity(0)
        }
        HStack(spacing: 0) {
          Rectangle().fill(Color.white)
            .iconShape(size * 0.15)
            .opacity(0)
          Rectangle().fill(Color.white)
            .iconShape(size * 0.15)
        }
      }
      .padding(size * 0.01)
      .opacity(0.7)
    case .center:
      Rectangle().fill(Color.white)
        .iconShape(size * 0.15)
        .padding(.horizontal, size * 0.075)
        .padding(.vertical, size * 0.035)
        .opacity(0.7)
    case .fill:
      Rectangle().fill(Color.white)
        .iconShape(size * 0.15)
        .padding(size * 0.01)
        .opacity(0.7)
    case .zoom:
      Rectangle().fill(Color.white)
        .iconShape(size * 0.2)
        .opacity(0.7)
    case .arrangeLeftRight:
      HStack(spacing: spacing) {
        Rectangle().fill(Color.white)
          .iconShape(size * 0.15)
        Rectangle().fill(Color.white)
          .iconShape(size * 0.15)
          .opacity(0.7)
      }
      .padding(size * 0.01)
      .opacity(0.7)
    case .arrangeRightLeft:
      HStack(spacing: spacing) {
        Rectangle().fill(Color.white)
          .iconShape(size * 0.15)
          .opacity(0.7)
        Rectangle().fill(Color.white)
          .iconShape(size * 0.15)
      }
      .padding(size * 0.01)
      .opacity(0.7)
    case .arrangeTopBottom:
      VStack(spacing: spacing) {
        Rectangle().fill(Color.white)
          .iconShape(size * 0.15)
        Rectangle().fill(Color.white)
          .iconShape(size * 0.15)
          .opacity(0.7)
      }
      .padding(size * 0.01)
      .opacity(0.7)
    case .arrangeBottomTop:
      VStack(spacing: spacing) {
        Rectangle().fill(Color.white)
          .iconShape(size * 0.15)
          .opacity(0.7)
        Rectangle().fill(Color.white)
          .iconShape(size * 0.15)
      }
      .padding(size * 0.01)
      .opacity(0.7)
    case .arrangeLeftQuarters:
      HStack(spacing: spacing) {
        Rectangle().fill(Color.white)
          .iconShape(size * 0.15)
        VStack(spacing: spacing) {
          Rectangle().fill(Color.white)
            .iconShape(size * 0.15)
          Rectangle().fill(Color.white)
            .iconShape(size * 0.15)
        }
        .opacity(0.7)
      }
      .padding(size * 0.01)
      .opacity(0.7)
    case .arrangeRightQuarters:
      HStack(spacing: spacing) {
        VStack(spacing: spacing) {
          Rectangle().fill(Color.white)
            .iconShape(size * 0.15)
          Rectangle().fill(Color.white)
            .iconShape(size * 0.15)
        }
        .opacity(0.7)

        Rectangle().fill(Color.white)
          .iconShape(size * 0.15)
      }
      .padding(size * 0.01)
      .opacity(0.7)
    case .arrangeTopQuarters:
      VStack(spacing: spacing) {
        HStack(spacing: spacing) {
          Rectangle().fill(Color.white)
            .iconShape(size * 0.15)
        }
        HStack(spacing: spacing) {
          Rectangle().fill(Color.white)
            .iconShape(size * 0.15)
            .opacity(0.7)
          Rectangle().fill(Color.white)
            .iconShape(size * 0.15)
            .opacity(0.7)
        }
      }
      .padding(size * 0.01)
      .opacity(0.7)
    case .arrangeBottomQuarters:
      VStack(spacing: spacing) {
        HStack(spacing: spacing) {
          Rectangle().fill(Color.white)
            .iconShape(size * 0.15)
            .opacity(0.7)
          Rectangle().fill(Color.white)
            .iconShape(size * 0.15)
            .opacity(0.7)
        }
        HStack(spacing: spacing) {
          Rectangle().fill(Color.white)
            .iconShape(size * 0.15)
        }
      }
      .padding(size * 0.01)
      .opacity(0.7)
    case .arrangeQuarters:
      VStack(spacing: spacing) {
        HStack(spacing: spacing) {
          Rectangle().fill(Color.white)
            .iconShape(size * 0.15)
          Rectangle().fill(Color.white)
            .iconShape(size * 0.15)
        }
        HStack(spacing: spacing) {
          Rectangle().fill(Color.white)
            .iconShape(size * 0.15)
          Rectangle().fill(Color.white)
            .iconShape(size * 0.15)
        }
      }
      .padding(size * 0.01)
      .opacity(0.7)
    case .previousSize:
      Rectangle().fill(Color.white)
        .iconShape(size * 0.15)
        .overlay {
          Color.black.opacity(0.4)
          .mask {
            ZStack {
              Image(systemName: "app")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size * 0.2)
              Image(systemName: "arrowshape.turn.up.backward.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size * 0.1)
                .offset(x: -size * 0.005, y: -size * 0.005)
            }
          }
        }
        .padding(.horizontal, size * 0.075)
        .padding(.vertical, size * 0.035)
        .opacity(0.7)
    }
  }
}

private struct WindowView<Content>: View where Content: View {
  let size: CGSize
  private let content: () -> Content

  init(_ size: CGSize, content: @escaping () -> Content) {
    self.size = size
    self.content = content
  }

  var body: some View {
    Rectangle()
      .fill(
        LinearGradient(stops: [
          .init(color: Color(nsColor: .white), location: 0.0),
          .init(color: Color(nsColor: .white.withSystemEffect(.disabled)), location: 1.0),
        ], startPoint: .topLeading, endPoint: .bottom)
      )
      .overlay { iconOverlay().opacity(0.5) }
      .overlay(alignment: .topLeading) {
        HStack(alignment: .top, spacing: 0) {
          TrafficLightsView(size)
          Rectangle()
            .fill(.white)
            .frame(maxWidth: .infinity)
            .overlay {
              content()
                .foregroundStyle(Color.accentColor)
                .opacity(0.4)
            }
            .overlay { iconOverlay().opacity(0.5) }
        }
      }
      .iconShape(size.width * 0.7)
      .frame(width: size.width, height: size.height)
      .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
  }
}

private struct TrafficLightsView: View {
  let size: CGSize

  init(_ size: CGSize) {
    self.size = size
  }

  var body: some View {
    HStack(alignment: .top, spacing: size.width * 0.0_240) {
      Circle()
        .fill(Color(.systemRed))
        .grayscale(0.5)
      Circle()
        .fill(Color(.systemYellow))
        .shadow(color: Color(.systemYellow), radius: 10)
        .overlay(alignment: .center) {
          Image(systemName: "minus")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .fontWeight(.heavy)
            .foregroundStyle(Color.orange)
            .opacity(0.9)
            .frame(width: size.width * 0.06)
        }
      Circle()
        .fill(Color(.systemGreen))
        .grayscale(0.5)
      Divider()
        .frame(width: 1)
    }
    .frame(width: size.width * 0.3)
    .padding([.leading, .top], size.width * 0.0675)

  }
}

struct PreviewContainer<Content>: View where Content: View {
  let content: (CGFloat) -> Content

  var body: some View {
    HStack(alignment: .top, spacing: 8) {
      content(192)
      VStack(alignment: .leading, spacing: 8) {
        content(128)
        HStack(alignment: .top, spacing: 8) {
          content(64)
          content(32)
          content(16)
        }
      }
    }
    .padding()
  }
}

#Preview("Left") {
  PreviewContainer { WindowTilingIcon(kind: .left, size: $0) }
}

#Preview("Right") {
  PreviewContainer { WindowTilingIcon(kind: .right, size: $0) }
}

#Preview("Top") {
  PreviewContainer { WindowTilingIcon(kind: .top, size: $0) }
}

#Preview("Bottom") {
  PreviewContainer { WindowTilingIcon(kind: .bottom, size: $0) }
}

#Preview("Top Left") {
  PreviewContainer { WindowTilingIcon(kind: .topLeft, size: $0) }
}

#Preview("Top Right") {
  PreviewContainer { WindowTilingIcon(kind: .topRight, size: $0) }
}

#Preview("Bottom Left") {
  PreviewContainer { WindowTilingIcon(kind: .bottomLeft, size: $0) }
}

#Preview("Bottom Right") {
  PreviewContainer { WindowTilingIcon(kind: .bottomRight, size: $0) }
}

#Preview("Left & Right") {
  PreviewContainer { WindowTilingIcon(kind: .arrangeLeftRight, size: $0) }
}

#Preview("Right & Left") {
  PreviewContainer { WindowTilingIcon(kind: .arrangeRightLeft, size: $0) }
}

#Preview("Top & Bottom") {
  PreviewContainer { WindowTilingIcon(kind: .arrangeTopBottom, size: $0) }
}

#Preview("Bottom & Top") {
  PreviewContainer { WindowTilingIcon(kind: .arrangeBottomTop, size: $0) }
}


#Preview("Left & Quarters") {
  PreviewContainer { WindowTilingIcon(kind: .arrangeLeftQuarters, size: $0) }
}

#Preview("Right & Quarters") {
  PreviewContainer { WindowTilingIcon(kind: .arrangeRightQuarters, size: $0) }
}

#Preview("Top & Quarters") {
  PreviewContainer { WindowTilingIcon(kind: .arrangeTopQuarters, size: $0) }
}

#Preview("Bottom & Quarters") {
  PreviewContainer { WindowTilingIcon(kind: .arrangeBottomQuarters, size: $0) }
}

#Preview("Quarters") {
  PreviewContainer { WindowTilingIcon(kind: .arrangeQuarters, size: $0) }
}

#Preview("Center") {
  PreviewContainer { WindowTilingIcon(kind: .center, size: $0) }
}

#Preview("Fill") {
  PreviewContainer { WindowTilingIcon(kind: .fill, size: $0) }
}

#Preview("Zoom") {
  PreviewContainer { WindowTilingIcon(kind: .zoom, size: $0) }
}

#Preview("Previous Size") {
  PreviewContainer { WindowTilingIcon(kind: .previousSize, size: $0) }
}
