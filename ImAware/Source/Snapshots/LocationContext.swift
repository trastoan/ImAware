//
//  LocationContext.swift
//  Aware
//
//  Created by Yuri Saboia Felix Frota on 30/08/17.
//  Copyright © 2017 Taskr. All rights reserved.
//

import Foundation
import CoreLocation

enum Accuracy {
    case country
    case city
    case neighborhood
    case house
    case room
    case navigation
}

enum BeaconStatus {
    case near
    case notInRange
    case far
}

class LocationContext : NSObject, CLLocationManagerDelegate, Context {
    
    internal var contextType : ContextType = .Location
    
    //Location Manager
    private var aware = AwareLocation.shared
    
    //Store the beacons Status
    var beaconsStatus : [(String ,BeaconStatus)]?
    
    /**
     Returns the user CLLocation within decided accuracy
     
     - Parameter accuracy: define the desired accuracy for your location
     
     - Returns : A CLLocation with the last user location
     */
    
    func getUserCurrentLocation(accuracy : Accuracy, completion : @escaping (CLLocation?, Error?) -> ()) {
        aware.requestUserLocation(accuracy: accuracy) { (location, error) in
            DispatchQueue.main.async {
                completion(location, error)
            }
        }
    }
    
    //Can't return the commercial place, should I use maps api?
    func getNearbyPlaces(completion : @escaping ([CLPlacemark]?) -> ()){
        getUserCurrentLocation(accuracy: .room) { (location, error) in
            let geocoder = CLGeocoder()
            if let location = location {
                geocoder.reverseGeocodeLocation(location, completionHandler: { (places, error) in
                    if error != nil {
                        completion(nil)
                    } else {
                        var result = [CLPlacemark]()
                        if let places = places {
                            for place in places {
                                if place.name != nil {
                                    result.append(place)
                                }
                            }
                        }
                        completion(result)
                    }
                })
            } else {
                completion(nil)
            }
        }
    }

    //Beacons will not be available on first version

}
