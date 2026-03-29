//
//  ToastView.swift
//  NailConnect
//
//  Created by Keith Nguyen.
//


import SwiftUI

struct ToastView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .font(.body)
            .foregroundColor(.white)
            .padding()
            .background(Color.black.opacity(0.8))
            .cornerRadius(10)
            .shadow(radius: 10)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.clear) // Transparent background to ensure it's centered
    }
}
