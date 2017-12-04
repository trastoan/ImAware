# ImAware

[![CI Status](http://img.shields.io/travis/trastoan/ImAware.svg?style=flat)](https://travis-ci.org/trastoan/ImAware)
[![Version](https://img.shields.io/cocoapods/v/ImAware.svg?style=flat)](http://cocoapods.org/pods/ImAware)
[![License](https://img.shields.io/cocoapods/l/ImAware.svg?style=flat)](http://cocoapods.org/pods/ImAware)
[![Platform](https://img.shields.io/cocoapods/p/ImAware.svg?style=flat)](http://cocoapods.org/pods/ImAware)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

ImAware is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ImAware'
```
## Example

### Getting current Hardware context

```swift
//Return battery level as a Float
let batteryLevel = Snapshot.hardware.batteryLevel
//Returns a Bool to indicate phones plugged in or not
let headphoneOn = Snapshot.hardware.headphonetPluggedIn
//Returns brightness level as a float
let brightness = Snapshot.hardware.screenBrightness
//Returns a Bool indicating Low Power Mode state
let powerModeOn = Snapshot.hardware.powerModeEnabled
//Return a list of connected hardware
let connectedAcessories = Snapshot.hardware.connectedAcessories
//Returnss a % of free space in the system
let availableSpace = Snapshot.hardware.availableSpace
```
### Getting current user location context
```swift
Snapshot.location.getUserCurrentLocation(accuracy: .room) { (location, error) in
    guard let userLocation = location else{
        print(error?.localizedDescription)
        return
    }
}
```
### Getting current user nearby adresses
```swift
Snapshot.location.getNearbyPlaces { (placemarks) in
    guard let userNearbyAdresses = placemarks else {
        return
    }
}
```


### Getting current user activity context
```swift
Snapshot.activity.getCurrentUserActivity { (activityType) in
    print(activityType.rawValue)
}
```
### Observing user Hardware context
```swift
//You can observe a single sensor
Observer.hardware.observeSensor(sensor: .batteryLevel, withInterval: 100) { (value, error) in
    guard let batteryLevel = value as? Float else { return }
    print("A bateria possui \(batteryLevel)% de carga")
}

//Or multiple
Observer.hardware.observeMultipleSensors(sensors: [.batteryLevel,.headphoneConnected], withInterval: 100) { (values, error) in
    guard let batteryLevel = values[.batteryLevel] as? Float, let headphoneStatus = values[.headphoneConnected] as? Bool else { return }

    print("Você possui \(batteryLevel)% de bateria")
    print("Os headphones estão \(headphoneStatus ? "plugados" : "desplugados")")
}
```

### Observing user Location context
```swift
//Register a fence
Observer.location.createFence(withLatitude: 37.33170, longitude: -122.030237, radius: 200, identifier: "FenceWithMessage", fenceType: .uponEnter, payload: ["Message" : "I've entered Apple"])
//Create a class that subscribes to RegionChange protocol to receive fence updates
class locationObserver: RegionChange {
    var aware = AwareLocation.shared

    init() {
        aware.fenceDelegate = self
    }

    func fenceStatusDidChange(forFence fence: LocationFence) {
        if fence.identifier == "FenceWithMessage" {
        guard let fencePayload = fence.payload else { return }
        guard let message = fencePayload["Message"] as? String else { return }
            print(message)
        }
    }
}

//Stop monitoring fence
Observer.location.stopMonitoringFence(withIdentifier: "FenceWithMessage")
```
## Author

Yuri Frota , yurisaboiaf@gmail.com

## License

ImAware is available under the MIT license. See the LICENSE file for more info.
