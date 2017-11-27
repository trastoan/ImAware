//
//  LocationContext.swift
//  Aware
//
//  Created by Yuri Saboia Felix Frota on 30/08/17.
//  Copyright © 2017 Taskr. All rights reserved.
//

import Foundation
import CoreLocation

public enum Accuracy {
    case country
    case city
    case neighborhood
    case house
    case room
    case navigation
}

open class LocationContext: NSObject, CLLocationManagerDelegate, Context {
    
    internal var contextType: ContextType = .location
    
    //Location Manager
    private var aware = AwareLocation.shared
    
    /**
     Returns the user CLLocation within decided accuracy
     
     - Parameter accuracy: define the desired accuracy for your location
     
     - Returns : A CLLocation with the last user location
     */
    
    public func getUserCurrentLocation(accuracy: Accuracy, completion: @escaping (CLLocation?, Error?) -> Void) {
        aware.requestUserLocation(accuracy: accuracy) { (location, error) in
            DispatchQueue.main.async {
                completion(location, error)
            }
        }
    }
    
    //Can't return the commercial place, only adresses
    public func getNearbyPlaces(completion: @escaping ([CLPlacemark]?) -> Void) {
        getUserCurrentLocation(accuracy: .room) { (location, error) in
            let geocoder = CLGeocoder()
            if let location = location {
                geocoder.reverseGeocodeLocation(location, completionHandler: { (places, error) in
                    if error != nil {
                        completion(nil)
                    } else {
                        var result = [CLPlacemark]()
                        if let places = places {
                            for place in places where place.name != nil {
                                result.append(place)
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

