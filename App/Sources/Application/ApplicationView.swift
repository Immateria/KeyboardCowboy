import SwiftUI
import ViewKit

enum ApplicationView: View {
  case hidden
  case needsPermission(PermissionsView)
  case content(MainView)
  case wizard(WizardView)

  var body: some View {
    switch self {
    case .hidden:
      ZStack { }.frame(minWidth: 1, minHeight: 1)
    case .content(let view):
      view.frame(minWidth: 900, minHeight: 520)
    case .needsPermission(let view):
      view.frame(minWidth: 600, minHeight: 320)
    case .wizard(let view):
      view
    }
  }
}
