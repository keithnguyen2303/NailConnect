//
//  UserDetailView.swift
//  NailConnect
//
//  Created by Keith Nguyen.
//

import SwiftUI
import SwiftData
import FirebaseFirestore
import FirebaseAuth

struct UserDetailView: View {
    @Binding var userType: UserType
    let user: User
    let context: UserDetailContext // Determines if the button is for SAVE or UNSAVE
    let currentUserType: UserType
    let recipientID: String // Define id of profile to send offer/requests
    let onDismiss: (() -> Void)?
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var navigateToInfo = false
    @State private var navigateToPreference = false
    @State private var isAvailableToday: Bool = false
    @State private var profileImage: UIImage? = nil
    @State private var fullName: String = "Loading..."
    @Query private var userProfiles: [UserProfile]
    
    @State private var showSendSheet: Bool = false
    @State private var showMap: Bool = false
    @State private var showToast: Bool = false
    
    @State private var offerAmount: String = ""
    @State private var selectedWeeks: Int = 1
    @State private var message: String = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Top Section: Profile Image and Name
                    ZStack {
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: 0xf35a7d), Color(hex: 0x0ad7d1)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 200) // Reduced gradient height
                        .edgesIgnoringSafeArea(.top)
                        
                        HStack(alignment: .center, spacing: 20) {
                            // Profile Image
                            if let profileImage = profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 150, height: 150)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            } else {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 150, height: 150)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(Color(hex: 0x0ad7d1))
                                            .frame(width: 50, height: 50)
                                    )
                            }
                            
                            VStack(alignment: .leading) {
                                Text(fullName)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
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
                            .disabled(true)
                    }
                    .padding(.horizontal, 20)
                    
                    // List of Navigation Items
                    VStack(spacing: 15) {
                        
                        DashboardItemView(title: "Personal Information")
                            .onTapGesture {
                                navigateToInfo = true
                            }
                        //DashboardItemView(title: "Document")
                        DashboardItemView(title: "Preferred Schedule")
                            .onTapGesture {
                                navigateToPreference = true
                            }
                        DashboardItemView(title: currentUserType == .owner ? "Send Offer" : "Send Request")
                            .onTapGesture {
                                showSendSheet = true
                            }
                        //DashboardItemView(title: "Contact")
                        DashboardItemView(title: "Map")
                            .onTapGesture {
                                showMap = true
                            }
                    }
                    .padding(.horizontal, 20)
                    
                    // Save Profile Button
                    Button(action: {
                        updateRecentMatch()
                        showToast = true
                    }) {
                        Text(context == .save ? "SAVE PROFILE" : "UNSAVE PROFILE")
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
            .toast(isPresented: $showToast, message: context == .save ? "Saved Successfully!" : "Unsaved Successfully!")
            
            .sheet(isPresented: $showSendSheet) {
                SendRequestOfferSheet(
                    isPresented: $showSendSheet,
                    isOwner: currentUserType == .owner,
                    offerAmount: $offerAmount,
                    selectedWeeks: $selectedWeeks,
                    message: $message,
                    recipientID: recipientID
                )
            }
            .navigationTitle("Matching Profile")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $navigateToInfo) {
                ProfileInformationView(userID: user.id, userType: userType)
            }
            .navigationDestination(isPresented: $navigateToPreference) {
                PreferenceInfoView(searchedUserID: user.id, currentUserType: currentUserType)
            }
            .navigationDestination(isPresented: $showMap) {
                MapViewScreen(currentUserID: Auth.auth().currentUser!.uid, searchUserID: user.id)
            }
            .onAppear {
                print("UserDetailView loaded for recipientID: \(recipientID)")
                loadUserDetails()
            }
        }
    }
    // Load the user profile details from Firestore
    private func loadUserDetails() {
        AuthManager.shared.fetchUserByID(user.id) { result in
            switch result {
            case .success(let data):
                self.fullName = data["name"] as? String ?? "No Name"
                self.isAvailableToday = data["isAvailableToday"] as? Bool ?? false
                
                // Fetch profile image from SwiftData
                if let profile = userProfiles.first(where: { $0.userID == user.id }),
                   let imageData = profile.profileImageData {
                    self.profileImage = UIImage(data: imageData)
                }
            case .failure(let error):
                print("Error fetching user details: \(error.localizedDescription)")
            }
        }
    }
    private func updateRecentMatch() {
        let savedUserID = user.id
        
        let fields: [String: Any]
        if context == .save {
            fields = ["savedMatches": FieldValue.arrayUnion([savedUserID])]
        } else {
            fields = ["savedMatches": FieldValue.arrayRemove([savedUserID])]
        }
        
        AuthManager.shared.updateUserProfile(fields: fields) { result in
            switch result {
            case .success:
                print("Profile for \(user.username) \(context == .save ? "saved" : "unsaved")!")
            case .failure(let error):
                print("Error \(context == .save ? "saving" : "unsaving") profile: \(error.localizedDescription)")
            }
        }
    }
}

