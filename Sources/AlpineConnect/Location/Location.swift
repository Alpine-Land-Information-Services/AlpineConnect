//
//  Location.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 9/2/22.
//

import CoreLocation

open class Location: NSObject, CLLocationManagerDelegate, ObservableObject {
    
    public static let shared = Location()
    
    private let manager = CLLocationManager()
    public weak var delegate: LocationChangeDelegate?
    
    var headingOrientation: CLDeviceOrientation {
        get { manager.headingOrientation }
        set { manager.headingOrientation = newValue}
    }
    var isWorkind = false
    
    @Published public var lastLocation: CLLocation?                 // in degrees, 4326
    @Published public var lastHeading: CLHeading?
    @Published public var centerCoordinate: CLLocationCoordinate2D? // in projection, 26710
    
    public func start() {
        if isWorkind { return }
        isWorkind = true
        manager.requestWhenInUseAuthorization()
        manager.delegate = self
        manager.requestLocation()
//        manager.allowsBackgroundLocationUpdates = true
        manager.distanceFilter = 5
//        manager.showsBackgroundLocationIndicator = true
//        manager.pausesLocationUpdatesAutomatically = false
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()
        
        manager.headingFilter = 15
        manager.startUpdatingHeading()
    }

    func stop() {
        manager.stopUpdatingLocation()
        manager.stopUpdatingHeading()
        isWorkind = false
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            lastLocation = location
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.newLocation(self!.lastLocation!)
            }
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if let lastHeading = manager.heading {
            self.lastHeading = lastHeading
            delegate?.newHeading(lastHeading)
        }
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
        print("Location Manager Error: \(error)")
    }
}

public protocol LocationChangeDelegate: AnyObject {
    func newLocation(_ newValue: CLLocation)
    func newHeading(_ newHeading: CLHeading)
}

extension LocationChangeDelegate {
    public func newHeading(_ newHeading: CLHeading) {
        //default realization, so inheritors be able not to implement the method
    }
}
