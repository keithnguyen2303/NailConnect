//
//  DashboardView.swift
//  NailConnect
//
//  Created by Keith Nguyen.
//


import SwiftUI
import SwiftData
import FirebaseAuth

struct DashboardView: View {
    @Query private var userProfiles: [UserProfile]
    
    @State private var isAvailableToday: Bool = false
    @State private var navigateToEditProfile = false
    @State private var navigateToUserList = false
    @State private var navigateToPreferenceSettings = false
    @State private var navigateToOfferRequest = false
    @State private var navigateToMain = false
    @State private var showNailSalons = false
    @State private var users: [User] = []
    @State private var userName: String = "Loading..."
    @State private var profileImage: UIImage? = nil
    @State private var currentContext: UserDetailContext = .save
    @State private var navigateToLogin = false
    
    
    let userType: UserType
    let onLogout: () -> Void
    
    var body: some View {
        NavigationStack() {
            ScrollView {
                VStack(spacing: 20) {
                    // Top Section: Profile Image and Name
                    ZStack {
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: 0xf35a7d), Color(hex: 0x0ad7d1)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 230) // Restrict gradient height
                        .edgesIgnoringSafeArea(.top)
                        
                        HStack(alignment: .center, spacing: 20) {
                            VStack(alignment: .center) {
                                // Profile Image
                                if let profileImage = profileImage {
                                    Image(uiImage: profileImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 170, height: 170)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                } else {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 170, height: 170)
                                        .overlay(
                                            Image(systemName: "person.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .foregroundColor(Color(hex: 0x0ad7d1))
                                                .frame(width: 50, height: 50)
                                        )
                                }
                                
                                // Logout Button
                                Button(action: {
                                    AuthManager.shared.logout { result in
                                        switch result {
                                        case .success:
                                            print("Logged out successfully.")
                                            navigateToMain = true
                                            
                                        case .failure(let error):
                                            print("Logout failed: \(error.localizedDescription)")
                                        }
                                    }
                                }) {
                                    Text("Logout")
                                        .font(.footnote)
                                        .fontWeight(.bold)
                                        .padding(6)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color(hex: 0xf35a7d), lineWidth: 1)
                                        )
                                }
                                
                            }
                            
                            VStack(alignment: .leading) {
                                Text(userName) // Placeholder for user name
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Button(action: {
                                    navigateToEditProfile = true
                                }) {
                                    Text("Edit profile")
                                        .font(.footnote)
                                        .fontWeight(.bold)
                                        .padding(6)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color(hex: 0x0ad7d1), lineWidth: 1)
                                        )
                                }
                            }
                        }
                        .padding()
                    }
                    
                    // Toggle for Availability or Open Today
                    HStack {
                        Text(userType == .technician ? "Available today" : "Business open today")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: 0xf35a7d))
                        Spacer()
                        Toggle("", isOn: $isAvailableToday)
                            .toggleStyle(SwitchToggleStyle(tint: Color(hex: 0xf35a7d)))
                            .onChange(of: isAvailableToday) {
                                saveAvailabilityStatus()
                            }
                    }
                    .padding(.horizontal, 20)
                    
                    // List of Navigation Items
                    VStack(spacing: 15) {
                        DashboardItemView(title: "Recent saved matches")
                            .onTapGesture {
                                currentContext = .unsave
                                AuthManager.shared.fetchSavedMatches { result in
                                    switch result {
                                    case .success(let savedUsers):
                                        self.users = savedUsers // Pass saved users to the same users array
                                        self.navigateToUserList = true
                                    case .failure(let error):
                                        print("Error fetching saved matches: \(error.localizedDescription)")
                                    }
                                }
                            }
                        //DashboardItemView(title: "Document")
                        DashboardItemView(title: "Preference")
                            .onTapGesture {
                                navigateToPreferenceSettings = true
                            }
                        DashboardItemView(title: "Requests/Offers")
                            .onTapGesture {
                                navigateToOfferRequest = true
                            }
                        DashboardItemView(title: "Nearby Nail Salon")
                            .onTapGesture {
                                showNailSalons = true
                            }
                    }
                    .padding(.horizontal, 20)
                    
                    // Match Technician or Match Salon Button
                    Button(action: {
                        currentContext = .save
                        AuthManager.shared.fetchUsers(ofType: userType) { result in
                            switch result {
                            case .success(let fetchedUsers):
                                self.users = fetchedUsers
                                self.navigateToUserList = true
                            case .failure(let error):
                                print("Error fetching users: \(error.localizedDescription)")
                            }
                        }
                    }) {
                        Text(userType == .technician ? "MATCH SALON" : "MATCH TECHNICIAN")
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(LinearGradient(
                                gradient: Gradient(colors: [Color(hex: 0x0ad7d1), Color(hex: 0xf35a7d)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .foregroundColor(.white)
                            .cornerRadius(25)
                            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 50)
                    .padding(.bottom, 40)
                    
                }
            }
        }
        .navigationTitle(userType == .technician ? "Technician Dashboard" : "Owner Dashboard")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true) // cannot go back to login page here, need to logout
        .interactiveDismissDisabled(true)   // Disable swipe-to-go-back gesture
        .navigationDestination(isPresented: $navigateToEditProfile) {
            ProfileSetupView(userType: userType, isSignupMode: false) // Navigate to Profile Setup
        }
        .navigationDestination(isPresented: $navigateToPreferenceSettings) {
            PreferenceSettingsView(onDismiss: {
                navigateToPreferenceSettings = false
            })
        }
        .navigationDestination(isPresented: $navigateToOfferRequest) {
            OfferRequestView(userType: userType)
        }
        .navigationDestination(isPresented: $navigateToUserList) {
            UserListView(users: users, userType: userType == .technician ? .owner : .technician, context: currentContext, currentUserType: userType)
        }
        .navigationDestination(isPresented: $navigateToMain) {
            MainView()
        }
        .navigationDestination(isPresented: $showNailSalons) {
            NailSalonListView()
        }
        .onAppear() {
            loadUserProfile()
        }
    }
    private func saveAvailabilityStatus() {
        AuthManager.shared.updateAvailabilityStatus(isAvailableToday: isAvailableToday) { result in
            switch result {
            case .success:
                print("Availability status updated to \(isAvailableToday).")
            case .failure(let error):
                print("Failed to update availability status: \(error.localizedDescription)")
            }
        }
    }
    private func loadUserProfile() {
        AuthManager.shared.fetchUserProfile { result in
            switch result {
            case .success(let data):
                self.userName = data["name"] as? String ?? "No Name"
                self.isAvailableToday = data["isAvailableToday"] as? Bool ?? false
                
                // Fetch profile image from SwiftData
                if let userID = Auth.auth().currentUser?.uid {
                    if let profile = userProfiles.first(where: { $0.userID == userID }),
                       let imageData = profile.profileImageData {
                        self.profileImage = UIImage(data: imageData)
                    }
                }
            case .failure(let error):
                print("Error fetching user profile: \(error.localizedDescription)")
            }
        }
    }
}

struct DashboardItemView: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(Color(hex: 0xf35a7d))
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
        )
    }
}

#Preview("Technician Dashboard") {
    DashboardView(userType: .technician, onLogout: {})
}

#Preview("Owner Dashboard") {
    DashboardView(userType: .owner, onLogout: {})
}
