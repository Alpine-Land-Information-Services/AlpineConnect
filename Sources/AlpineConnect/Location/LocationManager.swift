//
//  LocationManager.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 4/7/22.
//

import CoreLocation

//public class LocationManager: NSObject, CLLocationManagerDelegate {
//
//    private let manager = CLLocationManager()
//
//    public var lastLocation: CLLocation? = nil
//    public static let shared = LocationManager()
//
//    public override init() {
//        super.init()
//        configure()
//    }
//
//    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let location = locations.last {
//            lastLocation = location
//        }
////        manager.stopUpdatingLocation()
//    }
//
//    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
//        print("Tracker Location Manager Error")
//        print("\(error)")
//    }
//
//    private func configure() {
//        manager.requestAlwaysAuthorization()
//        manager.requestWhenInUseAuthorization()
//        if CLLocationManager.locationServicesEnabled() {
//            manager.delegate = self
//            manager.distanceFilter = 100
//            manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
//            manager.startUpdatingLocation()
////            manager.startMonitoringSignificantLocationChanges()
//        }
//    }
//
//}
