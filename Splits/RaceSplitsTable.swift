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
    var runtotalTime = 0
    var t1TotalTime = 0
    var t2TotalTime = 0
    
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
        
        calculateTotalTime()
        
        numberFormatter.maximumFractionDigits = 1
        measurementFormatter.numberFormatter = numberFormatter
        timeFormatter.dateFormat = "HH:mm:ss"
        
        if locale.usesMetricSystem == false {
            bikeSlider.minimumValue = 10
            bikeSlider.maximumValue = 30
        }
        
        // Test data - REMOVE
        receivedRace.bikeDistance = 40000
        receivedRace.runDistance = 10000
        receivedRace.swimDistance = 1500
        
        let formattedSwimDistance = Measurement(value: receivedRace.swimDistance, unit: UnitLength.meters)
        let formattedBikeDistance = Measurement(value: receivedRace.bikeDistance, unit: UnitLength.meters)
        let formattedRunDistance = Measurement(value: receivedRace.runDistance, unit: UnitLength.meters)
        
        swimDistance.text = measurementFormatter.string(from: formattedSwimDistance)
        bikeDistance.text = measurementFormatter.string(from: formattedBikeDistance)
        runDistance.text = measurementFormatter.string(from: formattedRunDistance)
        
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
    
    // Calculate total time
    
    func calculateTotalTime() {
        let accumulateTime = swimTotalTime + t1TotalTime + bikeTotalTime + t2TotalTime + runtotalTime
        totalTime.text = "\(timeString(time: TimeInterval(accumulateTime)))"
    }

    // Show slider values on UI
    @IBAction func swimSliderChanged(_ sender: UISlider) {
        
        let swimTotalTime = (receivedRace.swimDistance / 100) * Double(swimSlider.value)
        swimPace.text = "\(paceString(time: TimeInterval(swimSlider!.value))) / 100m"
        swimTime.text = "\(timeString(time: TimeInterval(swimTotalTime)))"
        calculateTotalTime()
    }
    
    @IBAction func t1SliderChanged(_ sender: UISlider) {
        t1Pace.text = "T1: \(t1Slider.value.rounded()) mins"
        t1Time.text = "\(t1Slider.value.rounded()) mins"
        calculateTotalTime()
    }
    
    @IBAction func bikeSliderChanged(_ sender: UISlider) {
        
        if locale.usesMetricSystem {
            
            let convertedSpeed = bikeSlider.value.rounded() / 3.6 // kph to m/s
            let bikeSplit = receivedRace.bikeDistance / Double(convertedSpeed)
            bikeTotalTime = Int(bikeSplit)
            bikePace.text = "Bike pace: \(bikeSlider.value.rounded()) kph"
            bikeTime.text = "\(timeString(time: TimeInterval(bikeSplit.rounded())))"
            calculateTotalTime()
            
        } else {
            
            let convertedSpeed = bikeSlider.value.rounded() / 2.237 // mph to m/s
            let bikeSplit = receivedRace.bikeDistance / Double(convertedSpeed)
            bikeTotalTime = Int(bikeSplit)
            bikePace.text = "Bike pace: \(bikeSlider.value.rounded()) mph"
            bikeTime.text = "\(timeString(time: TimeInterval(bikeSplit.rounded())))"
            calculateTotalTime()
        }
    }
    
    @IBAction func t2SliderChanged(_ sender: UISlider) {
        t2Pace.text = "T2: \(t2Slider.value.rounded()) mins"
        t2Time.text = "\(t2Slider.value.rounded()) mins"
        calculateTotalTime()
        
    }
    
    @IBAction func runSliderChanged(_ sender: UISlider) {
        runPace.text = "\(paceString(time: TimeInterval(runSlider!.value))) /km"
        calculateTotalTime()
    }
}

