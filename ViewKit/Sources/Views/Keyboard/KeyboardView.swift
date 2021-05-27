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
  var row1_1: some View {
    RegularKeyIcon(letters: ["§", "'"]).frame(width: 48, height: 48)
    RegularKeyIcon(letters: ["!", "1"]).frame(width: 48, height: 48)
    RegularKeyIcon(letters: ["\"", "2"]).frame(width: 48, height: 48)
    RegularKeyIcon(letters: ["#", "3"]).frame(width: 48, height: 48)
    RegularKeyIcon(letters: ["$", "4"]).frame(width: 48, height: 48)
    RegularKeyIcon(letters: ["%", "5"]).frame(width: 48, height: 48)
    RegularKeyIcon(letters: ["&", "6"]).frame(width: 48, height: 48)
    RegularKeyIcon(letters: ["/", "7"]).frame(width: 48, height: 48)
    RegularKeyIcon(letters: ["\\(", "8"]).frame(width: 48, height: 48)
    RegularKeyIcon(letters: [")", "9"]).frame(width: 48, height: 48)
  }

  @ViewBuilder
  var row1_2: some View {
    RegularKeyIcon(letters: ["=", "0"]).frame(width: 48, height: 48)
    RegularKeyIcon(letters: ["?", "+"]).frame(width: 48, height: 48)
    RegularKeyIcon(letters: ["`", "´"]).frame(width: 48, height: 48)
  }


  var body: some View {
    ZStack(alignment: .trailing) {
      VStack(alignment: .leading) {
        HStack {
          row1_1
          row1_2
          RegularKeyIcon(letters: ["", "⌫"],
                         width: 56,
                         alignment: .bottomTrailing)
            .frame(width: 74, height: 48)
        }

        HStack {
          RegularKeyIcon(letters: [" ", "⇥"], width: 60,
                         alignment: .bottomLeading)
            .frame(width: 72, height: 48)
          ForEach(row2) { letter in
            RegularKeyIcon(letter: letter.string)
              .frame(width: 48, height: 48)
          }
        }

        HStack {
          RegularKeyIcon(letters: ["", "⇪"], width: 72,
                         alignment: .bottomLeading)
            .frame(width: 84, height: 48)
          ForEach(row3) { letter in
            RegularKeyIcon(letter: letter.string)
              .frame(width: 48, height: 48)
          }
          RegularKeyIcon(letters: ["*", "@"])
            .frame(width: 48, height: 48)
        }

        HStack {
          ModifierKeyIcon(key: .shift)
            .frame(width: 68, height: 48)

          ForEach(row4) { letter in
            RegularKeyIcon(letter: letter.string)
              .frame(width: 48, height: 48)
          }

          ModifierKeyIcon(key: .shift, alignment: .bottomTrailing)
            .frame(width: 110, height: 48)
        }

        HStack {
          ModifierKeyIcon(key: .function)
            .frame(width: 48, height: 48)
          ModifierKeyIcon(key: .control)
            .frame(width: 48, height: 48)
          ModifierKeyIcon(key: .option)
            .frame(width: 48, height: 48)
          ModifierKeyIcon(key: .command)
            .frame(width: 64, height: 48)

          RegularKeyIcon(letter: "")
            .frame(width: 265, height: 48)

          ModifierKeyIcon(key: .command, alignment: .topLeading)
            .frame(width: 64, height: 48)
          ModifierKeyIcon(key: .option, alignment: .topLeading)
            .frame(width: 48, height: 48)

          VStack {
            Spacer().frame(height: 24)
            RegularKeyIcon(letter: "◀︎", height: 24)
              .frame(width: 48, height: 24)
          }.frame(width: 48, height: 64)

          VStack(spacing: 0) {
            RegularKeyIcon(letter: "▲", height: 24)
              .frame(width: 48, height: 24)
            RegularKeyIcon(letter: "▼", height: 24)
              .frame(width: 48, height: 24)
          }.frame(width: 48, height: 64)

          VStack {
            Spacer().frame(height: 24)
            RegularKeyIcon(letter: "►", height: 24)
              .frame(width: 48, height: 24)
          }.frame(width: 48, height: 64)
        }
      }
      EnterKey(width: 48, height: 104)
        .offset(CGSize(width: 0, height: -31.0))
    }
    .padding()
  }
}

struct KeyboardView_Previews: PreviewProvider, TestPreviewProvider {

  static var previews: some View {
    testPreview.previewAllColorSchemes()
  }

  static var testPreview: some View {
    KeyboardView()
  }
}
