//
//  MapView.swift
//  NailConnect
//
//  Created by Keith Nguyen.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    var landmarks: [Landmark]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.removeAnnotations(mapView.annotations)

        for landmark in landmarks {
            let annotation = MKPointAnnotation()
            annotation.coordinate = landmark.placemark.coordinate
            annotation.title = landmark.name
            mapView.addAnnotation(annotation)
        }

        if let firstCoordinate = landmarks.first?.placemark.coordinate {
            let region = MKCoordinateRegion(
                center: firstCoordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
            mapView.setRegion(region, animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    class Coordinator: NSObject, MKMapViewDelegate {}
}
