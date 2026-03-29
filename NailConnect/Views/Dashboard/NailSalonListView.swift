//
//  NailSalonListView.swift
//  NailConnect
//
//  Created by Keith Nguyen on 11/30/24.
//


import SwiftUI

struct NailSalonListView: View {
    @StateObject private var viewModel = NailSalonViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.nailSalons.isEmpty {
                    ProgressView("Loading Nail Salons...")
                        .padding()
                } else {
                    List(viewModel.nailSalons) { salon in
                        NavigationLink(destination: NailSalonDetailView(salon: salon)) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(salon.name)
                                    .font(.headline)
                                
                                Text("Rating: \(String(format: "%.1f", salon.rating)) (\(salon.reviewCount ?? 0) reviews)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text(salon.fullAddress)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Nail Salons")
            .onAppear {
                Task {
                    await viewModel.fetchNailSalons(location: "Tempe, AZ")
                }
            }
        }
    }
}
