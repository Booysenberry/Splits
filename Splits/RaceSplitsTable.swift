//
//  RaceSplitsTable.swift
//  Splits
//
//  Created by Brad Booysen on 28/02/20.
//  Copyright © 2020 Booysenberry. All rights reserved.
//

import UIKit

class RaceSplitsTable: UITableViewController {
    
    var receivedRace = Race()
    var bikeTotalTime = 0
    var swimTotalTime = 0
    var runTotalTime = 0
    var t1TotalTime = 0
    var t2TotalTime = 0
    let step: Float = 5
    
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
        
        let formattedSwimDistance = Measurement(value: receivedRace.swimDistance, unit: UnitLength.meters)
        let formattedBikeDistance = Measurement(value: receivedRace.bikeDistance, unit: UnitLength.meters)
        let formattedRunDistance = Measurement(value: receivedRace.runDistance, unit: UnitLength.meters)
        
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
            
            let convertedSwimTime = (receivedRace.swimDistance / 100) * Double(swimSlider.value.rounded())
            swimTotalTime = Int(convertedSwimTime.rounded())
            
            let convertedBikeSpeed = bikeSlider.value.rounded() / 3.6 // kph to m/s
            let bikeSplit = receivedRace.bikeDistance / Double(convertedBikeSpeed)
            bikeTotalTime = Int(bikeSplit.rounded())
            
            let convertedRunSpeed = 16.667 / (runSlider.value.rounded() / 60) // m/km to m/s
            let runSplit = receivedRace.runDistance / Double(convertedRunSpeed)
            runTotalTime = Int(runSplit.rounded())
            
            t1TotalTime = Int(t1Slider.value)
            t2TotalTime = Int(t2Slider.value)
            
        } else {
            
            let convertedSwimTime = ((receivedRace.swimDistance * 1.094) / 100) * Double(swimSlider.value.rounded()) // Yds to meters
            swimTotalTime = Int(convertedSwimTime.rounded())
            
            let convertedBikeSpeed = bikeSlider.value.rounded() / 2.237 // mph to m/s
            let bikeSplit = receivedRace.bikeDistance / Double(convertedBikeSpeed)
            bikeTotalTime = Int(bikeSplit.rounded())
            
            let convertedRunSpeed = 26.822 / (runSlider.value.rounded() / 60) // m/mi to m/s
            let runSplit = (receivedRace.runDistance) / Double(convertedRunSpeed)
            runTotalTime = Int(runSplit.rounded())
            
            t1TotalTime = Int(t1Slider.value)
            t2TotalTime = Int(t2Slider.value)
   
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
    }
    
    @IBAction func t1SliderChanged(_ sender: UISlider) {
        
        // Increments of 5
        let roundedT1Time = round(t1Slider.value / step) * step
        
        t1Slider.value = roundedT1Time
        t1TotalTime = Int(roundedT1Time)
        t1Pace.text = "T1: \(paceString(time: TimeInterval(t1Slider.value))) mins"
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
    }
    
    @IBAction func t2SliderChanged(_ sender: UISlider) {
        
        // Increments of 5
        let roundedT2Time = round(t2Slider.value / step) * step
        
        t2Slider.value = roundedT2Time
        t2TotalTime = Int(roundedT2Time)
        t2Pace.text = "T1: \(paceString(time: TimeInterval(t2Slider.value))) mins"
        calculateTotalTime()
    }
    
    @IBAction func runSliderChanged(_ sender: UISlider) {
        
        calculateSplits()
        
        if locale.usesMetricSystem {
            runPace.text = "Run: \(paceString(time: TimeInterval(runSlider!.value.rounded()))) /km"
        } else {
            runPace.text = "Run: \(paceString(time: TimeInterval(runSlider!.value.rounded()))) /mile"
        }
    }
}

