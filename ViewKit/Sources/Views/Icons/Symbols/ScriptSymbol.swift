import SwiftUI

struct ScriptSymbol: View {
  func headPath(_ size: CGSize) -> some View {
    Path { path in
      path.move(to: .init(x: size.width * 0.5,
                          y: size.height * 0.15))

      path.addQuadCurve(to: .init(x: size.width * 0.6,
                                  y: size.height * 0.15),
                        control: .init(x: size.width * 0.6,
                                       y: size.height * 0.155))

      path.addQuadCurve(to: .init(x: size.width,
                                  y: 0),
                        control: .init(x: size.width * 0.85,
                                       y: size.height * 0.05))

      path.addQuadCurve(to: .init(x: size.width * 0.95,
                                  y: size.height * 0.4),
                        control: .init(x: size.width,
                                       y: size.height * 0.1))

      path.addQuadCurve(to: .init(x: size.width * 0.98,
                                  y: size.height * 0.7),
                        control: .init(x: size.width,
                                       y: size.height * 0.6))

      path.addQuadCurve(to: .init(x: size.width * 0.98,
                                  y: size.height * 0.7),
                        control: .init(x: size.width,
                                       y: size.height * 0.6))

      path.addQuadCurve(to: .init(x: size.width * 0.5,
                                  y: size.height),
                        control: .init(x: size.width * 0.75,
                                       y: size.height))

    }.stroke(Color.white)
  }

  @ViewBuilder
  func eyePath(_ size: CGSize) -> some View {
    Path { path in
      path.move(to: .init(x: size.width * 0.2,
                          y: size.height * 0.38))

      path.addQuadCurve(to: .init(x: size.width * 0.4,
                                  y: size.height * 0.5),
                        control: .init(x: size.width * 0.4,
                                       y: size.height * 0.3))

      path.addQuadCurve(to: .init(x: size.width * 0.2,
                                  y: size.height * 0.38),
                        control: .init(x: size.width * 0.2,
                                       y: size.height * 0.55))
    }.stroke(Color.white)
  }

  @ViewBuilder
  func nosePath(_ size: CGSize) -> some View {
    Path { path in
      path.move(to: .init(x: size.width * 0.5,
                          y: size.width * 0.69))

      path.addQuadCurve(to: .init(x: size.width * 0.5,
                                  y: size.height * 0.6),
                        control: .init(x: size.width * 0.4,
                                       y: size.height * 0.6))
    }.stroke(Color.white)
  }

  @ViewBuilder
  func mouthPath(_ size: CGSize) -> some View {
    Path { path in
      path.move(to: .init(x: size.width * 0.5,
                          y: size.height * 0.69))

      path.addQuadCurve(to: .init(x: size.width * 0.3,
                                  y: size.height * 0.8),
                        control: .init(x: size.width * 0.5,
                                       y: size.height * 0.9))
    }.stroke(Color.white)
  }

  @ViewBuilder
  func wiskersPath(_ size: CGSize) -> some View {
    ZStack {
      Path { path in
        path.move(to: .init(x: size.width * 0.44,
                            y: size.height * 0.7))

        path.addQuadCurve(to: .init(x: size.width * 0.02,
                                    y: size.height * 0.8),
                          control: .init(x: size.width * 0.3,
                                         y: size.height * 0.66))
      }.stroke(Color.white)

      Path { path in
        path.move(to: .init(x: size.width * 0.42,
                            y: size.height * 0.72))

        path.addQuadCurve(to: .init(x: size.width * 0.03,
                                    y: size.height * 0.85),
                          control: .init(x: size.width * 0.3,
                                         y: size.height * 0.66))
      }.stroke(Color.white)

      Path { path in
        path.move(to: .init(x: size.width * 0.4,
                            y: size.height * 0.72))

        path.addQuadCurve(to: .init(x: size.width * 0.04,
                                    y: size.height * 0.9),
                          control: .init(x: size.width * 0.3,
                                         y: size.height * 0.66))
      }.stroke(Color.white)
    }
  }

  var body: some View {
    ZStack {
      GeometryReader { proxy in
        ZStack {
          headPath(proxy.size)
          headPath(proxy.size).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))

          eyePath(proxy.size)
          eyePath(proxy.size).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))

          nosePath(proxy.size)
          nosePath(proxy.size).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))

          wiskersPath(proxy.size)
          wiskersPath(proxy.size).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))

          mouthPath(proxy.size)
          mouthPath(proxy.size).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
        }
      }
    }
  }
}

struct ScriptSymbol_Previews: PreviewProvider {
  static var previews: some View {
    testPreview.previewAllColorSchemes()
  }

  static var testPreview: some View {
    ScriptSymbol()
  }
}
