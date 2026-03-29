//
//  PreferenceInfoView.swift
//  NailConnect
//
//  Created by Keith Nguyen on 11/30/24.
//


import SwiftUI

struct PreferenceInfoView: View {
    let searchedUserID: String // The ID of the user whose preferences are being viewed
    let currentUserType: UserType
    @State private var navigateback: Bool = false
    @State private var selectedDays: [String] = []
    @State private var isTravelDistanceEnabled: Bool = false
    @State private var maxTravelDistance: String = ""
    
    let daysOfWeek = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    
    var body: some View {
        List {
            // Weekly Preferences Section
            Section(header: Text("Weekly Preferences")) {
                ForEach(daysOfWeek, id: \.self) { day in
                    HStack {
                        Text("Every \(day)")
                        Spacer()
                        if selectedDays.contains(day) {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color(hex: 0x0ad7d1)) // Updated color
                        }
                    }
                }
            }
            
            // Travel Distance Section
            Section(header: Text("Maximum Travel Distance")) {
                Toggle("Enable Travel Distance", isOn: .constant(isTravelDistanceEnabled))
                    .toggleStyle(SwitchToggleStyle(tint: Color.gray)) // Disabled style
                    .disabled(true)
                
                if isTravelDistanceEnabled {
                    HStack {
                        Text("Travel Distance")
                        Spacer()
                        if !maxTravelDistance.isEmpty {
                            Text("\(maxTravelDistance) mi")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .navigationTitle("Preferences")
        .navigationBarTitleDisplayMode(.large)
        .listStyle(InsetGroupedListStyle())
        .navigationDestination(isPresented: $navigateback) {
            DashboardView(userType: currentUserType, onLogout: {})
        }
        .navigationBarBackButtonHidden(true) // Hide the default back button
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    navigateback = true
                }) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
            }
        }
        .onAppear {
            loadPreferences()
        }
    }
    
    private func loadPreferences() {
        // Fetch preferences for the searched user by their ID
        AuthManager.shared.fetchUserByID(searchedUserID) { result in
            switch result {
            case .success(let data):
                if let days = data["availableDays"] as? [String] {
                    self.selectedDays = days
                }
                if let distance = data["maxTravelDistance"] as? Double {
                    self.isTravelDistanceEnabled = distance > 0
                    self.maxTravelDistance = distance > 0 ? String(distance) : ""
                }
            case .failure(let error):
                print("Error fetching preferences: \(error.localizedDescription)")
            }
        }
    }
}
