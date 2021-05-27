import SwiftUI

struct KeyboardView: View {

  let row2 = [
    "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "Å", "^"
  ].compactMap({ Letter(string: $0) })

  let row3 = [
    "A", "S", "D", "F", "G", "H", "J", "K", "L", "Ö", "Ä"
  ].compactMap({ Letter(string: $0) })

  let row4 = [
    ">", "Z", "X", "C", "V", "B", "N", "M", ",", ".", "-"
  ].compactMap({ Letter(string: $0) })

  @ViewBuilder
  func row1_1(_ size: CGFloat) -> some View {
    RegularKeyIcon(letters: ["§", "'"], width: size, height: size).frame(width: size, height: size)
    RegularKeyIcon(letters: ["!", "1"], width: size, height: size).frame(width: size, height: size)
    RegularKeyIcon(letters: ["\"", "2"], width: size, height: size).frame(width: size, height: size)
    RegularKeyIcon(letters: ["#", "3"], width: size, height: size).frame(width: size, height: size)
    RegularKeyIcon(letters: ["$", "4"], width: size, height: size).frame(width: size, height: size)
    RegularKeyIcon(letters: ["%", "5"], width: size, height: size).frame(width: size, height: size)
    RegularKeyIcon(letters: ["&", "6"], width: size, height: size).frame(width: size, height: size)
    RegularKeyIcon(letters: ["/", "7"], width: size, height: size).frame(width: size, height: size)
    RegularKeyIcon(letters: ["\\(", "8"], width: size, height: size).frame(width: size, height: size)
    RegularKeyIcon(letters: [")", "9"], width: size, height: size).frame(width: size, height: size)
  }

  @ViewBuilder
  func row1_2(_ size: CGFloat) -> some View {
    RegularKeyIcon(letters: ["=", "0"], width: size, height: size)
      .frame(width: size, height: size)
    RegularKeyIcon(letters: ["?", "+"], width: size, height: size)
      .frame(width: size, height: size)
    RegularKeyIcon(letters: ["`", "´"], width: size, height: size)
      .frame(width: size, height: size)
  }

  let width: CGFloat

  var body: some View {
      ZStack(alignment: .trailing) {
        VStack(alignment: .leading, spacing: relative(8)) {
          HStack(spacing: relative(8)) {
            row1_1(relative(48))
            row1_2(relative(48))
            RegularKeyIcon(letters: ["", "⌫"],
                           width: relative(56),
                           height: relative(48),
                           alignment: .bottomTrailing)
              .frame(width: relative(74), height: relative(48))
          }

          HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
              HStack(spacing: relative(8)) {
                RegularKeyIcon(letters: [" ", "⇥"],
                               width: relative(60),
                               height: relative(48),
                               alignment: .bottomLeading)
                  .frame(width: relative(72), height: relative(48))
                ForEach(row2) { letter in
                  RegularKeyIcon(letter: letter.string,
                                 width: relative(48),
                                 height: relative(48))
                    .frame(width: relative(48), height: relative(48))
                }
              }

              Spacer().frame(height: relative(8))

              HStack(spacing: relative(8)) {
                RegularKeyIcon(letters: ["", "⇪"],
                               width: relative(72),
                               height: relative(48),
                               alignment: .bottomLeading)
                  .frame(width: relative(84), height: relative(48))
                ForEach(row3) { letter in
                  RegularKeyIcon(letter: letter.string,
                                 width: relative(48),
                                 height: relative(48))
                    .frame(width: relative(48), height: relative(48))
                }
                RegularKeyIcon(letters: ["*", "@"],
                               width: relative(48), height: relative(48))
                  .frame(width: relative(48), height: relative(48))
              }
            }
            EnterKey(width: relative(48),
                     height: relative(48) + relative(48) + relative(8))
              .offset(CGSize(width: relative(-2),
                             height: relative(1)))
          }

          HStack(spacing: relative(8)) {
            ModifierKeyIcon(key: .shift)
              .frame(width: relative(68), height: relative(48))

            ForEach(row4) { letter in
              RegularKeyIcon(letter: letter.string,
                             width: relative(48), height: relative(48))
                .frame(width: relative(48), height: relative(48))
            }

            ModifierKeyIcon(key: .shift, alignment: .bottomTrailing)
              .frame(width: relative(48) + relative(48) + relative(16),
                     height: relative(48))
          }

          HStack(spacing: relative(8)) {
            ModifierKeyIcon(key: .function)
              .frame(width: relative(48), height: relative(48))
            ModifierKeyIcon(key: .control)
              .frame(width: relative(48), height: relative(48))
            ModifierKeyIcon(key: .option)
              .frame(width: relative(48), height: relative(48))
            ModifierKeyIcon(key: .command)
              .frame(width: relative(64), height: relative(48))

            RegularKeyIcon(letter: "",
                           height: relative(48))
              .frame(width: width * 0.33, height: relative(48))

            ModifierKeyIcon(key: .command, alignment: .topLeading)
              .frame(width: relative(64), height: relative(48))
            ModifierKeyIcon(key: .option, alignment: .topLeading)
              .frame(width: relative(48), height: relative(48))

            VStack(spacing: 0) {
              Spacer().frame(width: relative(48),
                             height: relative(24))
              RegularKeyIcon(letter: "◀︎",
                             width: relative(48),
                             height: relative(24))
                .frame(width: relative(48), height: relative(24))
            }.frame(width: relative(48), height: relative(64))

            VStack(spacing: 0) {
              RegularKeyIcon(letter: "▲",
                             width: relative(48),
                             height: relative(24))
                .frame(width: relative(48), height: relative(24))
              RegularKeyIcon(letter: "▼",
                             width: relative(48),
                             height: relative(24))
                .frame(width: relative(48), height: relative(24))
            }

            VStack(spacing: 0) {
              Spacer().frame(height: relative(24))
              RegularKeyIcon(letter: "►",
                             width: relative(48),
                             height: relative(24))
                .frame(width: relative(48), height: relative(24))
            }.frame(width: relative(48), height: relative(64))
          }
        }
      }
      .padding(relative(16))
  }

  func relative(_ number: CGFloat) -> CGFloat {
    let standard: CGFloat = 800
    return ceil(number * ((width - number) / (standard - number)))
  }
}

struct KeyboardView_Previews: PreviewProvider, TestPreviewProvider {
  static var previews: some View {
    testPreview.previewAllColorSchemes()
  }

  static var testPreview: some View {
    Group {
      KeyboardView(width: 320).previewDisplayName("320")
      KeyboardView(width: 640).previewDisplayName("640")
      KeyboardView(width: 800).previewDisplayName("800")
      KeyboardView(width: 1024).previewDisplayName("1024")
    }
  }
}
