//
//  AuthView.swift
//  NailConnect
//
//  Created by Keith Nguyen.
//

import SwiftUI

struct AuthView: View {
    @State private var isSignupMode = true // Toggles between signup and login
    @State private var username = ""
    @State private var password = ""
    @State private var email = ""
    @State private var selectedUserType: UserType = .technician // Default
    @State private var errorMessage: String? // For error message display
    @State private var isPasswordVisible = false // Toggles password visibility
    @State private var navigateToProfileSetup = false // State variable for navigation
    @State private var navigateToDashboard = false // State variable for navigation
    
    @FocusState private var focusedField: Field? // Tracks focused field
    
    enum Field {
        case email, username, password
    }
    
    var body: some View {
        //       NavigationStack {
        VStack(spacing: 20) {
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .padding(.top, 40)
            
            Text(isSignupMode ? "SIGN UP" : "LOG IN")
                .font(.title)
                .fontWeight(.bold)
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .padding(.horizontal, 30)
                    .multilineTextAlignment(.center)
            }
            
            if isSignupMode {
                TextField("Email", text: $email)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(5)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(getStrokeColor(field: .email), lineWidth: 1))
                    .padding(.horizontal, 30)
                    .focused($focusedField, equals: .email)
                    .onChange(of: email) { checkFieldStates() }
                    .autocapitalization(.none)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .textContentType(.emailAddress)
                
            }
            
            TextField("Username", text: $username)
                .padding()
                .background(Color.white)
                .cornerRadius(5)
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(getStrokeColor(field: .username), lineWidth: 1))
                .padding(.horizontal, 30)
                .focused($focusedField, equals: .username)
                .onChange(of: username) { checkFieldStates() }
                .autocapitalization(.none)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .textContentType(.username)
            
            ZStack(alignment: .trailing) {
                Group {
                    if isPasswordVisible {
                        TextField("Password", text: $password)
                    }
                    else {
                        SecureField("Password", text: $password)
                    }
                }
                .padding(.trailing, 25)
                .frame(height: 25)
                .padding()
                .background(Color.white)
                .cornerRadius(5)
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(getStrokeColor(field: .password), lineWidth: 1))
                .padding(.horizontal, 30)
                .focused($focusedField, equals: .password)
                .onChange(of: password) { checkFieldStates() }
                .autocapitalization(.none)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .textContentType(.username)
                
                Button(action: {
                    isPasswordVisible.toggle()
                }) {
                    Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                        .foregroundColor(isPasswordVisible ? Color(hex: 0x0ad7d1) : Color(hex: 0xf35a7d))
                        .padding()
                }
                .padding(.trailing, 20)
            }
            
            
            if isSignupMode {
                Text("You are...")
                    .font(.subheadline)
                
                HStack {
                    RadioButton(title: "Nail Technician", isSelected: $selectedUserType, matchingType: .technician)
                    RadioButton(title: "Salon Owner", isSelected: $selectedUserType, matchingType: .owner)
                }
            }
            
            Button(action: {
                handleAuthentication()
            }) {
                Text(isSignupMode ? "SIGN UP" : "LOG IN")
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(LinearGradient(gradient: Gradient(colors: [Color(hex: 0x0ad7d1), Color(hex: 0xf35a7d)]), startPoint: .leading, endPoint: .trailing))
                    .foregroundColor(.white)
                    .cornerRadius(25)
                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                    .padding(.horizontal, 50)
            }
            .padding(.top, 20)
            
            Spacer()
            
            HStack {
                Text(isSignupMode ? "Already have an account?" : "Don't have an account?")
                Button(action: {
                    isSignupMode.toggle()
                }) {
                    Text(isSignupMode ? "Login" : "Signup")
                        .foregroundColor(Color(hex: 0xf35a7d))
                }
            }
            .padding(.bottom, 40)
            .padding(.horizontal, 20)
        }
        .navigationDestination(isPresented: $navigateToProfileSetup) {
            ProfileSetupView(userType: selectedUserType, isSignupMode: isSignupMode) // Destination view
        }
        .navigationDestination(isPresented: $navigateToDashboard) {
            DashboardView(userType: selectedUserType, onLogout: {}) // Pass the user type here
        }
        //        }
    }
    
    private func handleAuthentication() {
        errorMessage = nil // Reset error message before each attempt
        
        if isSignupMode {
            // Validate input for signup
            guard !email.isEmpty, !username.isEmpty, !password.isEmpty else {
                errorMessage = "Email, username, and password cannot be empty."
                return
            }
            
            // Call AuthManager to handle signup
            AuthManager.shared.signUp(email: email, username: username, password: password, userType: selectedUserType) { result in
                switch result {
                case .success:
                    print("Signup successful!")
                    errorMessage = nil
                    navigateToProfileSetup = true // Trigger navigation
                case .failure(let error):
                    print("Signup error: \(error.localizedDescription)")
                    errorMessage = error.localizedDescription
                }
            }
        } else {
            // Validate input for login
            guard !username.isEmpty, !password.isEmpty else {
                errorMessage = "Username and password cannot be empty."
                return
            }
            
            // Call AuthManager to handle login
            AuthManager.shared.login(username: username, password: password) { result in
                switch result {
                case .success(let userType):
                    print("Login successful!")
                    errorMessage = nil
                    selectedUserType = userType // Set the userType for navigation
                    navigateToDashboard = true
                case .failure(let error):
                    print("Login error: \(error.localizedDescription)")
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func getStrokeColor(field: Field) -> Color {
        if focusedField == field {
            return isFieldEmpty(field: field) ? Color(hex: 0xf35a7d) : Color(hex: 0x0ad7d1)
        } else {
            return Color.gray.opacity(0.5) // Default color for unfocused fields
        }
    }
    
    private func isFieldEmpty(field: Field) -> Bool {
        switch field {
        case .email:
            return email.isEmpty
        case .username:
            return username.isEmpty
        case .password:
            return password.isEmpty
        }
    }
    
    private func checkFieldStates() {
    }
}

struct RadioButton: View {
    let title: String
    @Binding var isSelected: UserType
    let matchingType: UserType
    
    var body: some View {
        HStack {
            Image(systemName: isSelected == matchingType ? "largecircle.fill.circle" : "circle")
                .foregroundColor(isSelected == matchingType ? Color(hex: 0xf35a7d) : .gray)
                .onTapGesture {
                    isSelected = matchingType
                }
            Text(title)
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    AuthView()
}

