//
//  UserListView.swift
//  NailConnect
//
//  Created by Keith Nguyen.
//


import SwiftUI
import SwiftData
import FirebaseFirestore
import FirebaseAuth

struct UserListView: View {
    
    @State private var users: [User]
    @State private var userType: UserType
    let context: UserDetailContext
    let currentUserType: UserType
    @Query private var userProfiles: [UserProfile] // SwiftData for profile images
    
    // Add a public or internal initializer
    init(users: [User], userType: UserType, context: UserDetailContext, currentUserType: UserType) {
        self.users = users
        self.userType = userType
        self.context = context
        self.currentUserType = currentUserType
    }
    
    var navigationTitle: String {
        if context == .save {
            let userType = users.first?.userType.rawValue.capitalized ?? "Profiles"
            return "Available \(userType)"
        } else {
            let userType = users.first?.userType.rawValue.capitalized ?? "Profiles"
            return "Saved \(userType)"
        }
    }
    
    var body: some View {
        if users.isEmpty {
            VStack {
                Spacer()
                Text("No Profiles Saved")
                    .font(.title) // Larger font
                    .fontWeight(.bold) // Bold for emphasis
                    .foregroundColor(.gray) // Subtle color
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.large)
        } else {
            List(users, id: \.id) { user in
                NavigationLink(
                    destination: UserDetailView(
                        userType: $userType,
                        user: user,
                        context: context,
                        currentUserType: currentUserType,
                        recipientID: user.id,
                        onDismiss: {
                            if context == .unsave {
                                fetchUpdatedUsers()
                            }
                        })) {
                            HStack(spacing: 15) {
                                // Profile Image
                                if let profile = userProfiles.first(where: { $0.userID == user.id }),
                                   let imageData = profile.profileImageData,
                                   let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50) // Thumbnail size
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                                } else {
                                    Circle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 50, height: 50) // Default placeholder size
                                        .overlay(
                                            Image(systemName: "person.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .foregroundColor(.gray)
                                                .frame(width: 25, height: 25)
                                        )
                                }
                                // User Details
                                VStack(alignment: .leading) {
                                    Text(user.username)
                                        .font(.headline)
                                    Text(user.userType.rawValue.capitalized)
                                        .foregroundColor(.gray)
                                        .font(.subheadline)
                                }
                            }
                        }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.large)
            .listStyle(PlainListStyle())
        }
    }
    
    private func fetchUpdatedUsers() {
        AuthManager.shared.fetchSavedMatches { result in
            switch result {
            case .success(let updatedUsers):
                self.users = updatedUsers
            case .failure(let error):
                print("Error fetching saved matches: \(error.localizedDescription)")
            }
        }
    }
}

enum UserDetailContext {
    case save
    case unsave
}



