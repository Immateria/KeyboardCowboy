import Cocoa
import Carbon
import Combine
import SwiftUI

final class ResponderChain {
  private var responders = [Responder]()
  private var subscription: AnyCancellable?
  private var didBecomeActiveNotification: AnyCancellable?

  static public var shared: ResponderChain = .init()

  @Environment(\.scenePhase) private var scenePhase

  @AppStorage("responderId") var responderId: String = ""

  private init() {
    guard !responderId.isEmpty else { return }

    let initialResponderId = responderId
    didBecomeActiveNotification = NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)
      .sink { [weak self] value in
        guard let self = self else { return }
        self.makeFirstResponder(initialResponderId)
        self.didBecomeActiveNotification = nil
      }
  }

  func resetSelection() {
    responders.forEach { $0.isSelected = false }
  }

  func extendSelection(_ responder: Responder) {
    guard let lhs = responders.firstIndex(where: { $0.id == responderId }),
          let rhs = responders.firstIndex(where: { $0.id == responder.id }) else {
      return
    }

    let slice: ArraySlice<Responder>

    responder.isSelected.toggle()

    guard lhs != rhs else {
      return
    }

    if lhs > rhs {
      slice = responders[rhs...lhs]
    } else {
      slice = responders[lhs...rhs]
    }

    slice.forEach { $0.isSelected = responder.isSelected }
  }

  func selectNamespace(_ namespace: Namespace.ID) {
    let namedSpaceResponders = self.responders.filter({ $0.namespace == namespace })
    let selectedResponders = namedSpaceResponders.filter({ $0.isSelected == true })

    if namedSpaceResponders.count == selectedResponders.count {
      namedSpaceResponders.forEach({ $0.isSelected.toggle() })
    } else {
      namedSpaceResponders.forEach({ $0.isSelected = true })
    }
  }

  func makeFirstResponder<T: Identifiable>(_ identifiable: T) where T.ID == String {
    makeFirstResponder(identifiable.id)
  }

  func makeFirstResponder(_ id: String) {
    guard let responder = responders.first(where: { $0.id == id }) else { return }
    subscription = responder.$makeFirstResponder
      .compactMap { $0 }
      .sink(receiveValue: { [weak self] completion in
        completion(false)
        self?.subscription = nil
        self?.responderId = id
      })
  }

  func setPreviousResponder(_ currentResponder: Responder) {
    guard let view = currentResponder.view else { return }

    let currentNamespaceResponders = responders
      .sorted(by: { $0.view?.frameInWindow().origin.x ?? 0 < $1.view?.frameInWindow().origin.x ?? 0 })
      .sorted(by: { $0.view?.frameInWindow().origin.y ?? 0 < $1.view?.frameInWindow().origin.y ?? 0 })
      .filter({
        $0.namespace == currentResponder.namespace &&
        $0.view != nil
      })
    let responderFrame = view.frameInWindow()

    if let next = currentNamespaceResponders
      .last(where: { responder in
        guard let nextView = responder.view else {
          return false
        }
        let nextResponderFrame = nextView.frameInWindow()

        return nextResponderFrame.origin.y < responderFrame.origin.y ||
        nextResponderFrame.origin.x < responderFrame.origin.x
      }) {
      makeFirstResponder(next.id)
    } else {
      let otherNamespaces = responders
        .compactMap({ $0.namespace })
        .unique()

      if let currentNamespace = currentResponder.namespace,
         let index = otherNamespaces.firstIndex(of: currentNamespace),
         index > 0 {
        guard let responder = responders.last(where: { $0.namespace == otherNamespaces[index - 1] }) else {
          return
        }

        makeFirstResponder(responder.id)
      } else {

      }
    }
  }

  func setNextResponder(_ currentResponder: Responder) {
    guard let view = currentResponder.view else { return }

    let currentNamespaceResponders = responders
      .filter({
        $0.namespace == currentResponder.namespace &&
        $0.view != nil
      })
    let responderFrame = view.frameInWindow()

    if let next = currentNamespaceResponders
      .first(where: { responder in
        guard let nextView = responder.view else {
          return false
        }
        let nextResponderFrame = nextView.frameInWindow()

        return nextResponderFrame.origin.x > responderFrame.origin.x ||
        nextResponderFrame.origin.y > responderFrame.origin.y 

      }) {
      makeFirstResponder(next.id)
    } else {
      let otherNamespaces = responders
        .compactMap({ $0.namespace })
        .unique()

      if let currentNamespace = currentResponder.namespace,
         let index = otherNamespaces.firstIndex(of: currentNamespace),
         index < otherNamespaces.count - 1 {
        guard let responder = responders.first(where: { $0.namespace == otherNamespaces[index + 1] }) else {
          return
        }

        makeFirstResponder(responder.id)
      }
    }
  }

  func clean() {
    responders.removeAll(where: { $0.view == nil })
    sort()
  }

  func sort() {
    responders
      .sort(by: { $0.view?.frameInWindow().origin.x ?? 0 < $1.view?.frameInWindow().origin.x ?? 0 })
    responders
      .sort(by: { $0.view?.frameInWindow().origin.y ?? 0 < $1.view?.frameInWindow().origin.y ?? 0 })
  }

  func remove(_ responder: Responder) {
    responders.removeAll(where: { $0.id == responder.id })
  }

  func add(_ responder: Responder) {
    clean()
    if let firstIndex = responders.firstIndex(where: { $0.id == responder.id }) {
      responders[firstIndex] = responder
    } else {
      responders.append(responder)
    }
  }
}

