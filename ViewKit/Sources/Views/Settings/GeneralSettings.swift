import SwiftUI

public struct GeneralSettings: View {
  @AppStorage("configurationPath") var configurationPath = "~"
  @AppStorage("dotFileConfiguration") var dotFileConfiguration = false
  @AppStorage("openWindowOnLaunch") var openWindowOnLaunch = false
  @AppStorage("hideMenuBarIcon") var hideMenubarIcon = false
  @AppStorage("hideDockIcon") var hideDockIcon = false

  @ObservedObject var openPanelController: OpenPanelController

  // swiftlint:disable line_length
  public var body: some View {
    Form {
      VStack {
        VStack(alignment: .leading) {
          HStack {
            TextField("file://", text: $configurationPath)
              .disabled(true)
            Button("Browse", action: {
              openPanelController.perform(.selectFolder(handler: { path in
                Swift.print(path)
              }))
            })
          }
          Toggle("Save configuration as a hidden file", isOn: $dotFileConfiguration)
        }
        .padding([.top, .trailing, .bottom])
        .padding(.leading, 185)

        Divider()

        VStack(alignment: .leading) {
          Toggle("Open window on application launch", isOn: $openWindowOnLaunch)
          Toggle("Hide Keyboard Cowboy in the Dock", isOn: $hideDockIcon)
          Toggle("Hide Keyboard Cowboy in the menu bar", isOn: $hideMenubarIcon)
          Text("""
        If you hide the icon in both the Dock and the menu bar, you can access it by double-clicking its application icon in the Finder.
        """)
            .font(.caption)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding([.top, .trailing, .bottom])
        .padding(.leading, 185)
      }
    }.tabItem {
      Label("General", image: "Menubar_active")
    }
  }
}

struct GeneralSettings_Previews: PreviewProvider {
  static var previews: some View {
    GeneralSettings(openPanelController: OpenPanelPreviewController().erase())
  }
}
