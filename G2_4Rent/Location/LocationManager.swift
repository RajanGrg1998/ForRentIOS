//
//  LocationManager.swift
//  Rajan_Plants
//
//  Created by Rajan Gurungq on 2024-10-30.
//

import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()

    private let locationManager = CLLocationManager()
    private let geoCoder = CLGeocoder()
    private var locationCompletion: ((CLLocation) -> Void)?
    private var geocodeCompletion: ((CLLocation?) -> Void)?

    override private init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        requestLocationPermission()
    }

    private func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func fetchCurrentLocation(completion: @escaping (CLLocation) -> Void) {
        locationCompletion = completion
        locationManager.startUpdatingLocation()
    }

    func performForwardGeocoding(address: String, completion: @escaping (CLLocation?) -> Void) {
        geocodeCompletion = completion
        geoCoder.geocodeAddressString(address) { placemarks, error in
            if let location = placemarks?.first?.location {
                completion(location)
            } else {
                print("Forward geocoding failed: \(error?.localizedDescription ?? "No error info")")
                completion(nil)
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationCompletion?(location)
            locationCompletion = nil
            locationManager.stopUpdatingLocation()
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            print("Location access permitted")
        case .denied, .restricted:
            print("Location access denied or restricted")
        case .notDetermined:
            print("Location access not determined")
            requestLocationPermission()
        @unknown default:
            print("Unknown location authorization status")
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to update location: \(error.localizedDescription)")
        locationCompletion = nil
    }
}
