//
//  LocationManager.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 4/7/22.
//

import CoreLocation

public class LocationManager: NSObject, CLLocationManagerDelegate {
    
    private let manager = CLLocationManager()
    
    public var currentCoordiante: CLLocationCoordinate2D? = nil
    public static let shared = LocationManager()
    
    public override init() {
        super.init()
        configure()
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location: CLLocationCoordinate2D = manager.location?.coordinate {
            currentCoordiante = location
        }
        manager.stopUpdatingLocation()
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
        print("Tracker Location Manager Error")
        print("\(error)")
    }
    
    private func configure() {
        if manager.delegate == nil {
            manager.delegate = self
        }
        manager.requestAlwaysAuthorization()
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

}
