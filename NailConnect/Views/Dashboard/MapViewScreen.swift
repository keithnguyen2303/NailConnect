//
//  MapViewScreen.swift
//  NailConnect
//
//  Created by Keith Nguyen.
//


import SwiftUI
import MapKit
import FirebaseFirestore
import FirebaseAuth
import CoreLocation

struct MapViewScreen: View {
    @State private var currentUserCoordinate: CLLocationCoordinate2D?
    @State private var searchUserCoordinate: CLLocationCoordinate2D?
    @State private var currentUserName: String = "Loading..."
    @State private var currentUserAddress: String = "Loading address..."
    @State private var searchUserName: String = "Loading..."
    @State private var searchUserAddress: String = "Loading address..."
    @State private var landmarks: [Landmark] = []
    @State private var isLoading = true
    @State private var distance: String = "Calculating distance..." // Holds the calculated distance
    @State private var maxTravelDistance: Double? // Fetch from Firebase
    @State private var distanceColor: Color = .gray // Default to gray
    @State private var preferenceText: String? // Text indicating preference match
    let currentUserID: String
    let searchUserID: String

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading locations...")
                    .frame(height: 400)
            } else {
                MapView(landmarks: landmarks)
                    .edgesIgnoringSafeArea(.all)
                    .frame(height: 400)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Your Location:")
                    .font(.headline)
                Text(currentUserName)
                    .font(.subheadline)
                Text(currentUserAddress)
                    .foregroundColor(.gray)
                    .padding(.bottom)

                Text("\(searchUserName)'s Location:")
                    .font(.headline)
                Text(searchUserName)
                    .font(.subheadline)
                Text(searchUserAddress)
                    .foregroundColor(.gray)
                    .padding(.bottom)

                HStack {
                    Text("Estimated Distance:")
                        .font(.headline)
                    Text(distance)
                        .foregroundColor(distanceColor)
                    if let preferenceText = preferenceText {
                        Text(preferenceText)
                            .foregroundColor(distanceColor)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
        }
        .onAppear {
            fetchAndGeocodeAddresses()
        }
        .navigationTitle("Location Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func fetchAndGeocodeAddresses() {
        let db = Firestore.firestore()
        let geocoder = CLGeocoder()

        // Fetch current user's address
        let currentUserRef = db.collection("users").document(currentUserID)
        let searchUserRef = db.collection("users").document(searchUserID)

        // Group Dispatch to handle both fetches
        let group = DispatchGroup()

        // Fetch current user address
        group.enter()
        currentUserRef.getDocument { document, error in
            if let error = error {
                print("Error fetching current user address: \(error.localizedDescription)")
                group.leave()
                return
            }
            if let data = document?.data() {
                self.currentUserName = data["name"] as? String ?? "No Name"
                self.currentUserAddress = data["address"] as? String ?? "No Address"
                self.maxTravelDistance = data["maxTravelDistance"] as? Double // Fetch maxTravelDistance
                geocoder.geocodeAddressString(self.currentUserAddress) { placemarks, error in
                    if let coordinate = placemarks?.first?.location?.coordinate {
                        self.currentUserCoordinate = coordinate
                        self.landmarks.append(
                            Landmark(
                                placemark: MKPlacemark(coordinate: coordinate),
                                name: "Your Location"
                            )
                        )
                    }
                    group.leave()
                }
            } else {
                group.leave()
            }
        }

        // Fetch search user address
        group.enter()
        searchUserRef.getDocument { document, error in
            if let error = error {
                print("Error fetching search user address: \(error.localizedDescription)")
                group.leave()
                return
            }
            if let data = document?.data() {
                self.searchUserName = data["name"] as? String ?? "No Name"
                self.searchUserAddress = data["address"] as? String ?? "No Address"
                geocoder.geocodeAddressString(self.searchUserAddress) { placemarks, error in
                    if let coordinate = placemarks?.first?.location?.coordinate {
                        self.searchUserCoordinate = coordinate
                        self.landmarks.append(
                            Landmark(
                                placemark: MKPlacemark(coordinate: coordinate),
                                name: "\(self.searchUserName)'s Location"
                            )
                        )
                    }
                    group.leave()
                }
            } else {
                group.leave()
            }
        }

        // Once both are fetched and geocoded
        group.notify(queue: .main) {
            isLoading = false
            calculateDistance()
        }
    }

    private func calculateDistance() {
        guard let currentCoordinate = currentUserCoordinate,
              let searchCoordinate = searchUserCoordinate else {
            distance = "Unable to calculate distance."
            return
        }

        let currentLocation = CLLocation(latitude: currentCoordinate.latitude, longitude: currentCoordinate.longitude)
        let searchLocation = CLLocation(latitude: searchCoordinate.latitude, longitude: searchCoordinate.longitude)
        let distanceInMeters = currentLocation.distance(from: searchLocation)
        let distanceInMiles = distanceInMeters / 1609.34 // Conversion factor from meters to miles

        // Format the distance as a string
        distance = String(format: "%.2f miles", distanceInMiles)

        // Compare with maxTravelDistance
        if let maxTravel = maxTravelDistance {
            if maxTravel == 0 || distanceInMiles <= maxTravel {
                distanceColor = Color(hex: 0xf35a7d) // Matches preference
                preferenceText = "(matches preference)"
            } else {
                distanceColor = Color(hex: 0x0ad7d1) // Does not match preference
                preferenceText = "(does not match preference)"
            }
        } else {
            distanceColor = .gray // No maxTravelDistance specified
            preferenceText = nil
        }
        print("Calculated distance: \(distance)")
    }
}
