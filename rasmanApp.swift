//
//  rasmanApp.swift
//  rasman
//
//  Created by Lucas J. Chumley on 8/14/24.
//

import SwiftUI
import SwiftData

@main
struct rasmanApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ServerSettings.self,
            SentMessage.self,
            
        ])
        let modelConfiguration = ModelConfiguration(schema: schema)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark) // Force Dark Mode
        }
        .modelContainer(sharedModelContainer)
        .commands {
            CommandGroup(replacing: .newItem, addition: { })
            CommandGroup(replacing: .appInfo) {
                Button("About RASman") {
                    NSApplication.shared.orderFrontStandardAboutPanel(
                        options: [
                            NSApplication.AboutPanelOptionKey.credits: NSAttributedString(
                                string: "Created with ❤️ by Lucas in Tennessee",
                                attributes: [
                                    NSAttributedString.Key.font: NSFont.boldSystemFont(
                                        ofSize: NSFont.smallSystemFontSize)
                                ]
                            ),
                        ]
                    )
                }
            }
        }
    }
}


