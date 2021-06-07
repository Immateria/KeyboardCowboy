import SwiftUI

struct FeatureIcon<Content: View>: View {
  let content: () -> Content
  let color: Color
  let size: CGSize

  init(color: Color,
       size: CGSize = .init(width: 50, height: 50),
       @ViewBuilder _ content: @escaping () -> Content) {
    self.color = color
    self.content = content
    self.size = size
  }

  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 8)
        .fill(color)
      content()
        .frame(width: size.width / 1.5, height: size.height / 1.5)
    }
    .frame(width: size.width, height: size.width)
    .padding()
  }
}

struct FeatureIcon_Previews: PreviewProvider {
  static var previews: some View {
    testPreview.previewAllColorSchemes()
  }

  static let previewSize: CGSize = .init(width: 50, height: 50)

  static var testPreview: some View {
    HStack {
      FeatureIcon(color: .red, size: previewSize,
                  { AppSymbol() })
      FeatureIcon(color: .orange, size: previewSize,
                  { TrafficSymbol() })
      FeatureIcon(color: .yellow, size: previewSize,
                  { ScriptIcon(cornerRadius: 3) })
      FeatureIcon(color: .green, size: previewSize,
                  { CommandKeyIcon() })
      FeatureIcon(color: .blue, size: previewSize,
                  { FolderIcon() })
      FeatureIcon(color: .purple, size: previewSize,
                  { URLIcon() })
      FeatureIcon(color: .gray, size: previewSize, { Text("Groups") })
    }
  }
}