struct SendRequestOfferSheet: View {
    @Binding var isPresented: Bool
    let isOwner: Bool // Determines if it's an offer or a request
    @Binding var offerAmount: String
    @Binding var selectedWeeks: Int
    @Binding var message: String
    let recipientID: String
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(isOwner ? "Send Offer" : "Send Request")) {
                    HStack {
                        Text("$") // Leading dollar symbol
                            .font(.headline)
                            .padding(.trailing, 4) // Padding to separate from text field
                        
                        TextField("Enter amount", text: $offerAmount)
                            .keyboardType(.decimalPad)
                            .padding(.vertical, 6) // Ensure proper vertical padding
                        
                        Text("per day") // Trailing "per day" label
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.leading, 4) // Padding to separate from text field
                    }
                    .keyboardType(.decimalPad)
                    
                    HStack {
                        Text("Number of Weeks")
                        Spacer()
                        Picker("", selection: $selectedWeeks) {
                            ForEach(1...52, id: \.self) { week in
                                Text("\(week)").tag(week)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(maxWidth: 100, maxHeight: 100)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Message")
                            .font(.headline)
                        
                        TextEditor(text: $message)
                            .frame(height: 100) // Set a custom height
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            )
                            .padding(.bottom, 10)
                    }
                }
            }
            .onAppear() {
                print("Offer loaded for recipientID: \(recipientID)")
            }
            .navigationTitle(isOwner ? "Send Offer" : "Send Request")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Send") {
                        sendRequestOffer()
                    }.disabled(offerAmount.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    private func sendRequestOffer() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("User not logged in.")
            return
        }
        // Convert `offerAmount` to Double
        guard let amount = Double(offerAmount) else {
            print("Invalid amount: \(offerAmount)")
            return
        }
        // Create the data structure for the offer/request
        let offerOrRequest: [String: Any] = [
            "senderID": currentUserID,
            "recipientID": recipientID,
            "amount": amount,
            "weeks": selectedWeeks,
            "message": message,
            "timestamp": Timestamp(date: Date())
        ]
        
        let collectionName = isOwner ? "offers" : "requests" // Owner sends offers, Technician sends requests
        
        // Log recipient ID for debugging
        print("Sending to recipientID: \(recipientID)")
        
        // Store the data in the recipient's document
        AuthManager.shared.addOfferOrRequest(
            toRecipient: recipientID,
            collectionName: collectionName,
            data: offerOrRequest
        ) { recipientResult in
            switch recipientResult {
            case .success:
                print("\(isOwner ? "Offer" : "Request") added to recipient successfully!")
            case .failure(let error):
                print("Failed to add \(isOwner ? "offer" : "request") to recipient: \(error.localizedDescription)")
            }
            
            // Store the data in the sender's document
            AuthManager.shared.addOfferOrRequest(
                toRecipient: currentUserID,
                collectionName: collectionName,
                data: offerOrRequest
            ) { senderResult in
                switch senderResult {
                case .success:
                    print("\(isOwner ? "Offer" : "Request") added to sender successfully!")
                    isPresented = false // Dismiss the sheet
                case .failure(let error):
                    print("Failed to add \(isOwner ? "offer" : "request") to sender: \(error.localizedDescription)")
                }
            }
        }
    }
}
