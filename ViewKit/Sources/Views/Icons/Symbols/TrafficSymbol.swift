import SwiftUI

struct TrafficSymbol: View {
    var body: some View {
      ZStack {
        GeometryReader { proxy in
          RegularKeyIcon(letter: "", height: proxy.size.height * 0.6)
            .colorScheme(.dark)
            .frame(width: proxy.size.width, height: proxy.size.height)
        }

        HStack(spacing: 4) {
          Circle()
            .fill(Color.red)
            .background(Circle().stroke(Color(.shadowColor)))
          Circle()
            .fill(Color.yellow)
            .background(Circle().stroke(Color(.shadowColor)))
          Circle()
            .fill(Color.green)
            .background(Circle().stroke(Color(.shadowColor)))
        }.padding(.horizontal, 3)
      }
    }
}

struct TrafficSymbol_Previews: PreviewProvider {
  static var previews: some View {
    testPreview.previewAllColorSchemes()
  }

  static var testPreview: some View {
        TrafficSymbol()
    }
}
