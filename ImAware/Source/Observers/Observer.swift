//
//  Observer.swift
//  ImAware
//
//  Created by Yuri Saboia Felix Frota on 13/11/17.
//

import Foundation

@available(iOS 10.0, *)
public struct Observer {
    var hardware = HardwareObserver()
    var location = LocationObserver()
}
