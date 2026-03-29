//
//  NailSalonDetailView.swift
//  NailConnect
//
//  Created by Keith Nguyen.
//


import SwiftUI

struct NailSalonDetailView: View {
    let salon: NailSalon
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if let imageURL = salon.image_url, let url = URL(string: imageURL) {
                    let _ = print("Image test URL: \(url)")
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                    } placeholder: {
                        ProgressView()
                    }
                    .cornerRadius(10)
                }
                
                Text(salon.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Text("Rating: \(String(format: "%.1f", salon.rating)) (\(salon.reviewCount ?? 0) reviews)")
                    .font(.subheadline)
                
                if let price = salon.price {
                    Text("Price: \(price)")
                        .font(.subheadline)
                }
                
                Text("Address: \(salon.fullAddress)")
                    .font(.subheadline)
                    .padding(.top)
                
                Text("Phone: \(salon.displayPhone ?? salon.phone)")
                    .font(.subheadline)
                    .padding(.bottom)
                
                if let menuURL = salon.attributes.menuURL, let url = URL(string: menuURL) {
                    Link("View Menu", destination: url)
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding(.top)
                }
                
                
                Link("Visit Yelp Page", destination: URL(string: salon.url)!)
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding(.top)
            }
            .padding()
        }
        .navigationTitle(salon.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
