//
//  UserProfile.swift
//  NailConnect
//
//  Created by Keith Nguyen.
//


import Foundation
import SwiftData

@Model
class UserProfile: Identifiable {
    @Attribute(.unique) var userID: String // Corresponds to Firebase UID
    @Attribute var profileImageData: Data? // Image stored as binary data
    
    init(userID: String, profileImageData: Data?) {
        self.userID = userID
        self.profileImageData = profileImageData
    }
}
