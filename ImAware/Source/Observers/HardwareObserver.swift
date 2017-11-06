//
//  HardwareObserver.swift
//  Aware
//
//  Created by Yuri Saboia Felix Frota on 05/11/17.
//

import Foundation

enum Sensor {
    case ScreenBrightness
    case HeadphoneConnected
    case BatteryLevel
    case AvailableSpace
    case PowerModeEnabled
    case ConnectedAcessories
}

@available(iOS 10.0, *)
class HardwareObserver {
    var timers = [SensorTimer]()
    let hardwareContext = HardwareContext()
    
    func observeSensor(sensor: Sensor, withInterval interval : TimeInterval, completion : @escaping (Any?, Error?) -> ()) {
        let timer =  SensorTimer(timeInterval: interval, repeats: true, sensor: sensor, block: { (timer) in
            completion(self.getSensorData(sensor: sensor), nil)
        })
        timer.timer.fire()
        timers.append(timer)
    }
    
    func stopObserverForSensors(sensors : [Sensor]) {
        for timer in timers {
            if sensors.contains(timer.sensor) {
                timer.timer.invalidate()
            }
        }
    }
    
    func stopAllObservers() {
        for timer in timers {
            timer.timer.invalidate()
        }
    }
    
    
    private func getSensorData(sensor : Sensor) -> Any {
        switch sensor {
        case .ScreenBrightness:
            return hardwareContext.screenBrightness
        case .HeadphoneConnected:
            return hardwareContext.headphonetPluggedIn
        case .BatteryLevel:
            return hardwareContext.batteryLevel ?? 0
        case .AvailableSpace:
            return hardwareContext.availableSpace
        case .PowerModeEnabled:
            return hardwareContext.powerModeEnabled
        case .ConnectedAcessories:
            return hardwareContext.connectedAcessories
        }
    }
}



