//
//  Extensions.swift
//  Aware
//
//  Created by Yuri Saboia Felix Frota on 18/10/17.
//  Copyright © 2017 YuriFrota. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocationManager{
    func stopAllLocationUpdates(){
        self.stopUpdatingHeading()
        self.stopMonitoringSignificantLocationChanges()
        self.disallowDeferredLocationUpdates()
    }
    
    func stopMonitoringAllRegions() {
        self.monitoredRegions.forEach{self.stopMonitoring(for: $0)}
    }
}


import CoreLocation

extension UserDefaults {
    var geoFences : [LocationFence]? {
        get {
            if let data = object(forKey: PreferenceKey.fence) as? Data {
                return NSKeyedUnarchiver.unarchiveObject(with: data) as? [LocationFence]
            }
            return nil
        }
        set {
            if let _ = newValue {
                setValue(NSKeyedArchiver.archivedData(withRootObject: newValue!), forKeyPath: PreferenceKey.fence)
            }
        }
    }
    
    var monitoringBackgroundLocation : Bool {
        get {
            return bool(forKey: PreferenceKey.monitoring)
        }
        
        set {
            setValue(newValue, forKey: PreferenceKey.monitoring)
        }
    }
}

extension CLLocation {
    func toJSONData() -> Data? {
        let stamp = self.timestamp.timeIntervalSince1970
        let locationData = ["location" :
            ["speed": self.speed,
             "latitude" : self.coordinate.latitude,
             "longitude" : self.coordinate.longitude,
             "altitude" : self.altitude,
             "horizontalAccuracy" : self.horizontalAccuracy,
             "verticalAccuracy" : self.verticalAccuracy,
             "course" : self.course,
             "timeStamp" : stamp,
             "floor" : self.floor?.level ?? 0]]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: locationData, options: .prettyPrinted)
            return jsonData
        } catch {
            return nil
        }
    }
}

