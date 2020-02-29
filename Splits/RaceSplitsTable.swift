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
    var totalTimeRecorded = 0
    
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
        
        // Test data
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
    
    
    // Show slider values on UI
    @IBAction func swimSliderChanged(_ sender: UISlider) {
        swimPace.text = "Swim pace: \(swimSlider.value.rounded()) / 100m"
    }
    
    @IBAction func t1SliderChanged(_ sender: UISlider) {
        t1Pace.text = "T1: \(t1Slider.value.rounded()) mins"
        t1Time.text = "\(t1Slider.value.rounded()) mins"
    }
    
    @IBAction func bikeSliderChanged(_ sender: UISlider) {
        bikePace.text = "Bike pace: \(bikeSlider.value.rounded()) / Hr"
    }
    
    @IBAction func t2SliderChanged(_ sender: UISlider) {
        t2Pace.text = "T2: \(t2Slider.value.rounded()) mins"
        t2Time.text = "\(t2Slider.value.rounded()) mins"
        
    }
    
    @IBAction func runSliderChanged(_ sender: UISlider) {
        runPace.text = "Run pace: \(runSlider.value.rounded()) / Km"
    }
}
