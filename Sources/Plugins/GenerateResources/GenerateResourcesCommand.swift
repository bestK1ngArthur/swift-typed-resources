//
//  GenerateResourcesCommand.swift.swift
//  swift-typed-resources
//
//  Created by Artem Belkov on 29.09.2024.
//  Copyright © 2024 Artem Belkov. All rights reserved.
//

import Foundation
import PackagePlugin

@main
struct GenerateResourcesCommand: CommandPlugin {

    func performCommand(context: PluginContext, arguments: [String]) async throws {
        let tool = try context.tool(named: "SwiftTypedResourcesTool")
        let toolExecutable = URL(fileURLWithPath: tool.path.string)

        for target in context.package.targets {
            guard let target = target as? SourceModuleTarget else { continue }

            let path = target.directory.string
            let arguments: [String] = [
                path,
                path,
                "--resources", "images+strings",
                "--bundle", "module"
            ]

            let process = try Process.run(toolExecutable, arguments: arguments)
            process.waitUntilExit()

            if process.terminationReason == .exit && process.terminationStatus == 0 {
                Diagnostics.progress("Resources have been generated.")
            } else {
                let problem = "\(process.terminationReason):\(process.terminationStatus)"
                Diagnostics.error("Resources generation has been failed: \(problem)")
            }
        }
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension GenerateResourcesCommand: XcodeCommandPlugin {

    func performCommand(context: XcodePluginContext, arguments: [String]) throws {
        let tool = try context.tool(named: "SwiftTypedResourcesTool")
        let toolExecutable = URL(fileURLWithPath: tool.path.string)

        let projectDirectory = context.xcodeProject.directory

        for target in context.xcodeProject.targets {
            let path = projectDirectory.appending([target.displayName]).string
            let arguments: [String] = [
                path,
                path,
                "--resources", "images+strings",
                "--bundle", "main"
            ]

            let process = try Process.run(toolExecutable, arguments: arguments)
            process.waitUntilExit()

            if process.terminationReason == .exit && process.terminationStatus == 0 {
                Diagnostics.progress("Resources have been generated.")
            } else {
                let problem = "\(process.terminationReason):\(process.terminationStatus)"
                Diagnostics.error("Resources generation has been failed: \(problem)")
            }
        }
    }
}

#endif
