//
//  WelcomeView.swift
//  NailConnect
//
//  Created by Keith Nguyen.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .padding(.top, 80)
            
            Text("WELCOME")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Welcome to Nail Connect! Your go-to platform for finding the perfect match between nail technicians and salon owners. Let’s make connecting easier, faster, and right around the corner. Ready to get started?")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            Spacer()
            
            NavigationLink(destination: AuthView()) {
                Text("GETTING STARTED")
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(LinearGradient(gradient: Gradient(colors: [Color(hex: 0x0ad7d1), Color(hex: 0xf35a7d)]), startPoint: .leading, endPoint: .trailing))
                    .foregroundColor(.white)
                    .cornerRadius(25)
                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                    .padding(.horizontal, 50)
            }
            .padding(.bottom, 40)
        }
        .navigationBarBackButtonHidden(true)
        .interactiveDismissDisabled(true)
    }
}
