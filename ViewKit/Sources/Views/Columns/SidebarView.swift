import SwiftUI

struct SidebarView: View {
  let factory: ViewFactory
  @ObservedObject var store: ViewKitStore

  var body: some View {
    factory.groupList(store: store)
      .toolbar(content: { SidebarToolbar() })
      .frame(minWidth: 225)
  }
}
