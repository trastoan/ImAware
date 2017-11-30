//
//  Aware.swift
//  Aware
//
//  Created by Yuri Saboia Felix Frota on 11/10/17.
//  Copyright © 2017 YuriFrota. All rights reserved.
//

import Foundation
import CoreLocation
import UserNotifications

public protocol RegionChange: class {
    func fenceStatusDidChange(forFence fence: LocationFence)
}

enum Frequency {
    case single
    case observe
}

open class AwareLocation: NSObject, CLLocationManagerDelegate {
    public static let locationManager = CLLocationManager()
    public static let shared = AwareLocation()
    
    private var frequency: Frequency?
    private var requestError: LocationError?
    private var currentLocation: CLLocation?
    private var group = DispatchGroup()
    private var observeLocation = false
    public var serverInfo: Server?
    
    weak var speedDelegate: ActivityLocation? {
        didSet {
            observeLocation = true
        }
    }
    
    weak public var fenceDelegate: RegionChange?
    
    private override init() {
        super.init()
        AwareLocation.locationManager.delegate = self
        observeLocation = UserDefaults.standard.monitoringBackgroundLocation
    }
    
    func startManagingLocation() -> Error? {
        return !checkAuthorization() ? LocationError.serviceNotAvailable : nil
    }
    
    func beginLocationUpdate() {
        if speedDelegate != nil {
            AwareLocation.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
        AwareLocation.locationManager.startUpdatingLocation()
    }
    
    func startMonitoringLocation() {
        observeLocation = true
        AwareLocation.locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func stopUpdatingLocation() {
        if speedDelegate == nil && !observeLocation {
            AwareLocation.locationManager.stopUpdatingLocation()
        }
    }
    
    func pauseMonitoringFences() {
        if AwareLocation.locationManager.monitoredRegions.count > 0 {
            guard let fences = UserDefaults.standard.geoFences else { return }
            _ = fences.map {AwareLocation.locationManager.stopMonitoring(for: $0.region)}
        }
    }
    
    func restartMonitoringFences() {
        if AwareLocation.locationManager.monitoredRegions.count < 0 {
            if let location = AwareLocation.locationManager.location {
                LocationFence.updateMonitoredFences(userLocation: location)
            } else {
                guard let fences = UserDefaults.standard.geoFences else { return }
                _ = fences.map {AwareLocation.locationManager.startMonitoring(for: $0.region)}
            }
        }
    }
    
    func sendLocationToServer(withLocation location: CLLocation) {
        guard let server = serverInfo else { return }
        guard let data = location.toJSONData() else { return }
        
        let request = NSMutableURLRequest(url: server.url)
        request.httpMethod = server.httpMethod.rawValue
        request.httpBody = data
        request.allHTTPHeaderFields = server.headers
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest) { (_, _, _) in
            
        }
        task.resume()
    }
    
    func handleFence(forRegion region: CLRegion) {
        let identifier = region.identifier
        guard let fences = UserDefaults.standard.geoFences else { return }
        let fenceIndex = fences.index { $0.identifier == identifier }
        
        guard let index = fenceIndex else {return}
        if let fence = fences[index] as LocationFence? {
            fenceDelegate?.fenceStatusDidChange(forFence: fence)
        }
    }
    
    func requestUserLocation(accuracy: Accuracy, completion: @escaping (CLLocation?, Error?) -> Void) {
        if !checkAuthorization() {
            DispatchQueue.main.async {
                completion(nil, LocationError.serviceNotAvailable)
                return
            }
        }
        
        changeAccuracy(accuracy: accuracy)
        frequency = .single
        AwareLocation.locationManager.startUpdatingLocation()
        
        //Using Dispatch group to exclude the need of delegate implementation from the developer
        group.enter()
        //Insert timeout on group
        group.notify(queue: .main) {
            completion(self.currentLocation, self.requestError)
            //Not best for energy consumption
            AwareLocation.locationManager.stopUpdatingLocation()
            self.frequency = nil
        }
    }
    
    func checkAuthorization() -> Bool {
        let status = CLLocationManager.authorizationStatus()
        if status != .authorizedAlways && status != .authorizedWhenInUse {
            AwareLocation.locationManager.requestAlwaysAuthorization()
        }
        
        return CLLocationManager.authorizationStatus() != .authorizedAlways ? false : true
    }
    
    /**
     Changes the accuracy for location manager initiation
     
     - Parameter accuracy: define the desired accuracy for your location
     */
    private func changeAccuracy(accuracy: Accuracy) {
        switch accuracy {
        case .country:
            AwareLocation.locationManager.desiredAccuracy = 10000.0
        case .city:
            AwareLocation.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        case .neighborhood:
            AwareLocation.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        case .house:
            AwareLocation.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        case .room:
            AwareLocation.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        case .navigation:
            AwareLocation.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        }
    }
    
    //Fences
    
    func startMonitoringFence(for region: CLRegion) {
        AwareLocation.locationManager.startMonitoring(for: region)
    }
    
    func stopMonitoringFence(for region: CLRegion) {
        AwareLocation.locationManager.stopMonitoring(for: region)
    }
    
    func getMonitoredRegions() -> Set<CLRegion> {
        return AwareLocation.locationManager.monitoredRegions
    }
}

// MARK: Location Delegates

extension AwareLocation {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last {
            if observeLocation {
                sendLocationToServer(withLocation: location)
            }
            if speedDelegate != nil {
                speedDelegate!.currentSpeed(speed: location.speed)
            }
        }
        
        self.currentLocation = locations.last
        requestError = nil
        if frequency == .single {
            group.leave()
            frequency = nil
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        handleFence(forRegion: region)
    }
    
    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        handleFence(forRegion: region)
    }
    
    //Error Handling delegates
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        requestError = .serviceNotAvailable
        group.leave()
    }
    
    public func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        requestError = .monitoringError
        group.leave()
    }
}

