//
//  ProfileInformationView.swift
//  NailConnect
//
//  Created by Keith Nguyen on 11/30/24.
//


import SwiftUI
import FirebaseCore
import SwiftData
import FirebaseAuth

struct ProfileInformationView: View {
    let userID: String // ID of the user whose profile we are viewing
    let userType: UserType // Technician or Owner
    
    @Query private var userProfiles: [UserProfile]
    
    @State private var navigateback: Bool = false
    @State private var fullName: String = "Loading..."
    @State private var birthday: String = "Loading..."
    @State private var phoneNumber: String = "Loading..."
    @State private var address: String = "Loading..."
    @State private var profileImage: Image? = nil
    @State private var nailSalonName: String = "Loading..."
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                // Top Gradient Background
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: 0xf35a7d), Color(hex: 0x0ad7d1)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 270) // Restrict gradient height
                    .edgesIgnoringSafeArea(.top)
                    
                    ZStack(alignment: .bottomTrailing) {
                        // Profile Image
                        if let profileImage = profileImage {
                            profileImage
                                .resizable()
                                .scaledToFill()
                                .frame(width: 200, height: 200)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color(hex: 0x0ad7d1), lineWidth: 2))
                        } else {
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 150, height: 150)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(Color(hex: 0x0ad7d1))
                                        .frame(width: 50, height: 50)
                                )
                        }
                        
                    }
                    .padding(.top, 40)
                    .frame(width: 200, height: 200)
                    
                }
                .padding(.top, 10)
                
                // Information Fields
                Group {
                    ProfileInfoField(title: "Full Name", value: fullName)
                    ProfileInfoField(title: "Birthday", value: birthday)
                    ProfileInfoField(title: "Phone Number", value: phoneNumber)
                    ProfileInfoField(title: "Address", value: address)
                    
                    if userType == .owner {
                        ProfileInfoField(title: "Nail Salon Name", value: nailSalonName)
                    }
                }
                .padding(.horizontal, 30)
                
            }
            .padding(.bottom, 70)
            .onAppear {
                loadUserProfile()
            }
        }
        .navigationTitle("Profile Information")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateback) {
            DashboardView(userType: userType == .technician ? .owner : .technician, onLogout: {})
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
    }
    
    private func loadUserProfile() {
        // Fetch user details from SwiftData and Firestore
        AuthManager.shared.fetchUserByID(userID) { result in
            switch result {
            case .success(let data):
                fullName = data["name"] as? String ?? "No Name"
                if let birthdayTimestamp = data["birthday"] as? Timestamp {
                    let date = birthdayTimestamp.dateValue()
                    birthday = formatDate(date)
                } else {
                    birthday = "No Birthday"
                }
                phoneNumber = data["phoneNumber"] as? String ?? "No Phone Number"
                address = data["address"] as? String ?? "No Address"
                if userType == .owner {
                    nailSalonName = data["salonName"] as? String ?? "No Salon Name"
                }
                
                // Load profile image from SwiftData
                if let profile = userProfiles.first(where: { $0.userID == userID }),
                   let imageData = profile.profileImageData,
                   let uiImage = UIImage(data: imageData) {
                    profileImage = Image(uiImage: uiImage)
                }
            case .failure(let error):
                print("Error loading user profile: \(error.localizedDescription)")
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}


struct ProfileInfoField: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray) // Field label
            
            Text(value)
                .foregroundColor(.black)
                .padding(.vertical, 12) // Reduce vertical padding inside the box
                .padding(.horizontal, 15)
                .frame(maxWidth: .infinity, minHeight: 60, alignment: .leading) // Adjusted minHeight
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(hex: 0x0ad7d1), lineWidth: 1)
                )
        }
        .padding(.vertical, 5)
    }
    
    private func icon(for title: String) -> String {
        switch title {
        case "Full Name": return "person.fill"
        case "Birthday": return "calendar"
        case "Phone Number": return "phone.fill"
        case "Address": return "map.fill"
        case "Nail Salon Name": return "building.2.fill"
        default: return "info.circle"
        }
    }
}

struct ProfileInformationView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileInformationView(userID: "sampleUserID", userType: .owner)
    }
}
