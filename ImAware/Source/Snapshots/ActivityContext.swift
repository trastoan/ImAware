//
//  ActivityContext.swift
//  Aware
//
//  Created by Yuri Saboia Felix Frota on 29/08/17.
//  Code based on KWC-team 2015
//  Copyright © 2017 Taskr. All rights reserved.
//
import UIKit
import CoreMotion
import CoreLocation

public enum ActivityType : String {
    case running = "Running"
    case walking = "Walking"
    case driving = "Driving"
    case standingBy = "Standing By"
}

protocol ActivityLocation: class {
    func currentSpeed(speed: Double)
}

open class ActivityContext: NSObject, Context, ActivityLocation {
    
    private lazy var motionManager = CMMotionManager()
    
    internal var contextType: ContextType = .activity
    
    //Needs Refactor ******
    private var acData: [[Double]] = []    // accelerometer data
    private var acDataFiltered: [[Double]] = [] //filtered data
    private var speedData: [Double] = [] // speed data
    
    private var count: Int = 1
    
    private let acUpdateInterval = 0.02 // sampling rate
    private let cycleInterval = 3.0 // how many sec for a cycle
    private let ALPHA = 0.0314 // the alpha in the filter
    private var lastOfLastCycle: [Double] = []
    
    private var aware = AwareLocation.shared
    
    override init() {
        super.init()
    }
    
    internal func currentSpeed(speed: Double) {
        self.speedData.append(speed)
    }
    
    //Needs Refactor ******
    public func getCurrentUserActivity(completion: @escaping (ActivityType) -> Void) {
        aware.beginLocationUpdate()
        let countMax = self.cycleInterval / self.acUpdateInterval
        
        motionManager.accelerometerUpdateInterval = self.acUpdateInterval
        
        if motionManager.isAccelerometerAvailable {
            let queue = OperationQueue.main
            motionManager.startAccelerometerUpdates(to: queue, withHandler: { (data, _) in
                guard let data = data else {
                    return
                }
                
                let thisAcData = [data.acceleration.x, data.acceleration.y, data.acceleration.z]
                self.acData.append(thisAcData)
                
                //Filter Data
                var thisAcDataFiltered: [Double] = []
                var lastAcDataFiltered: [Double] = []
                
                if self.acDataFiltered.count == 0 {
                    lastAcDataFiltered = self.lastOfLastCycle.count != 0 ? self.lastOfLastCycle : [0, 0, 0]
                } else { //Mid Cycle
                    lastAcDataFiltered = self.acDataFiltered[self.acDataFiltered.endIndex - 1]
                }
                
                let thisX = lastAcDataFiltered[0] + self.ALPHA*(thisAcData[0] - lastAcDataFiltered[0])
                let thisY = lastAcDataFiltered[1] + self.ALPHA*(thisAcData[1] - lastAcDataFiltered[1])
                let thisZ = lastAcDataFiltered[2] + self.ALPHA*(thisAcData[2] - lastAcDataFiltered[2])
                
                thisAcDataFiltered = [thisX, thisY, thisZ]
                
                self.acDataFiltered.append(thisAcDataFiltered)
                
                //End Cycle calculations
                if self.count >= Int(countMax) {
                    self.lastOfLastCycle = self.acDataFiltered[self.acDataFiltered.endIndex - 1]
                    
                    //Tresshold Calculations
                    var acDataFilteredX: [Double] = []
                    var acDataFilteredY: [Double] = []
                    var acDataFilteredZ: [Double] = []
                    
                    for i in self.acDataFiltered {
                        acDataFilteredX.append(i[0])
                        acDataFilteredY.append(i[1])
                        acDataFilteredZ.append(i[2])
                    }
                    
                    let xyz = [abs(self.average(nums: acDataFilteredX)), abs(self.average(nums: acDataFilteredY)), abs(self.average(nums: acDataFilteredZ))]
                    
                    let treshold = xyz.max()! * 2.0
                    
                    let whichAxis = xyz.index(of: xyz.max() ?? 0)
                    
                    //Walking or Running
                    var overTresholdCount = 0.0
                    
                    //Calculate Step Rate
                    var stepRateCount = 0
                    
                    var lastData: [Double] = []
                    
                    //Check how many points are greater than the treshold and whats the step rate
                    for i in self.acData {
                        let tresholdStep = treshold * 0.6
                        if lastData.count != 0 {
                            if abs(lastData[whichAxis!]) < tresholdStep && abs(i[whichAxis!]) >= tresholdStep {
                                stepRateCount += 1
                            }
                        }
                        //Count over treshold data
                        if abs(i[whichAxis!]) >= treshold {
                            overTresholdCount += 1.0
                        }
                        
                        lastData = i
                    }
                    
                    if overTresholdCount >= Double(self.acData.count) * 0.1 {
                        completion(.running)
                    } else {
                        if stepRateCount <= 2 {
                            completion(.standingBy)
                        } else {
                            completion(.walking)
                        }
                    }
                    
                    self.acData = []
                    self.speedData = []
                    self.acDataFiltered = []
                    self.count = 1
                    
                    //Stop watching activity
                    self.aware.stopUpdatingLocation()
                    self.aware.speedDelegate = nil
                    self.motionManager.stopAccelerometerUpdates()
                    
                } else {
                    self.count += 1
                }
            })
        }
    }
    
    private func average(nums: [Double]) -> Double {
        var total = 0.0
        for vote in nums {
            total += vote
        }
        return total/Double(nums.count)
    }
}

