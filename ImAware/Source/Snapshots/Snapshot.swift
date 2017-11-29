//
//  Snapshot.swift
//  ImAware
//
//  Created by Yuri Saboia Felix Frota on 13/11/17.
//

import Foundation

public struct Snapshot {
    public static var hardware = HardwareContext()
    public static var location = LocationContext()
    public static var activity = ActivityContext()
    
    public init() {}
}
