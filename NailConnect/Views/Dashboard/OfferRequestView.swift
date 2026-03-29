//
//  OfferRequestView.swift
//  NailConnect
//
//  Created by Keith Nguyen.
//


import SwiftUI

struct OfferRequestView: View {
    @State private var selectedTab: Tab = .offers
    let userType: UserType // Pass the logged-in user type
    
    @State private var offers: [Letter] = [] // List of offers
    @State private var requests: [Letter] = [] // List of requests
    
    enum Tab {
        case offers
        case requests
    }
    
    var body: some View {
        VStack {
            // Content Based on Selected Tab
            if selectedTab == .offers {
                LetterListView(letters: offers, title: "Offers", userType: userType, isOffer: true)
            } else {
                LetterListView(letters: requests, title: "Requests", userType: userType, isOffer: false)
            }
            
            Spacer()
            
            // Custom Bottom TabBar
            HStack {
                Spacer()
                
                Button(action: {
                    selectedTab = .offers
                }) {
                    VStack {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(selectedTab == .offers ? Color.blue : Color.gray)
                        
                        Text("Offers")
                            .font(.caption)
                            .foregroundColor(selectedTab == .offers ? Color.blue : Color.gray)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    selectedTab = .requests
                }) {
                    VStack {
                        Image(systemName: "paperplane.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(selectedTab == .requests ? Color.blue : Color.gray)
                        
                        Text("Requests")
                            .font(.caption)
                            .foregroundColor(selectedTab == .requests ? Color.blue : Color.gray)
                    }
                }
                
                Spacer()
            }
            .padding(.vertical, 10)
            .background(Color(UIColor.systemGroupedBackground))
        }
        .onAppear {
            fetchLetters()
        }
        .navigationTitle("Offers/Requests")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func fetchLetters() {
        // Fetch Offers
        AuthManager.shared.fetchLetters(collectionName: "offers") { result in
            switch result {
            case .success(let offers):
                self.offers = offers
            case .failure(let error):
                print("Error fetching offers: \(error.localizedDescription)")
            }
        }
        
        // Fetch Requests
        AuthManager.shared.fetchLetters(collectionName: "requests") { result in
            switch result {
            case .success(let requests):
                self.requests = requests
            case .failure(let error):
                print("Error fetching requests: \(error.localizedDescription)")
            }
        }
    }
}

struct LetterListView: View {
    let letters: [Letter]
    let title: String
    let userType: UserType
    let isOffer: Bool
    
    var body: some View {
        List(letters, id: \.id) { letter in
            NavigationLink(destination: LetterDetailView(letter: letter, userType: userType, isOffer: isOffer)) {
                VStack(alignment: .leading) {
                    Text("\(userType == .owner && isOffer || userType == .technician && !isOffer ? "To: " : "From: ")\(userType == .owner && isOffer || userType == .technician && !isOffer ? letter.receiverName : letter.senderName)")
                        .font(.headline)
                    Text("Phone: \(userType == .owner && isOffer || userType == .technician && !isOffer ? letter.receiverPhoneNumber : letter.phoneNumber)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("\(title): $\(String(format: "%.2f", letter.amount)) for \(letter.weeks) weeks")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct LetterDetailView: View {
    let letter: Letter
    let userType: UserType
    let isOffer: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Letter Details")
                .font(.largeTitle)
            Text("\(userType == .owner && isOffer || userType == .technician && !isOffer ? "To: " : "From: ")\(userType == .owner && isOffer || userType == .technician && !isOffer ? letter.receiverName : letter.senderName)")
            Text("Phone: \(userType == .owner && isOffer || userType == .technician && !isOffer ? letter.receiverPhoneNumber : letter.phoneNumber)")
            Text("Amount: $\(String(format: "%.2f", letter.amount))")
            Text("Weeks: \(letter.weeks)")
            Text("Message: \(letter.message)")
        }
        .padding()
    }
}

// Preview
struct OfferRequestView_Previews: PreviewProvider {
    static var previews: some View {
        OfferRequestView(userType: .technician)
    }
}

#Preview {
    OfferRequestView(userType: .technician) // For technician preview
    OfferRequestView(userType: .owner) // For owner preview
}
