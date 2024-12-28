//
//  CryptoTrackerApp.swift
//  CryptoTracker
//
//  Created by Javier Martin on 22/12/24.
//

import SwiftUI
import SwiftData

@main
struct CryptoTrackerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            CryptoID.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            CryptoListView()
        }
        .modelContainer(sharedModelContainer)
    }
}
