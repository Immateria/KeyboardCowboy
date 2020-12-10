import Foundation
import ModelKit
import LogicFramework
import ViewKit
import SwiftUI
import Combine

final class SearchFeatureController: ViewController {
  @Published var state = ModelKit.SearchResults.empty()
  let groupController: GroupsControlling
  let searchController: SearchRootController
  var anyCancellables = [AnyCancellable]()

  init(searchController: SearchRootController,
       groupController: GroupsControlling,
       query: Binding<String>) {
    self.groupController = groupController
    self.searchController = searchController

    searchController.$state
      .dropFirst()
      .removeDuplicates()
      .sink(receiveValue: { [weak self] in
      guard let self = self else { return }
      self.state = $0
    }).store(in: &anyCancellables)
  }

  func perform(_ action: SearchResultsList.Action) {
    switch action {
    case .search(let query):
      searchController.search(for: query)
    case .selectCommand(let command):
      if let workflow = groupController.workflow(for: command) {
//        userSelection.group = groupController.group(for: workflow)
//        userSelection.group = groupController.group(for: workflow)
      }
      break
    case .selectWorkflow(let workflow):
//      userSelection.group = groupController.group(for: workflow)
//      userSelection.workflow = workflow
    break
    }
  }
}
