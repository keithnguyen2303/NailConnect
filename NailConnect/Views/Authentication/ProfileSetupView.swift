//
//  ProfileSetupView.swift
//  NailConnect
//
//  Created by Keith Nguyen.
//


import SwiftUI
import FirebaseCore
import SwiftData
import FirebaseAuth

struct ProfileSetupView: View {
    let userType: UserType // Receive userType from the previous view
    let isSignupMode: Bool
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfiles: [UserProfile]
    
    @State private var fullName: String = "Loading..."
    @State private var birthday: Date = Date()
    @State private var birthdayString: String = "Loading..."
    @State private var phoneNumber: String = "Loading..."
    @State private var address: String = "Loading..."
    @State private var profileImage: Image? = nil
    @State private var isImagePickerPresented: Bool = false
    @State private var selectedImage: UIImage? = nil
    @State private var nailSalonName: String = "Loading..."
    @State private var navigateToDashboard : Bool = false
    @State private var showToast: Bool = false
    
    
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
                        
                        // Camera Icon on the Bottom-Right Edge
                        Image(systemName: "camera.fill")
                            .foregroundColor(Color(hex: 0x0ad7d1))
                            .padding(8)
                            .background(Color.white) // Optional: Add a white background behind the icon
                            .clipShape(Circle()) // Optional: Make the background circular
                            .overlay(Circle().stroke(Color(hex: 0x0ad7d1), lineWidth: 1)) // Optional border
                            .offset(x: 10, y: 10) // Adjust positioning slightly outward
                            .onTapGesture {
                                isImagePickerPresented = true
                            }
                    }
                    .frame(width: 200, height: 200)
                }
                .padding(.top, 10)
                // Input Fields
                Group {
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(Color(hex: 0x0ad7d1))
                            .frame(width: 24, alignment: .leading)
                        TextField("Full name", text: $fullName)
                            .textFieldStyle(ProfileTextFieldStyle())
                    }
                    
                    
                    ZStack(alignment: .trailing) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(Color(hex: 0x0ad7d1))
                                .frame(width: 24, alignment: .leading)
                            
                            TextField("Birthday", text: .constant(birthdayString))
                                .disabled(true) // Make the text field uneditable
                                .textFieldStyle(ProfileTextFieldStyle())
                        }
                        
                        Image(systemName: "calendar")
                            .foregroundColor(Color.gray.opacity(0.5))
                            .padding()
                            .overlay {
                                DatePicker("", selection: $birthday, displayedComponents: .date)
                                    .blendMode(.destinationOver)
                                    .labelsHidden()
                                    .onChange(of: birthday) {
                                        birthdayString = formatDate(birthday)
                                    }
                            }
                            .padding(.trailing, 5)
                    }
                    
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundColor(Color(hex: 0x0ad7d1))
                            .frame(width: 24, alignment: .leading)
                        TextField("Phone number", text: $phoneNumber)
                            .textFieldStyle(ProfileTextFieldStyle())
                            .keyboardType(.phonePad)
                    }
                    
                    HStack {
                        Image(systemName: "map.fill")
                            .foregroundColor(Color(hex: 0x0ad7d1))
                            .frame(width: 24, alignment: .leading)
                        TextField("Address", text: $address)
                            .textFieldStyle(ProfileTextFieldStyle())
                    }
                    
                    // Conditionally show the Nail Salon Name field for owners
                    if userType == .owner {
                        HStack {
                            Image(systemName: "building.2.fill")
                                .foregroundColor(Color(hex: 0x0ad7d1))
                                .frame(width: 24, alignment: .leading)
                            TextField("Nail Salon Name", text: $nailSalonName)
                                .textFieldStyle(ProfileTextFieldStyle())
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 5)
                
                Spacer()
                
                // Update Profile Button
                Button(action: {
                    // Save profile data to Firebase
                    AuthManager.shared.updateUserProfile(
                        name: fullName,
                        birthday: birthday,
                        phoneNumber: phoneNumber,
                        address: address,
                        salonName: nailSalonName
                    ) { result in
                        switch result {
                        case .success:
                            print("Profile updated successfully!")
                        case .failure(let error):
                            print("Error updating profile: \(error.localizedDescription)")
                        }
                    }
                    if isSignupMode {
                        navigateToDashboard = true
                    }
                    showToast = true
                }) {
                    Text("UPDATE PROFILE")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient(gradient: Gradient(colors: [Color(hex: 0x0ad7d1), Color(hex: 0xf35a7d)]), startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(25)
                        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 50)
                .padding(.bottom, 40)
                
            }
            .navigationBarBackButtonHidden(isSignupMode)
            .interactiveDismissDisabled(isSignupMode)
            
            .onAppear {
                print("Loaded ProfileSetupView for userType: \(userType)") // For testing
            }
            
            .toast(isPresented: $showToast, message: "Saved successfully!")
            .navigationDestination(isPresented: $navigateToDashboard) {
                DashboardView(userType: userType, onLogout: {}) // Pass the user type here
            }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $selectedImage, image: $profileImage)
                    .onDisappear {
                        if let userID = Auth.auth().currentUser?.uid, let selectedImage = selectedImage,
                           let imageData = selectedImage.pngData() {
                            // Save or update user profile in SwiftData
                            if let existingProfile = userProfiles.first(where: { $0.userID == userID }) {
                                existingProfile.profileImageData = imageData
                            } else {
                                let newProfile = UserProfile(userID: userID, profileImageData: imageData)
                                modelContext.insert(newProfile)
                            }
                        }
                    }
            }
            .onAppear {
                // Fetch user profile from Firestore
                AuthManager.shared.fetchUserProfile { result in
                    switch result {
                    case .success(let data):
                        fullName = data["name"] as? String ?? ""
                        birthday = (data["birthday"] as? Timestamp)?.dateValue() ?? Date()
                        birthdayString = formatDate(birthday) // Format the birthday string
                        phoneNumber = data["phoneNumber"] as? String ?? ""
                        address = data["address"] as? String ?? ""
                        if userType == .owner {
                            nailSalonName = data["salonName"] as? String ?? ""
                        }
                        
                        
                        // Load profile image from SwiftData
                        if let userID = Auth.auth().currentUser?.uid {
                            if let profile = userProfiles.first(where: { $0.userID == userID }),
                               let imageData = profile.profileImageData,
                               let uiImage = UIImage(data: imageData) {
                                self.profileImage = Image(uiImage: uiImage)
                            }
                        }
                        
                    case .failure(let error):
                        print("Error fetching profile: \(error.localizedDescription)")
                    }
                }
            }
        }
        .navigationTitle("Edit Profile")
    }
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// Custom TextField Style for Profile Fields
struct ProfileTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .padding()
            .background(Color.white)
            .cornerRadius(5)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color(hex: 0x0ad7d1), lineWidth: 1)
            )
    }
}

// Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var image: Image?
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.selectedImage = uiImage
                parent.image = Image(uiImage: uiImage)
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

// Preview
#Preview {
    ProfileSetupView(userType: .technician, isSignupMode: true)
}
