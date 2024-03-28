//
//  LocationManager.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 6/28/23.
//

import CoreLocation
import UIKit
import SwiftUI

public class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    
    public static let shared = LocationManager()
    
    private let manager = CLLocationManager()
    
    var headingOrientation: CLDeviceOrientation {
        get { manager.headingOrientation }
        set { manager.headingOrientation = newValue }
    }
    
    var isActive = false
    
    @Published public var lastLocation: CLLocation? // in degrees, 4326
    @Published public var lastHeading: CLHeading?
    
    @Published public var autorizationStatus: CLAuthorizationStatus
    
    public var locationUsers = [UUID: String]()
    
    public var degrees: Double = .zero {
        didSet {
            objectWillChange.send()
        }
    }
    
    private override init() {
        autorizationStatus = manager.authorizationStatus
        
        super.init()
        start()
    }
    
    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        withAnimation {
            autorizationStatus = manager.authorizationStatus
        }
    }
    
    func start() {
        guard !isActive else { return }
        isActive = true

        manager.delegate = self
        manager.requestLocation()
        manager.allowsBackgroundLocationUpdates = true
        manager.distanceFilter = 5
        manager.showsBackgroundLocationIndicator = true
        manager.pausesLocationUpdatesAutomatically = false
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.activityType = .otherNavigation
        manager.startUpdatingLocation()
        
        manager.headingFilter = 5
        manager.startUpdatingHeading()
    }
    
    public func resume() {
        guard !isActive else { return }
        manager.startUpdatingLocation()
        manager.startUpdatingHeading()
        isActive = true
    }

    public func stop() {
        manager.stopUpdatingLocation()
        manager.stopUpdatingHeading()
        isActive = false
    }
    
    public func stopIfNoUsers() {
        guard locationUsers.isEmpty else { return }
        stop()
    }
    
    public func addLocationUser(id: UUID, description: String) {
        locationUsers[id] = description
    }
    
    public func removeLocationUser(with id: UUID) {
        locationUsers.removeValue(forKey: id)
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            lastLocation = location
            NotificationCenter.default.post(Notification(name: .AC_UserLocationUpdate, object: location))
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        DispatchQueue.main.async { [self] in
            if let heading = manager.heading {
                lastHeading = heading
                degrees = -1 * heading.magneticHeading
            }
        }
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    public func setDeviceOrientation(_ orientation: UIDeviceOrientation) {
        switch orientation {
        case .portrait:
            manager.headingOrientation = CLDeviceOrientation.portrait
        case .portraitUpsideDown:
            manager.headingOrientation = CLDeviceOrientation.portraitUpsideDown
        case .landscapeLeft:
            manager.headingOrientation = CLDeviceOrientation.landscapeLeft
        case .landscapeRight:
            manager.headingOrientation = CLDeviceOrientation.landscapeRight
        default:
            break
        }
    }

    public func setDeviceOrientation(_ orientation: UIInterfaceOrientation) {
        switch orientation {
        case .portrait:
            manager.headingOrientation = CLDeviceOrientation.portrait
        case .portraitUpsideDown:
            manager.headingOrientation = CLDeviceOrientation.portraitUpsideDown
        case .landscapeLeft:
            manager.headingOrientation = CLDeviceOrientation.landscapeLeft
        case .landscapeRight:
            manager.headingOrientation = CLDeviceOrientation.landscapeRight
        default:
            break
        }
    }
}
