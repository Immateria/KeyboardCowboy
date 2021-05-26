import Apps
import Foundation
import ModelKit

class WizardGroupExamples {
  // swiftlint:disable function_body_length
  static func groups(_ applications: [Application]) -> [ModelKit.Group] {
    var groups = [ModelKit.Group]()

    if let app = applications.first(where: { $0.bundleName == "Calendar" }) {
      groups.append(Group(name: app.displayName,
                          rule: Rule(bundleIdentifiers: [app.bundleIdentifier]),
                          workflows: [
                            Workflow(name: "This workflow will run when \(app.displayName) is active"),
                            Workflow(name: "You can change this by editing the group")
                          ]))
    }

    if let app = applications.first(where: { $0.bundleName == "Finder" }) {
      groups.append(Group(name: app.displayName,
                          rule: Rule(bundleIdentifiers: [app.bundleIdentifier]),
                          workflows: [
                            Workflow(name: "This workflow will run when \(app.displayName) is active"),
                            Workflow(name: "You can change this by editing the group")
                          ]))
    }

    if let app = applications.first(where: { $0.bundleName == "Mail" }) {
      groups.append(Group(name: app.displayName,
                          rule: Rule(bundleIdentifiers: [app.bundleIdentifier]),
                          workflows: [
                            Workflow(name: "This workflow will run when \(app.displayName) is active"),
                            Workflow(name: "You can change this by editing the group")
                          ]))
    }

    if let app = applications.first(where: { $0.bundleName == "Safari" }) {
      groups.append(Group(name: app.displayName,
                          rule: Rule(bundleIdentifiers: [app.bundleIdentifier]),
                          workflows: [
                            Workflow(name: "This workflow will run when \(app.displayName) is active"),
                            Workflow(name: "You can change this by editing the group")
                          ]))
    }

    groups.append(contentsOf: [
      Self.applicationGroup(applications),
      Self.automationGroup(applications),
      Self.folderGroup(applications),
      Self.scriptGroup(applications),
      Self.webPagesGroup(applications),
    ])

    return groups
  }

  private static func applicationGroup(_ applications: [Application]) -> ModelKit.Group {
    var workflows = [Workflow]()

    if let app = applications.first(where: { $0.bundleName == "Calendar" }) {
      workflows.append(
        Workflow(name: "Open \(app.displayName)",
                 commands: [Command.application(ApplicationCommand(application: app))]
        ))
    }

    if let app = applications.first(where: { $0.bundleName == "Finder" }) {
      workflows.append(
        Workflow(name: "Open \(app.displayName)",
                 commands: [Command.application(ApplicationCommand(application: app))]
        ))
    }

    if let app = applications.first(where: { $0.bundleName == "Mail" }) {
      workflows.append(
        Workflow(name: "Open \(app.displayName)",
                 commands: [Command.application(ApplicationCommand(application: app))]
        ))
    }

    if let app = applications.first(where: { $0.bundleName == "Notes" }) {
      workflows.append(
        Workflow(name: "Open \(app.displayName)",
                 commands: [Command.application(ApplicationCommand(application: app))]
        ))
    }

    if let app = applications.first(where: { $0.bundleName == "Reminders" }) {
      workflows.append(
        Workflow(name: "Open \(app.displayName)",
                 commands: [Command.application(ApplicationCommand(application: app))]
        ))
    }

    if let app = applications.first(where: { $0.bundleName == "Photos" }) {
      workflows.append(
        Workflow(name: "Open \(app.displayName)",
                 commands: [Command.application(ApplicationCommand(application: app))]
        ))
    }

    if let app = applications.first(where: { $0.bundleName == "Messages" }) {
      workflows.append(
        Workflow(name: "Open \(app.displayName)",
                 commands: [Command.application(ApplicationCommand(application: app))]
        ))
    }

    return Group(symbol: "star",
                 name: "Applications",
                 color: "#EB5545",
                 workflows: workflows)
  }

  private static func automationGroup(_ applications: [Application]) -> ModelKit.Group {
    Group(symbol: "checkmark.seal",
          name: "Automation",
          color: "#F2A23C",
          workflows: [
            Workflow(name: "Did you know that Keyboard Cowboy has support for automation?"),
            Workflow(name: "Example automation",
                     trigger: .application([ApplicationTrigger(application: Application(bundleIdentifier: "com.apple.mail",
                                                                                        bundleName: "Mail", path: "/System/Applications/Mail.app"),
                                                               contexts: [
                                                                .frontMost
                                                               ])]),
                     commands: [
                      Command.application(ApplicationCommand(application: Application.calendar()))
                     ],
                     isEnabled: false)
          ])
  }

  private static func folderGroup(_ applications: [Application]) -> ModelKit.Group {
    Group(symbol: "folder",
          name: "Folder & Folders",
          color: "#F9D64A",
          workflows: [
            Workflow(
              name: "Open Downloads folder",
              commands: [
                Command.open(OpenCommand(path: "~/Downloads"))
              ])
          ])
  }

  private static func scriptGroup(_ applications: [Application]) -> ModelKit.Group {
    Group(symbol: "sparkles",
          name: "Scripts",
          color: "#6BD35F",
          workflows: [
            Workflow(name: "This is a good place to add your scripts")
          ])
  }

  private static func webPagesGroup(_ applications: [Application]) -> ModelKit.Group {
    Group(symbol: "bookmark",
          name: "Web pages",
          color: "#3984F7",
          workflows: [
            Workflow(
              name: "Open apple.com",
              commands: [
                Command.open(OpenCommand(path: "https://www.apple.com"))
              ])
          ])
  }
}

