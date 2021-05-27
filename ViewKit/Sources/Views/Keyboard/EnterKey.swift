import SwiftUI

struct EnterKey: View, KeyView {
  @Environment(\.colorScheme) var colorScheme
  let segments = ShapeParameters().segments

  let width: CGFloat
  let height: CGFloat

  var body: some View {
    ZStack {
      shape(Color.black.opacity( colorScheme == .light ? 0.3 : 0.9 ))
        .transform {
          $0.offset(x: 0, y: 1)
            .blur(radius: 2)
            .scaleEffect(CGSize(width: 0.99, height: 1.0))
        }

      shape(Color.black.opacity( colorScheme == .light ? 0.33 : 0.9 ))
        .transform {
          $0.offset(x: 0, y: height * 0.025)
            .blur(radius: 1.0)
            .scaleEffect(CGSize(width: 0.95, height: 1.0))
        }

      shape(Color(.windowFrameTextColor))
        .transform {
          $0.opacity(0.25)
        }

      shape(Color(.windowBackgroundColor))
        .transform {
          $0.padding(0.1)
        }

      Text("↩")
        .font(Font.system(size: height * 0.1, weight: .regular, design: .rounded))
        .padding()
        .frame(width: width, height: height, alignment: .trailing)
        .offset(x: width * 0.025, y: -height * 0.125)

    }.frame(width: width, height: height)
  }

  func shape(_ color: Color) -> some View {
    Rectangle()
      .fill(color)
      .mask(
      GeometryReader { proxy in
        let width = proxy.size.width
        let height = proxy.size.height
        Path { path in
          segments.enumerated().forEach { offset, segment in
            if offset == 0 {
              path.move(to: CGPoint(x: width * segment.line.x, y: height * segment.line.y))
            } else {
              path.addLine(to: CGPoint(x: width * segment.line.x, y: height * segment.line.y))
            }

            path.addQuadCurve(to: CGPoint(x: width * segment.curve.x, y: height * segment.curve.y),
                              control: CGPoint(x: width * segment.control.x, y: height * segment.control.y
                              ))
          }
        }
      }
    )
  }

  let gradientStart = Color(red: 239.0 / 255, green: 120.0 / 255, blue: 221.0 / 255)
  let gradientEnd = Color(red: 239.0 / 255, green: 172.0 / 255, blue: 120.0 / 255)
}

struct EnterKey_Previews: PreviewProvider, TestPreviewProvider {
  static var previews: some View {
    testPreview.previewAllColorSchemes()
  }

  static var testPreview: some View {
    EnterKey(width: 64, height: 128)
  }
}

struct ShapeParameters {
  struct Segment {
    let line: CGPoint
    let curve: CGPoint
    let control: CGPoint
  }

  static let cornerRadius: CGFloat = 0.05
  let segments = [
    Segment(
      line: CGPoint(x: 0.1, y: 0.1 + cornerRadius),
      curve: CGPoint(x: 0.1 + cornerRadius, y: 0.1),
      control: CGPoint(x: 0.1, y: 0.1)
    ),
    Segment(
      line: CGPoint(x: 0.9 - cornerRadius, y: 0.1),
      curve: CGPoint(x: 0.9, y: 0.1 + cornerRadius),
      control: CGPoint(x: 0.9, y: 0.1)
    ),
    Segment(
      line: CGPoint(x: 0.9 , y: 0.9 - cornerRadius),
      curve: CGPoint(x: 0.9 - cornerRadius, y: 0.9),
      control: CGPoint(x: 0.9, y: 0.9)
    ),
    Segment(
      line: CGPoint(x: 0.3 + cornerRadius, y: 0.9),
      curve: CGPoint(x: 0.3, y: 0.9 - cornerRadius),
      control: CGPoint(x: 0.3, y: 0.9)
    ),
    Segment(
      line: CGPoint(x: 0.3,
                    y: 0.45 + cornerRadius),
      curve: CGPoint(x: 0.3 - cornerRadius,
                     y: 0.45),
      control: CGPoint(x: 0.3,
                       y: 0.45)
    ),
    Segment(
      line: CGPoint(x: 0.1 + cornerRadius, y: 0.45),
      curve: CGPoint(x: 0.1, y: 0.45 - cornerRadius),
      control: CGPoint(x: 0.1, y: 0.45)
    ),
  ]
}
