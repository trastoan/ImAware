//
//  LocationObserver.swift
//  Aware
//
//  Created by Yuri Saboia Felix Frota on 11/09/17.
//  Copyright © 2017 YuriFrota. All rights reserved.
//

import Foundation
import CoreLocation

class LocationObserver : NSObject {
    
    //Manager that deals with the on and off of
    let aware = AwareLocation.shared
    
    //Initialize CLLocation Manager and request user authorization to location
    override init() {
        super.init()
    }
    
    func createFence(withLatitude latitude : Double, longitude : Double, radius : Double, identifier : String, fenceType : FenceType, payload : [String : Any]) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let fence = LocationFence(radius: radius, location: location, type: fenceType, identifier: identifier, newFence: true, payload : payload)
        fence.startMonitoring(fence: fence)
    }
    
    func stopMonitoringFence(withIdentifier identifier : String) -> Bool{
        return LocationFence.removeFence(withIdentifier: identifier)
    }
    
    func pauseAllFenceMonitoration() {
        
    }
    
    func restartAllFencesMonitoration() {
        
    }
    
    func sendLocationDataToServer(withURL url : URL, HTTPMethod method : HTTPMethods, andHeaders headers : [String : String]?) {
        aware.startMonitoringLocation()
        let server = Server(url: url, httpMethod: method, headers : headers)
        aware.serverInfo = server
    }
    
    func stopSendingLocationDataToServer() {
        aware.stopUpdatingLocation()
        aware.serverInfo = nil
    }
}
