//
//  Snapshot.swift
//  ImAware
//
//  Created by Yuri Saboia Felix Frota on 13/11/17.
//

import Foundation

public struct Snapshot {
    public var hardware = HardwareContext()
    public var location = LocationContext()
    public var activity = ActivityContext()
    
    public init() {}
}
