//
//  RaceSplitsTable.swift
//  Splits
//
//  Created by Brad Booysen on 28/02/20.
//  Copyright © 2020 Booysenberry. All rights reserved.
//

import UIKit
import CoreData

class RaceSplitsTable: UITableViewController {
    
    var receivedRace = Race()
    
    var swimTotalTime: Float = 0.0
    var bikeTotalTime: Float = 0.0
    var runTotalTime: Float = 0.0
    var t1TotalTime: Float = 0.0
    var t2TotalTime: Float = 0.0
    let step: Float = 5
    
    let defaults = UserDefaults.standard
    let notificationCentre = NotificationCenter.default
    let locale = Locale.current
    let distanceFormatter = LengthFormatter()
    let timeFormatter = DateFormatter()
    let measurementFormatter = MeasurementFormatter()
    let numberFormatter = NumberFormatter()
    
    @IBOutlet weak var swimPace: UILabel!
    @IBOutlet weak var swimTime: UILabel!
    @IBOutlet weak var swimDistance: UILabel!
    @IBOutlet weak var swimSlider: UISlider!
    @IBOutlet weak var t1Pace: UILabel!
    @IBOutlet weak var t1Time: UILabel!
    @IBOutlet weak var t1Slider: UISlider!
    @IBOutlet weak var bikePace: UILabel!
    @IBOutlet weak var bikeTime: UILabel!
    @IBOutlet weak var bikeDistance: UILabel!
    @IBOutlet weak var bikeSlider: UISlider!
    @IBOutlet weak var t2Pace: UILabel!
    @IBOutlet weak var t2Time: UILabel!
    @IBOutlet weak var t2Slider: UISlider!
    @IBOutlet weak var runPace: UILabel!
    @IBOutlet weak var runTime: UILabel!
    @IBOutlet weak var runDistance: UILabel!
    @IBOutlet weak var runSlider: UISlider!
    @IBOutlet weak var totalTime: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numberFormatter.maximumFractionDigits = 1
        measurementFormatter.numberFormatter = numberFormatter
        timeFormatter.dateFormat = "HH:mm:ss"
        
        // Checks if this is the first time the app is being launched
        if defaults.bool(forKey: "First Launch") == true {
            
            t1Slider.setValue(defaults.float(forKey: "t1Pace"), animated: false)
            t1Pace.text = "T1: \(paceString(time: TimeInterval(defaults.float(forKey: "t1Pace")))) mins"
            
            t2Slider.setValue(defaults.float(forKey: "t2Pace"), animated: false)
            t2Pace.text = "T2: \(paceString(time: TimeInterval(defaults.float(forKey: "t2Pace")))) mins"
            
            swimSlider.setValue(defaults.float(forKey: "swimPace").rounded(), animated: false)
            swimPace.text = "Swim: \(paceString(time: TimeInterval(defaults.float(forKey: "swimPace").rounded()))) /100 yds"
            
            bikeSlider.setValue(defaults.float(forKey: "bikePace").rounded(), animated: false)
            bikePace.text = "Bike: \(defaults.float(forKey: "bikePace").rounded()) mph"
            
            runSlider.setValue(defaults.float(forKey: "runPace"), animated: false)
            runPace.text = "Run: \(paceString(time: TimeInterval(defaults.float(forKey: "runPace").rounded()))) /mile"
            
            defaults.set(true, forKey: "First Launch")
            
        } else {
            
            t1Pace.text = "T1: \(paceString(time: TimeInterval(t1Slider.value))) mins"
            t2Pace.text = "T2: \(paceString(time: TimeInterval(t2Slider.value))) mins"
            
            if locale.usesMetricSystem == false {
                
                swimSlider.setValue(112.5, animated: false)
                swimPace.text = "Swim: \(paceString(time: TimeInterval(swimSlider!.value))) /100 yds"
                
                bikeSlider.minimumValue = 10
                bikeSlider.maximumValue = 30
                bikeSlider.setValue(20, animated: false)
                bikePace.text = "Bike: \(bikeSlider.value.rounded()) mph"
               
                runSlider.minimumValue = 300
                runSlider.maximumValue = 960
                runSlider.setValue(630, animated: false)
                runPace.text = "Run: \(paceString(time: TimeInterval(runSlider!.value.rounded()))) /mile"
                
            } else {
                
                swimPace.text = "Swim: \(paceString(time: TimeInterval(swimSlider!.value))) /100m"
                bikePace.text = "Bike: \(bikeSlider.value.rounded()) kph"
                runPace.text = "Run: \(paceString(time: TimeInterval(runSlider!.value.rounded()))) /km"
                
            }
            
            defaults.set(true, forKey: "First Launch")
        }
        
        let formattedSwimDistance = Measurement(value: Double(receivedRace.swimDistance), unit: UnitLength.meters)
        let formattedBikeDistance = Measurement(value: Double(receivedRace.bikeDistance), unit: UnitLength.meters)
        let formattedRunDistance = Measurement(value: Double(receivedRace.runDistance), unit: UnitLength.meters)
        
        swimDistance.text = measurementFormatter.string(from: formattedSwimDistance)
        bikeDistance.text = measurementFormatter.string(from: formattedBikeDistance)
        runDistance.text = measurementFormatter.string(from: formattedRunDistance)
        
        calculateSplits()
        
