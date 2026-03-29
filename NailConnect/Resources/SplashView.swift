//
//  SplashView.swift
//  NailConnect
//
//  Created by Keith Nguyen.
//


import SwiftUI

struct SplashView: View {
    @State private var showLogo = false

    var body: some View {
        ZStack {
            Color.white // Background color
                .ignoresSafeArea()

            VStack {
                if showLogo {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .transition(.opacity.combined(with: .scale))
                        .animation(.easeIn(duration: 1.0), value: showLogo)
                }
            }
            .navigationBarBackButtonHidden(true)
            .interactiveDismissDisabled(true)
        }
        .onAppear {
            withAnimation {
                showLogo = true
            }
        }
    }
    
//    @State private var opacity = 0.0
//
//        var body: some View {
//            ZStack {
//                Color.white // Background color
//                    .ignoresSafeArea()
//
//                VStack {
//                    Image("logo")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 200, height: 200)
//                        .opacity(opacity) // Control the opacity
//                        .animation(.easeIn(duration: 1.0), value: opacity) // Fade-in animation
//                }
//            }
//            .onAppear {
//                // Trigger the fade-in animation
//                opacity = 1.0
//            }
//        }
    
}

#Preview {
    SplashView()
}
