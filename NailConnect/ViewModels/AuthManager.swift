//
//  AuthManager.swift
//  NailConnect
//
//  Created by Keith Nguyen.
//

import FirebaseAuth
import FirebaseFirestore

class AuthManager {
    static let shared = AuthManager()
    private let db = Firestore.firestore()
    
    //Sign Up New User
    func signUp(email: String, username: String, password: String, userType: UserType, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            
            if let error = error as NSError? {
                if AuthErrorCode(rawValue: error.code) == .emailAlreadyInUse {
                    // Handle "email already in use" specifically
                    completion(.failure(NSError(domain: "AuthManager", code: -2, userInfo: [NSLocalizedDescriptionKey: "This email address is already in use."])))
                } else if AuthErrorCode(rawValue: error.code) == .weakPassword {
                    // Handle "weak password" specifically
                    completion(.failure(NSError(domain: "AuthManager", code: -3, userInfo: [NSLocalizedDescriptionKey: "The password must be at least 6 characters long."])))
                } else {
                    completion(.failure(error))
                }
                return
            }
            
            guard let userID = result?.user.uid else {
                completion(.failure(NSError(domain: "AuthManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "User ID not found."])))
                return
            }
            
            // Save username to Firestore
            self.db.collection("users").document(userID).setData([
                "username": username,
                "email": email,
                "userType": userType == .technician ? "technician" : "owner"
            ]) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
    
    // Log In Existing User
    func login(username: String, password: String, completion: @escaping (Result<UserType, Error>) -> Void) {
        // Fetch email and userType by username
        db.collection("users").whereField("username", isEqualTo: username).getDocuments { querySnapshot, error in
            if let error = error {
                print("Firestore Error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            guard let document = querySnapshot?.documents.first,
                  let email = document.data()["email"] as? String,
                  let userTypeString = document.data()["userType"] as? String,
                  let userType = UserType(rawValue: userTypeString) else {
                print("No user found with username: \(username)")
                completion(.failure(NSError(domain: "AuthManager", code: -4, userInfo: [NSLocalizedDescriptionKey: "Username not found or password is incorrect. Please try again."])))
                return
            }
            
            // Perform Firebase login with email
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error as NSError? {
                    print("Firebase Auth Error: \(error.localizedDescription)")
                    completion(.failure(NSError(domain: "AuthManager", code: -4, userInfo: [NSLocalizedDescriptionKey: "Username not found or password is incorrect. Please try again."])))
                } else {
                    print("Login successful for email: \(email)")
                    completion(.success(userType)) // Return userType upon success
                }
            }
        }
    }
    // Log out User
    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    // Check if User is Logged In
    func checkIfUserIsLoggedIn(completion: @escaping (Result<UserType, Error>) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "AuthManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No logged-in user."])))
            return
        }
        
        // Fetch userType from Firestore
        db.collection("users").document(currentUser.uid).getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = document?.data(),
                  let userTypeString = data["userType"] as? String,
                  let userType = UserType(rawValue: userTypeString) else {
                completion(.failure(NSError(domain: "AuthManager", code: -2, userInfo: [NSLocalizedDescriptionKey: "User type not found."])))
                return
            }
            
            completion(.success(userType))
        }
    }
    
    func fetchUserProfile(completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "AuthManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in."])))
            return
        }
        
        db.collection("users").document(userID).getDocument { document, error in
            if let error = error {
                completion(.failure(error))
            } else if let document = document, document.exists {
                completion(.success(document.data() ?? [:]))
            } else {
                completion(.failure(NSError(domain: "AuthManager", code: -2, userInfo: [NSLocalizedDescriptionKey: "User profile not found."])))
            }
        }
    }
    
    func fetchUserByID(_ userID: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        db.collection("users").document(userID).getDocument { document, error in
            if let error = error {
                completion(.failure(error))
            } else if let document = document, document.exists {
                completion(.success(document.data() ?? [:]))
            } else {
                completion(.failure(NSError(domain: "AuthManager", code: -2, userInfo: [NSLocalizedDescriptionKey: "User not found."])))
            }
        }
    }
    
    // Update User Profile
    func updateUserProfile(fields: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "AuthManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in."])))
            return
        }
        
        db.collection("users").document(userID).updateData(fields) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func updateAvailabilityStatus(isAvailableToday: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "AuthManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in."])))
            return
        }
        
        db.collection("users").document(userID).updateData([
            "isAvailableToday": isAvailableToday
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func fetchUsers(ofType userType: UserType, completion: @escaping (Result<[User], Error>) -> Void) {
        let targetType = userType == .technician ? "owner" : "technician"
        
        db.collection("users").whereField("userType", isEqualTo: targetType).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let documents = snapshot?.documents else {
                completion(.failure(NSError(domain: "AuthManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No users found."])))
                return
            }
            let users = documents.compactMap { doc -> User? in
                let data = doc.data()
                return User(
                    id: doc.documentID,
                    username: data["username"] as? String ?? "",
                    email: data["email"] as? String ?? "",
                    userType: UserType(rawValue: data["userType"] as? String ?? "") ?? .technician // default to .technician
                )
            }
            completion(.success(users))
        }
    }
    
    func fetchSavedMatches(completion: @escaping (Result<[User], Error>) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "AuthManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in."])))
            return
        }
        
        db.collection("users").document(currentUserID).getDocument { document, error in
            if let error = error {
                completion(.failure(error))
            } else if let document = document, let data = document.data(),
                      let savedMatches = data["savedMatches"] as? [String], !savedMatches.isEmpty {
                
                // Fetch the user profiles for the savedMatches IDs
                self.db.collection("users").whereField(FieldPath.documentID(), in: savedMatches).getDocuments { querySnapshot, error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        let users: [User] = querySnapshot?.documents.compactMap { doc in
                            let data = doc.data()
                            return User(
                                id: doc.documentID,
                                username: data["username"] as? String ?? "Unknown",
                                email: data["email"] as? String ?? "No Email",
                                userType: UserType(rawValue: data["userType"] as? String ?? "") ?? .technician
                            )
                        } ?? []
                        completion(.success(users))
                    }
                }
            } else {
                completion(.success([])) // No saved matches found
            }
        }
    }
    // Update user profile with additional information
    func updateUserProfile(name: String, birthday: Date, phoneNumber: String, address: String, salonName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "AuthManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in."])))
            return
        }
        
        let profileData: [String: Any] = [
            "name": name,
            "birthday": Timestamp(date: birthday),
            "phoneNumber": phoneNumber,
            "address": address,
            "salonName": salonName
        ]
        
        db.collection("users").document(userID).setData(profileData, merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func updatePreferences(availableDays: [String], maxTravelDistance: Double, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "AuthManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in."])))
            return
        }
        
        let preferencesData: [String: Any] = [
            "availableDays": availableDays,
            "maxTravelDistance": maxTravelDistance
        ]
        
        db.collection("users").document(userID).setData(preferencesData, merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func addOfferOrRequest(toRecipient recipientID: String, collectionName: String, data: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        print("Adding \(collectionName) to recipientID: \(recipientID)")
        print("Data: \(data)")
        let recipientRef = db.collection("users").document(recipientID)
        
        recipientRef.updateData([
            collectionName: FieldValue.arrayUnion([data])
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // Fetch Letters (Offers or Requests)
    func fetchLetters(collectionName: String, completion: @escaping (Result<[Letter], Error>) -> Void) {
        fetchUserProfile { result in
            switch result {
            case .success(let userData):
                guard let letters = userData[collectionName] as? [[String: Any]] else {
                    completion(.success([])) // If no letters, return an empty array
                    return
                }
                
                // Fetch details for sender and recipient for each letter
                let group = DispatchGroup()
                var mappedLetters: [Letter] = []
                
                for letter in letters {
                    group.enter()
                    
                    let senderID = letter["senderID"] as? String ?? ""
                    let recipientID = letter["recipientID"] as? String ?? ""
                    let amount = letter["amount"] as? Double ?? 0.0
                    let weeks = letter["weeks"] as? Int ?? 0
                    let message = letter["message"] as? String ?? "No message"
                    let id = letter["id"] as? String ?? UUID().uuidString
                    
                    // Fetch sender and recipient details
                    var senderName = "Unknown"
                    var senderPhoneNumber = "Unknown"
                    var receiverName = "Unknown"
                    var receiverPhoneNumber = "Unknown"
                    
                    let fetchSender = DispatchGroup()
                    fetchSender.enter()
                    AuthManager.shared.fetchUserByID(senderID) { senderResult in
                        switch senderResult {
                        case .success(let senderData):
                            senderName = senderData["name"] as? String ?? "Unknown"
                            senderPhoneNumber = senderData["phoneNumber"] as? String ?? "Unknown"
                        case .failure(let error):
                            print("Error fetching sender details: \(error.localizedDescription)")
                        }
                        fetchSender.leave()
                    }
                    
                    let fetchRecipient = DispatchGroup()
                    fetchRecipient.enter()
                    AuthManager.shared.fetchUserByID(recipientID) { recipientResult in
                        switch recipientResult {
                        case .success(let recipientData):
                            receiverName = recipientData["name"] as? String ?? "Unknown"
                            receiverPhoneNumber = recipientData["phoneNumber"] as? String ?? "Unknown"
                        case .failure(let error):
                            print("Error fetching recipient details: \(error.localizedDescription)")
                        }
                        fetchRecipient.leave()
                    }
                    
                    // Wait for both sender and recipient fetches to complete
                    fetchSender.notify(queue: .main) {
                        fetchRecipient.notify(queue: .main) {
                            let letter = Letter(
                                id: id,
                                senderName: senderName,
                                phoneNumber: senderPhoneNumber,
                                receiverName: receiverName,
                                receiverPhoneNumber: receiverPhoneNumber,
                                amount: amount,
                                weeks: weeks,
                                message: message
                            )
                            mappedLetters.append(letter)
                            group.leave()
                        }
                    }
                }
                
                // Wait for all letters to be processed
                group.notify(queue: .main) {
                    completion(.success(mappedLetters))
                }
                
            case .failure(let error):
                print("Error fetching user profile: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
}

