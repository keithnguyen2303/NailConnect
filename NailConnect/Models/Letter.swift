//
//  Letter.swift
//  NailConnect
//
//  Created by Keith Nguyen.
//


import Foundation

struct Letter: Identifiable {
    let id: String           // Unique identifier for each letter
    let senderName: String   // Name of the sender
    let phoneNumber: String  // Contact number of the sender
    let receiverName: String // Name of the receiver
    let receiverPhoneNumber: String // Contact number of the receiver
    let amount: Double       // Monetary value of the letter
    let weeks: Int           // Duration of the work required/desired in weeks
    let message: String      // Additional notes of letter
}
