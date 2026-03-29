//
//  MainView.swift
//  NailConnect
//
//  Created by Keith Nguyen.
//

import SwiftUI
import FirebaseAuth

/// The `MainView` serves as the entry point to the app. It handles displaying a splash screen, determining the user's login state, and navigating to the appropriate views based on login status and user type.
struct MainView: View {
    // State to control whether the SplashView is shown
    @State private var showSplash = true
    
    // Tracks whether the user is logged in (nil = unknown, true = logged in, false = not logged in)
    @State private var isLoggedIn: Bool? = nil
    
    // Tracks the user's type (e.g., Technician, Salon Owner) after login
    @State private var userType: UserType?
    
    var body: some View {
        ZStack {
            // Show SplashView if `showSplash` is true
            if showSplash {
                SplashView()
            } else if let isLoggedIn = isLoggedIn {
                // After SplashView, navigate based on login state
                NavigationStack {
                    if isLoggedIn, let userType = userType {
                        // If logged in, navigate to DashboardView with user type
                        DashboardView(userType: userType, onLogout: handleLogout)
                    } else {
                        // If not logged in, show WelcomeView
                        WelcomeView()
                    }
                }
            }
        }
        .onAppear {
            // Show SplashView for 1.5 seconds, then check login state
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showSplash = false // Hide SplashView
                checkLoginState() // Determine the user's login state
            }
        }
    }
    
    /// Checks the user's login state and fetches additional profile data if logged in.
    private func checkLoginState() {
        if let currentUser = Auth.auth().currentUser {
            // A user is logged in; fetch user profile data
            print("User is logged in with ID: \(currentUser.uid)")
            
            AuthManager.shared.fetchUserProfile { result in
                switch result {
                case .success(let data):
                    // Parse `userType` from the fetched profile data
                    if let userTypeString = data["userType"] as? String,
                       let userType = UserType(rawValue: userTypeString) {
                        self.userType = userType
                        self.isLoggedIn = true
                        print("Login state confirmed: UserType = \(userType.rawValue)")
                    } else {
                        // Failed to parse `userType` from the fetched data
                        print("Failed to parse userType from Firestore.")
                        self.isLoggedIn = false
                    }
                case .failure(let error):
                    // Handle errors when fetching user profile
                    print("Error fetching user profile: \(error.localizedDescription)")
                    self.isLoggedIn = false
                }
            }
        } else {
            // No user is currently logged in
            print("No user is logged in.")
            isLoggedIn = false
        }
    }
    
    /// Logs out the user and resets login state.
    private func handleLogout() {
        AuthManager.shared.logout { result in
            switch result {
            case .success:
                // Successfully logged out
                print("User logged out successfully.")
                isLoggedIn = false
                userType = nil // Reset user type
            case .failure(let error):
                // Handle logout error
                print("Logout error: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    MainView()
}