final class Responder: ObservableObject {
  weak var view: NSView?

  let id: String
  var namespace: Namespace.ID?

  @Published var isFirstReponder: Bool
  @Published var isHovering: Bool
  @Published var isSelected: Bool
  @Published var makeFirstResponder: ((Bool) -> Void)?

  init(_ id: String = UUID().uuidString, namespace: Namespace.ID? = nil) {
    self.id = id
    self.namespace = namespace
    _isFirstReponder = .init(initialValue: false)
    _isHovering = .init(initialValue: false)
    _isSelected = .init(initialValue: false)
  }
}

enum ResponderAction {
  case enter
}

struct ResponderView<Content>: View where Content: View {
  typealias ResponderHandler = (ResponderAction) -> Void
  @StateObject var responder: Responder
  let content: (Responder) -> Content
  let action: ResponderHandler?

  init<T: Identifiable>(_ identifiable: T,
                        namespace: Namespace.ID? = nil,
                        action: ResponderHandler? = nil,
                        content: @escaping (Responder) -> Content) where T.ID == String {
    _responder = .init(wrappedValue: .init(identifiable.id, namespace: namespace))
    self.content = content
    self.action = action
  }

  init(_ id: String = UUID().uuidString,
       namespace: Namespace.ID? = nil,
       action: ResponderHandler? = nil,
       content: @escaping (Responder) -> Content) {
    _responder = .init(wrappedValue: .init(id, namespace: namespace))
    self.content = content
    self.action = action
  }

  var body: some View {
    ZStack {
      ResponderRepresentable(responder) { action in
        self.action?(action)
      }
      content(responder)
        .onHover { responder.isHovering = $0 }
        .gesture(
          TapGesture().modifiers(.shift).onEnded { _ in
            responder.makeFirstResponder?(true)
          }
        )
        .onTapGesture {
          responder.makeFirstResponder?(false)
        }
    }
  }
}

struct ResponderBackgroundView: View {
  @StateObject var responder: Responder

  var cornerRadius: CGFloat = 8

  @ViewBuilder
  var body: some View {
    RoundedRectangle(cornerRadius: cornerRadius)
      .stroke(Color.accentColor.opacity(responder.isFirstReponder ?
                                        responder.isSelected ? 1.0 : 0.5 : 0.0))
      .opacity(responder.isFirstReponder ? 1.0 : 0.05)

    RoundedRectangle(cornerRadius: cornerRadius)
      .fill(Color.accentColor.opacity((responder.isFirstReponder || responder.isSelected) ? 0.5 : 0.0))
      .opacity((responder.isFirstReponder || responder.isSelected) ? 1.0 : 0.05)
  }
}

private struct ResponderRepresentable: NSViewRepresentable {
  @StateObject var responder: Responder
  private var action: (ResponderAction) -> Void

  init(_ responder: Responder, action: @escaping (ResponderAction) -> Void) {
    _responder = .init(wrappedValue: responder)
    self.action = action
  }

  func makeNSView(context: Context) -> FocusNSView {
    let view = FocusNSView(responder, action: action)
    responder.view = view
    ResponderChain.shared.add(responder)
    return view
  }

  func updateNSView(_ nsView: Self.NSViewType, context: Context) {
    responder.view = nsView
  }
}

private final class FocusNSView: NSControl {
  override var canBecomeKeyView: Bool { true }
  override var acceptsFirstResponder: Bool { true }

  private let responder: Responder
  private var firstResponderSubscription: AnyCancellable?
  private var windowSubscription: AnyCancellable?
  private var actionHandler: (ResponderAction) -> Void

  fileprivate init(_ responder: Responder, action: @escaping (ResponderAction) -> Void) {
    self.responder = responder
    self.actionHandler = action
    super.init(frame: .zero)

    windowSubscription = publisher(for: \.window)
      .compactMap { $0 }
      .sink { [weak self] window in
        self?.subscribe(to: window)
      }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func keyDown(with event: NSEvent) {
    super.keyDown(with: event)
    switch Int(event.keyCode) {
    case kVK_ANSI_A:
      guard let namespace = responder.namespace,
            event.modifierFlags.contains(.command) else { return }
      ResponderChain.shared.selectNamespace(namespace)
    case kVK_Escape:
      ResponderChain.shared.resetSelection()
    case kVK_DownArrow, kVK_RightArrow:
      ResponderChain.shared.setNextResponder(responder)
    case kVK_UpArrow, kVK_LeftArrow:
      ResponderChain.shared.setPreviousResponder(responder)
    case kVK_Return:
      actionHandler(.enter)
    default:
      break
    }
  }

  fileprivate func subscribe(to window: NSWindow) {
    firstResponderSubscription = window.publisher(for: \.firstResponder)
      .sink { [responder, weak self] firstResponder in
        guard let self = self else { return }
        responder.isFirstReponder = firstResponder == self
      }

    responder.makeFirstResponder = { [weak self] isSelected in
      guard let self = self else { return }
      if isSelected {
        ResponderChain.shared.extendSelection(self.responder)
      } else {
        ResponderChain.shared.resetSelection()
      }
      window.makeFirstResponder(self)
      ResponderChain.shared.responderId = self.responder.id
    }
  }
}

fileprivate extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: [Iterator.Element: Bool] = [:]
        return self.filter { seen.updateValue(true, forKey: $0) == nil }
    }
}

fileprivate extension NSView {
  func frameInWindow() -> NSRect {
    convert(bounds, to: window?.contentView)
  }
}
