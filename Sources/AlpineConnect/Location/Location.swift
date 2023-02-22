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
    @Published public var centerCoordinate: CLLocationCoordinate2D? // in projection, 26710
    
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
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()
        
        manager.headingFilter = 10
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
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.newLocation(self!.lastLocation!)
            }
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if let lastHeading = manager.heading {
            self.lastHeading = lastHeading
            delegate?.newHeading(lastHeading)
            degrees = -1 * lastHeading.magneticHeading
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
    func newLocation(_ newValue: CLLocation)
    func newHeading(_ newHeading: CLHeading)
}


extension LocationChangeDelegate {
    public func newHeading(_ newHeading: CLHeading) {
        //default realization, so inheritors be able not to implement the method
    }
}
