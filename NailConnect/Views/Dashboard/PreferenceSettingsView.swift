//
//  PreferenceSettingsView.swift
//  NailConnect
//
//  Created by Keith Nguyen.
//

import SwiftUI

struct PreferenceSettingsView: View {
    @State private var selectedDays: [String] = []
    @State private var isTravelDistanceEnabled: Bool = false
    @State private var maxTravelDistance: String = ""
    @State private var showDistanceAlert: Bool = false
    let onDismiss: () -> Void
    
    
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
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if selectedDays.contains(day) {
                            selectedDays.removeAll { $0 == day }
                        } else {
                            selectedDays.append(day)
                        }
                    }
                }
            }
            
            // Travel Distance Section
            Section(header: Text("Maximum Travel Distance")) {
                Toggle("Enable Travel Distance", isOn: $isTravelDistanceEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: Color(hex: 0xf35a7d))) // Updated color
                
                if isTravelDistanceEnabled {
                    Button(action: {
                        showDistanceAlert = true
                    }) {
                        HStack {
                            Text("Set Distance")
                            Spacer()
                            if !maxTravelDistance.isEmpty {
                                Text("\(maxTravelDistance) mi")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
        }
        .navigationTitle("Preference")
        .listStyle(InsetGroupedListStyle())
        .alert("Set Maximum Travel Distance", isPresented: $showDistanceAlert) {
            VStack {
                TextField("Enter distance in miles", text: $maxTravelDistance)
                    .keyboardType(.numberPad)
                    .onChange(of: maxTravelDistance) {oldValue, newValue in
                        let filtered = newValue.filter { "0123456789.".contains($0) } // Allow digits and dot
                        let dotCount = filtered.filter { $0 == "." }.count // Count the dots
                        if dotCount > 1 {
                            maxTravelDistance = String(filtered.dropLast()) // Remove the extra dot
                        } else {
                            maxTravelDistance = filtered // Accept the valid filtered input
                        }
                    }
            }
            
            Button("Cancel", role: .cancel) {}
            Button("OK", action: {
            })
            .disabled(maxTravelDistance.isEmpty) // Disable OK if the field is empty
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    savePreferences()
                    onDismiss()
                }
                .disabled(selectedDays.isEmpty && !isTravelDistanceEnabled)
            }
        }
        .onAppear() {
            loadPreferences()
        }
    }
    private func savePreferences() {
        let finalTravelDistance = isTravelDistanceEnabled ? Double(maxTravelDistance) ?? 0 : 0
        // Save preferences to Firebase
        AuthManager.shared.updatePreferences(availableDays: selectedDays, maxTravelDistance: finalTravelDistance) { result in
            switch result {
            case .success:
                print("Preferences saved successfully!")
            case .failure(let error):
                print("Error saving preferences: \(error.localizedDescription)")
            }
        }
    }
    
    private func loadPreferences() {
        AuthManager.shared.fetchUserProfile { result in
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

