import Combine
import SwiftUI

final class ConfigurationCoordinator {
  private var subscription: AnyCancellable?
  let store: ConfigurationStore
  let publisher: ConfigurationPublisher

  init(store: ConfigurationStore) {
    self.store = store
    self.publisher = ConfigurationPublisher()

    subscription = store.$selectedConfiguration.sink(receiveValue: { [weak self] selectedConfiguration in
      self?.render(selectedConfiguration: selectedConfiguration)
    })
  }

  func handle(_ action: SidebarView.Action) {
    switch action {
    case .selectConfiguration(let id):
      store.selectConfiguration(withId: id)
    default:
      break
    }
  }

  private func render(selectedConfiguration: KeyboardCowboyConfiguration?) {
    Task {
      var selections = [ConfigurationViewModel]()
      let configurations = store.configurations
        .map { configuration in
          let viewModel = ConfigurationViewModel(id: configuration.id, name: configuration.name)

          if let selectedConfiguration, configuration.id == selectedConfiguration.id {
            selections.append(viewModel)
          }

          return viewModel
        }

      await publisher.publish(configurations, selections: selections)
    }
  }
}
