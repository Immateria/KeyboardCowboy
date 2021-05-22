import SwiftUI

struct MenubarIcon: View {
  let color: Color
  let size: CGSize
  let offset: CGPoint

  init(color: Color, size: CGSize) {
    self.color = color
    self.size = size
    self.offset = size.height == 11
      ? CGPoint(x: 0.25, y: 0.25)
      : CGPoint(x: 0.3, y: 0)
  }

  var body: some View {
    ZStack {
      ZStack {
      RoundedRectangle(cornerRadius: size.height * 0.2)
        .stroke(color.opacity(0.75), lineWidth: 1)
        .scaleEffect(0.9)
      Text("⌘")
        .foregroundColor(color.opacity(0.75))
        .multilineTextAlignment(.center)
        .font(Font.system(size: size.height * 0.5,
                          weight: .light, design: .rounded))
        .offset(x: offset.x,
                y: offset.y)
      }.padding(1)
    }
    .frame(width: size.width, height: size.height, alignment: .center)
  }
}

struct MenubarIcon_Previews: PreviewProvider, TestPreviewProvider {
  static var previews: some View {
    testPreview.previewAllColorSchemes()
  }

  static var testPreview: some View {
    Group {
      HStack {
        MenubarIcon(color: Color.accentColor, size: CGSize(width: 11, height: 11))
        MenubarIcon(color: Color.accentColor, size: CGSize(width: 22, height: 22))
      }

      HStack {
        MenubarIcon(color: Color(.textColor), size: CGSize(width: 11, height: 11))
        MenubarIcon(color: Color(.textColor), size: CGSize(width: 22, height: 22))
      }
    }
  }
}
