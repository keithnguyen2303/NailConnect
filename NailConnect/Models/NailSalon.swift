//
//  NailSalon.swift
//  NailConnect
//
//  Created by Keith Nguyen.
//


import Foundation
import CoreLocation

// Main API Response
struct NailSalonResponse: Decodable {
    let businesses: [NailSalon] // List of nail salons
    let total: Int? // Total number of businesses
    let region: Region // Region info (center coordinates)
    
    enum CodingKeys: String, CodingKey {
            case businesses
            case total
            case region
        }
}

// NailSalon struct representing each business
struct NailSalon: Identifiable, Decodable {
    let id: String
    let name: String
    let isClosed: Bool?
    let reviewCount: Int?
    let categories: [Category]
    let rating: Double
    let phone: String
    let displayPhone: String?
    let image_url: String?
    let url: String
    let businessHours: [BusinessHours]?
    let location: Location
    let coordinates: Coordinates
    let distance: Double
    let alias: String
    let price: String?
    let attributes: Attributes
    
    var fullAddress: String {
        location.displayAddress?.joined(separator: ", ") ?? "No address available"
    }
}

// Category struct for `categories` array
struct Category: Decodable {
    let alias: String
    let title: String
}

// BusinessHours struct for `business_hours` array
struct BusinessHours: Decodable {
    let hoursType: String
    let isOpenNow: Bool
    let open: [OpenHours]
}

// OpenHours struct for the `open` array inside `business_hours`
struct OpenHours: Decodable {
    let isOvernight: Bool
    let start: String
    let end: String
    let day: Int
}

// Location struct for `location`
struct Location: Decodable {
    let displayAddress: [String]?
    let city: String
    let address1: String
    let zipCode: String?
    let country: String
    let address3: String?
    let state: String
    let address2: String?
}

// Coordinates struct for `coordinates`
struct Coordinates: Decodable {
    let longitude: Double
    let latitude: Double
}

// Attributes struct for `attributes`
struct Attributes: Decodable {
    let businessTempClosed: Bool?
    let menuURL: String?
    let waitlistReservation: Bool?
}

// Region struct for `region` in the response
struct Region: Decodable {
    let center: Center
}

// Center struct for `center` within `region`
struct Center: Decodable {
    let longitude: Double
    let latitude: Double
}
