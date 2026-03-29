//
//  Landmark.swift
//  NailConnect
//
//  Created by Keith Nguyen.
//

import Foundation
import MapKit

struct Landmark: Identifiable {
    let id = UUID()
    let placemark: MKPlacemark
    let name: String
}
