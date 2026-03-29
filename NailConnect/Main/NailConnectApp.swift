//
//  NailConnectApp.swift
//  NailConnect
//
//  Created by Keith Nguyen.
//

import SwiftUI
import FirebaseCore
import SwiftData

/// The main entry point of the NailConnect application.
@main
struct NailConnectApp: App {
    // Shared ModelContainer for managing SwiftData models
    var sharedModelContainer: ModelContainer = {
        // Define the schema for the SwiftData model
        let schema = Schema([
            UserProfile.self // Register the `UserProfile` model
        ])
        
        // Configure the model container with persistent storage
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            // Attempt to create and return a ModelContainer with the given configuration
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // Terminate the app if the ModelContainer creation fails
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    /// Initializes the app and configures Firebase during startup.
    init() {
        FirebaseApp.configure() // Configure Firebase SDK
        print("Firebase configured successfully.") // Confirm Firebase configuration in logs
    }
    
    /// Defines the body of the app and its primary scene.
    var body: some Scene {
        WindowGroup {
            MainView() // Launch the `MainView` as the root view
        }
        .modelContainer(sharedModelContainer) // Provide the `ModelContainer` to the app's environment
    }
}