        // Remove unused rows
        tableView.tableFooterView = UIView()
    }
    
    // Format pace string
    func paceString(time: TimeInterval) -> String {
        let minute = Int(time) / 60 % 60
        let second = Int(time) % 60
        
        // return formated string
        return String(format: "%02i:%02i", minute, second)
    }
    
    // Format time string
    func timeString(time: TimeInterval) -> String {
        let hour = Int(time) / 3600
        let minute = Int(time) / 60 % 60
        let second = Int(time) % 60
        
        // return formated string
        return String(format: "%02i:%02i:%02i", hour, minute, second)
    }
    
    func calculateSplits() {
        
        if locale.usesMetricSystem {
            
            let convertedSwimTime = (receivedRace.swimDistance / 100) * swimSlider.value
            swimTotalTime = convertedSwimTime.rounded()
            
            let convertedBikeSpeed = bikeSlider.value.rounded() / 3.6 // kph to m/s
            let bikeSplit = receivedRace.bikeDistance / convertedBikeSpeed
            bikeTotalTime = bikeSplit.rounded()
            
            let convertedRunSpeed = 16.667 / (runSlider.value.rounded() / 60) // m/km to m/s
            let runSplit = receivedRace.runDistance / convertedRunSpeed
            runTotalTime = runSplit.rounded()
            
            t1TotalTime = t1Slider.value
            t2TotalTime = t2Slider.value
            
        } else {
            
            let convertedSwimTime = ((receivedRace.swimDistance * 1.094) / 100) * swimSlider.value.rounded() // Yds to meters
            swimTotalTime = convertedSwimTime.rounded()
            
            let convertedBikeSpeed = bikeSlider.value.rounded() / 2.237 // mph to m/s
            let bikeSplit = receivedRace.bikeDistance / convertedBikeSpeed
            bikeTotalTime = bikeSplit.rounded()
            
            let convertedRunSpeed = 26.822 / (runSlider.value.rounded() / 60) // m/mi to m/s
            let runSplit = (receivedRace.runDistance) / convertedRunSpeed
            runTotalTime = runSplit.rounded()
            
            t1TotalTime = t1Slider.value
            t2TotalTime = t2Slider.value
   
        }
        calculateTotalTime()
    }
    
    // Calculate total time
    func calculateTotalTime() {
        let accumulateTime = swimTotalTime + t1TotalTime + bikeTotalTime + t2TotalTime + runTotalTime
        totalTime.text = "\(timeString(time: TimeInterval(accumulateTime)))"
        swimTime.text = "\(timeString(time: TimeInterval(swimTotalTime)))"
        t1Time.text = "\(timeString(time: TimeInterval(t1Slider.value)))"
        bikeTime.text = "\(timeString(time: TimeInterval(bikeTotalTime)))"
        t2Time.text = "\(timeString(time: TimeInterval(t2Slider.value)))"
        runTime.text = "\(timeString(time: TimeInterval(runTotalTime)))"
        defaults.set(accumulateTime, forKey: "totalRaceTime")
    }
    
    // Update UI with slider values
    @IBAction func swimSliderChanged(_ sender: UISlider) {
        
        calculateSplits()
        
        if locale.usesMetricSystem {
            swimPace.text = "Swim: \(paceString(time: TimeInterval(swimSlider!.value))) / 100m"
        } else {
            swimPace.text = "Swim: \(paceString(time: TimeInterval(swimSlider!.value))) / 100 yds"
        }
        swimTime.text = "\(timeString(time: TimeInterval(swimTotalTime)))"
        defaults.set(swimSlider.value, forKey: "swimPace")
    }
    
    @IBAction func t1SliderChanged(_ sender: UISlider) {
        
        // Increments of 5
        let roundedT1Time = round(t1Slider.value / step) * step
        
        t1Slider.value = roundedT1Time
        t1TotalTime = roundedT1Time
        t1Pace.text = "T1: \(paceString(time: TimeInterval(t1Slider.value))) mins"
        defaults.set(t1Slider.value, forKey: "t1Pace")
        calculateTotalTime()
    }
    
    @IBAction func bikeSliderChanged(_ sender: UISlider) {
        
        calculateSplits()
        
        if locale.usesMetricSystem {
            bikePace.text = "Bike: \(bikeSlider.value.rounded()) kph"
        } else {
            bikePace.text = "Bike: \(bikeSlider.value.rounded()) mph"
        }
        bikeTime.text = "\(timeString(time: TimeInterval(bikeTotalTime)))"
        defaults.set(bikeSlider.value, forKey: "bikePace")
    }
    
    @IBAction func t2SliderChanged(_ sender: UISlider) {
        
        // Increments of 5
        let roundedT2Time = round(t2Slider.value / step) * step
        
        t2Slider.value = roundedT2Time
        t2TotalTime = roundedT2Time
        t2Pace.text = "T1: \(paceString(time: TimeInterval(t2Slider.value))) mins"
        defaults.set(t2Slider.value, forKey: "t2Pace")
        calculateTotalTime()
    }
    
    @IBAction func runSliderChanged(_ sender: UISlider) {
        
        calculateSplits()
        
        if locale.usesMetricSystem {
            runPace.text = "Run: \(paceString(time: TimeInterval(runSlider!.value.rounded()))) /km"
        } else {
            runPace.text = "Run: \(paceString(time: TimeInterval(runSlider!.value.rounded()))) /mile"
        }
        defaults.set(runSlider.value, forKey: "runPace")
    }
}

