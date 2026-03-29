//
//  NailSalonViewModel.swift
//  NailConnect
//
//  Created by Keith Nguyen on 11/30/24.
//


import Foundation

class NailSalonViewModel: ObservableObject {
    @Published var nailSalons: [NailSalon] = []
    @Published var total: Int = 0
    @Published var regionCenter: Center?
    
    func fetchNailSalons(location: String) async {
        let url = URL(string: "https://api.yelp.com/v3/businesses/search")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "location", value: location),
            URLQueryItem(name: "term", value: "nail salons"),
            URLQueryItem(name: "sort_by", value: "best_match"),
            URLQueryItem(name: "limit", value: "20"),
        ]
        components.queryItems = queryItems
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = [
            "accept": "application/json",
            "Authorization": "Bearer SM55ZJxbyWtaMIa2qw-QiIb3F848ACeMhkH3jH36s0FVpVlRWiwCJpS9GsSIsYHGNqGuyghznTsqfHpSm5a6j6r10djk0OaLhM4OEHTDwGLg-b8M0qedasx6xu1KZ3Yx"
        ]
        
        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = urlResponse as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }
            
            // Pretty-print the raw JSON response
            if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
               let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]) {
                let prettyPrintedString = String(decoding: prettyData, as: UTF8.self)
                print("Pretty JSON Response:\n\(prettyPrintedString)")
            } else {
                print("Failed to pretty-print JSON")
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let apiResponse = try decoder.decode(NailSalonResponse.self, from: data)
            
            DispatchQueue.main.async {
                self.nailSalons = apiResponse.businesses
                self.total = apiResponse.total ?? 0
                self.regionCenter = apiResponse.region.center 
            }
            
        } catch {
            print("Error fetching data: \(error)")
        }
    }
}
