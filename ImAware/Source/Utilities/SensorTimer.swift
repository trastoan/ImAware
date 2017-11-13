//
//  SensorTimer.swift
//  Aware
//
//  Created by Yuri Saboia Felix Frota on 06/11/17.
//  Copyright © 2017 YuriFrota. All rights reserved.
//

import Foundation

@available(iOS 10.0, *)
class SensorTimer : NSObject {
    var sensors : [Sensor]
    var timer : Timer
    
    init(timeInterval : TimeInterval, repeats : Bool, sensors : [Sensor], block : @escaping (Timer) -> Swift.Void) {
        self.timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: repeats, block: block)
        self.sensors = sensors
    }
}
