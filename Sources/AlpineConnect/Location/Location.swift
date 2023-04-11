//
//  Location.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 9/2/22.
//

import CoreLocation
import UIKit

open class Location: NSObject, CLLocationManagerDelegate, ObservableObject {
    
    public static let shared = Location()
    
    private let manager = CLLocationManager()
    public weak var delegate: LocationChangeDelegate?
    
    var headingOrientation: CLDeviceOrientation {
        get { manager.headingOrientation }
        set { manager.headingOrientation = newValue}
    }
    
    var isWorking = false
    
    @Published public var lastLocation: CLLocation?                 // in degrees, 4326
    @Published public var lastHeading: CLHeading?
    //TODO: is this needed?
    @Published public var centerCoordinate: CLLocationCoordinate2D? // in projection, 26710
    
    public var locationUsers = [UUID: String]()
    
    public var degrees: Double = .zero {
        didSet {
            objectWillChange.send()
        }
    }
    
    public func start() {
        if isWorking { return }
        isWorking = true
        manager.requestWhenInUseAuthorization()
        manager.delegate = self
        manager.requestLocation()
        manager.allowsBackgroundLocationUpdates = true
        manager.distanceFilter = 5
        manager.showsBackgroundLocationIndicator = true
        manager.pausesLocationUpdatesAutomatically = false
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.activityType = .otherNavigation
        manager.startUpdatingLocation()
        
        manager.headingFilter = 10
        manager.startUpdatingHeading()
    }
    
    func resume() {
        guard !isWorking else {
            return
        }
        isWorking = true
        manager.startUpdatingLocation()
        manager.startUpdatingHeading()
    }

    func stop() {
        manager.stopUpdatingLocation()
        manager.stopUpdatingHeading()
        isWorking = false
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            lastLocation = location
            NotificationCenter.default.post(Notification(name: Notification.Name("tempLocationUpdate"), object: location))
            DispatchQueue.main.async { [weak self] in
                if let lastLocation = self?.lastLocation {
                    self?.delegate?.newLocation(lastLocation)
                }
            }
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if let heading = manager.heading {
            lastHeading = heading
            DispatchQueue.main.async { [weak self] in
                if let lastHeading = self?.lastHeading,
                   let lastLocation = self?.lastLocation
                {
                    self?.delegate?.newHeading(lastHeading, lastLocation)
                }
            }
            degrees = -1 * heading.magneticHeading
        }
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
        print("Location Manager Error: \(error)")
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


public protocol LocationChangeDelegate: AnyObject {
    func newLocation(_ newLocation: CLLocation)
    func newHeading(_ newHeading: CLHeading, _ newLocation: CLLocation)
}


extension LocationChangeDelegate {
    public func newHeading(_ newHeading: CLHeading, _ newLocation: CLLocation) {
        //default realization, so inheritors be able not to implement the method
    }
}
