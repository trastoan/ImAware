//
//  LocationFence.swift
//  Aware
//
//  Created by Yuri Saboia Felix Frota on 11/10/17.
//  Copyright © 2017 YuriFrota. All rights reserved.
//

import Foundation
import CoreLocation

protocol ObserverAction {
    func observerDidTrigger()
}

struct PreferenceKey {
    static let fence = "Fence"
    static let monitoring = "Monitoring Location"
}

public enum FenceType: String {
    case uponEnter = "Upon Enter"
    case uponExit = "Upon Exit"
    case uponEnterAndExit = "Upon enter and exit"
}

open class LocationFence: NSObject, NSCoding {
    private var aware = AwareLocation.shared
    
    var radius: Double
    var payload: [String: Any]?
    var location: CLLocation
    var coordinate: CLLocationCoordinate2D {
        return location.coordinate
    }
    
    var newFence: Bool
    
    var type: FenceType
    var identifier: String
    
    var region: CLCircularRegion {
        let region = CLCircularRegion(center: coordinate, radius: radius, identifier: identifier)
        region.notifyOnEntry = (type == .uponEnter || type == .uponEnterAndExit)
        region.notifyOnExit = (type == .uponExit  || type == .uponEnterAndExit)
        
        return region
    }
    
    override open var description: String {
        return "\(identifier) : latitude : \(self.location.coordinate.latitude) , longitude : \(self.location.coordinate.latitude) "
    }
    
    public init(radius: Double, location: CLLocation, type: FenceType, identifier: String = NSUUID().uuidString, newFence: Bool = true, payload: [String: Any]?) {
        self.radius = radius
        self.location = location
        self.type = type
        self.identifier = identifier
        self.newFence = newFence
        self.payload = payload
    }
    
    public func encode(with aCoder: NSCoder) {
        let typeSt = type.rawValue
        aCoder.encode(self.radius, forKey: "radius")
        aCoder.encode(typeSt, forKey: "fenceType")
        aCoder.encode(self.identifier, forKey: "identifier")
        aCoder.encode(self.coordinate.latitude, forKey: "latitude")
        aCoder.encode(self.coordinate.longitude, forKey: "longitude")
        aCoder.encode(self.location.altitude, forKey: "altitude")
        if let payload = self.payload {
            aCoder.encode(payload, forKey: "payload")
        }
    }
    
    required convenience public init?(coder aDecoder: NSCoder) {
        guard let typeValue = aDecoder.decodeObject(forKey: "fenceType") as? String,
            let identifier = aDecoder.decodeObject(forKey: "identifier") as? String
            else {return nil}
        
        let location = CLLocation(latitude: aDecoder.decodeDouble(forKey: "latitude"), longitude: aDecoder.decodeDouble(forKey: "longitude"))
        let radius = aDecoder.decodeDouble(forKey: "radius")
        
        guard let payload = aDecoder.decodeObject(forKey: "payload") as? [String: Any] else {return nil}
        
        var type: FenceType
        
        switch typeValue {
        case FenceType.uponEnter.rawValue:
            type = .uponEnter
        case FenceType.uponExit.rawValue:
            type = .uponExit
        default :
            type = .uponEnter
        }
        
        self.init(
            radius: radius,
            location: location,
            type: type,
            identifier: identifier,
            payload: payload
        )
        
    }
    
    //Fence monitoring
    
    public func startMonitoring(fence: LocationFence) {
        if !(CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self)) {
            print("Not available on this device")
            return
        }
        
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            AwareLocation.locationManager.requestAlwaysAuthorization()
        }
        
        if self.newFence {
            if var fences = UserDefaults.standard.geoFences {
                fences.append(self)
                UserDefaults.standard.geoFences = fences
            } else {
                UserDefaults.standard.geoFences = [self]
            }
        }
        
        let region = fence.region
        aware.startMonitoringFence(for: region)
    }
    
    public func stopMonitoring(fence: LocationFence) {
        for region in aware.getMonitoredRegions() {
            guard let circularRegion = region as? CLCircularRegion, circularRegion.identifier == fence.identifier
                else { continue }
            aware.stopMonitoringFence(for: region)
        }
    }
    
    static public func removeFence(withIdentifier identifier: String) -> Bool {
        if var fences = UserDefaults.standard.geoFences {
            for index in 0 ..< fences.count where fences[index].identifier == identifier {
                let fence = fences[index]
                fence.stopMonitoring(fence: fence)
                fences.remove(at: index)
                UserDefaults.standard.geoFences = fences
                return true
            }
        }
        return false
    }
    
    static public func nearbyFences(inFences fences: [LocationFence], proximity: CLLocationDistance, fromLocation location: CLLocation) -> [LocationFence] {
        var i = 1.0
        var nearbyFences = [LocationFence]()
        if fences.count >= 19 {
            nearbyFences = fences.filter {$0.location.distance(from: location) < proximity}
            while nearbyFences.count >= 19 {
                nearbyFences = fences.filter {$0.location.distance(from: location) < proximity - (proximity/1000) * i}
                i += 3
            }
            return nearbyFences
        }
        return fences
    }
    
    static func containsRegion(region: CLRegion, inFences fences: [LocationFence]) -> Bool {
        var contains = false
        for fence in fences where fence.region.identifier == region.identifier {
            contains = true
        }
        return contains
    }
    
    static public func getFences() -> [LocationFence] {
        if let fences = UserDefaults.standard.geoFences {
            return fences
        }
        return [LocationFence]()
    }
    
    static public func updateMonitoredFences(userLocation: CLLocation) {
        if let fences = UserDefaults.standard.geoFences {
            if fences.count > 19 {
                let nearbyFences = LocationFence.nearbyFences(inFences: fences, proximity: 50000, fromLocation: userLocation)
                let aware = AwareLocation.shared
                let monitored = aware.getMonitoredRegions()
                for region in monitored {
                    if !LocationFence.containsRegion(region: region, inFences: nearbyFences) {
                        aware.stopMonitoringFence(for: region)
                    }
                }
            }
        }
    }
}
