//
//  HardwareObserver.swift
//  Aware
//
//  Created by Yuri Saboia Felix Frota on 05/11/17.
//

import Foundation

enum Sensor {
    case screenBrightness
    case headphoneConnected
    case batteryLevel
    case availableSpace
    case powerModeEnabled
    case connectedAcessories
}

@available(iOS 10.0, *)
class HardwareObserver {
    private var timers = [SensorTimer]()
    private let hardwareContext = HardwareContext()
    
    func observeSensor(sensor: Sensor, withInterval interval : TimeInterval, completion : @escaping (Any?, Error?) -> ()) {
        let timer =  SensorTimer(timeInterval: interval, repeats: true, sensors: [sensor], block: { (timer) in
            completion(self.getSensorData(sensor: sensor), nil)
        })
        timer.timer.fire()
        timers.append(timer)
    }
    
    func observeMultipleSensors(sensors: [Sensor], withInterval interval : TimeInterval, completion : @escaping ([Sensor : Any?], Error?) -> ()) {
        let timer =  SensorTimer(timeInterval: interval, repeats: true, sensors: sensors, block: { (timer) in
            var data = [Sensor : Any?] ()
            for sensor in sensors {
                data[sensor] = self.getSensorData(sensor: sensor)
            }
            completion(data, nil)
        })
        timer.timer.fire()
        timers.append(timer)
    }
    
    
    func stopObserverForSensors(sensors : [Sensor]) {
        for timer in timers {
            for sensor in sensors {
                if timer.sensors.contains(sensor) {
                    timer.timer.invalidate()
                }
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
        case .screenBrightness:
            return hardwareContext.screenBrightness
        case .headphoneConnected:
            return hardwareContext.headphonetPluggedIn
        case .batteryLevel:
            return hardwareContext.batteryLevel ?? 0
        case .availableSpace:
            return hardwareContext.availableSpace
        case .powerModeEnabled:
            return hardwareContext.powerModeEnabled
        case .connectedAcessories:
            return hardwareContext.connectedAcessories
        }
    }
}



