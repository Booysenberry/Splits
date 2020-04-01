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
    @IBOutlet weak var footerView: UIView!
    
    var receivedRace = Race()
    var raceFromCD: SavedRace? = nil
    var isSavedRace = false
    var raceTotalTime: Float = 0.0
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Displays slowest speed on left
        swimSlider.semanticContentAttribute = .forceRightToLeft
        runSlider.semanticContentAttribute = .forceRightToLeft
        
        for slider in [swimSlider, runSlider] {
            slider?.minimumTrackTintColor = .systemGreen
            slider?.maximumTrackTintColor = .systemOrange
        }
        
        for slider in [bikeSlider, t1Slider, t2Slider] {
            slider?.minimumTrackTintColor = .systemOrange
            slider?.maximumTrackTintColor = .systemGreen
        }
        
        numberFormatter.maximumFractionDigits = 2
        measurementFormatter.numberFormatter = numberFormatter
        timeFormatter.dateFormat = "HH:mm:ss"
        
        formatDistances()
        
        switch isSavedRace {
        case true:
            // Add save button to navbar
            let saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveToCoreData))
            self.navigationItem.rightBarButtonItem = saveButton
            
            // Load data from core data
            loadSavedData()
            
        default:
            switch defaults.bool(forKey: "First Launch") {
            case true:
                // Load from user defaults
                loadUserDefaults()
                footerView.isHidden = true
                
            default:
                // First launch
                loadFirstLaunch()
                defaults.set(true, forKey: "First Launch")
                footerView.isHidden = true
            }
        }
        calculateSplits()
    }
    
    func formatDistances() {
        
        switch isSavedRace {
        case true:
            if let race = raceFromCD {
                let formattedSwimDistance = Measurement(value: Double(race.swimDistance), unit: UnitLength.meters)
                let formattedBikeDistance = Measurement(value: Double(race.bikeDistance), unit: UnitLength.meters)
                let formattedRunDistance = Measurement(value: Double(race.runDistance), unit: UnitLength.meters)
                
                swimDistance.text = measurementFormatter.string(from: formattedSwimDistance)
                bikeDistance.text = measurementFormatter.string(from: formattedBikeDistance)
                runDistance.text = measurementFormatter.string(from: formattedRunDistance)
            }
        default:
            let race = receivedRace
            let formattedSwimDistance = Measurement(value: Double(race.swimDistance), unit: UnitLength.meters)
            let formattedBikeDistance = Measurement(value: Double(race.bikeDistance), unit: UnitLength.meters)
            let formattedRunDistance = Measurement(value: Double(race.runDistance), unit: UnitLength.meters)
            
            swimDistance.text = measurementFormatter.string(from: formattedSwimDistance)
            bikeDistance.text = measurementFormatter.string(from: formattedBikeDistance)
            runDistance.text = measurementFormatter.string(from: formattedRunDistance)
        }
        calculateSplits()
    }
    
    
    func loadFirstLaunch() {
        
        t1Pace.text = "T1: \(paceString(time: TimeInterval(t1Slider.value))) mins"
        t2Pace.text = "T2: \(paceString(time: TimeInterval(t2Slider.value))) mins"
        
        switch locale.usesMetricSystem {
        case true:
            swimPace.text = "Swim: \(paceString(time: TimeInterval(swimSlider!.value))) /100m"
            bikePace.text = "Bike: \(bikeSlider.value.rounded()) kph"
            runPace.text = "Run: \(paceString(time: TimeInterval(runSlider!.value.rounded()))) /km"
        default:
            setImperialSliderRange()
            
            swimSlider.setValue(112.5, animated: false)
            swimPace.text = "Swim: \(paceString(time: TimeInterval(swimSlider!.value))) /100 yds"
            
            bikeSlider.setValue(20, animated: false)
            bikePace.text = "Bike: \(bikeSlider.value.rounded()) mph"
            
            runSlider.setValue(630, animated: false)
            runPace.text = "Run: \(paceString(time: TimeInterval(runSlider!.value.rounded()))) /mile"
        }
    }
    
    
    func loadSavedData() {
        
        if let selectedRace = raceFromCD {
            
            if let raceName = selectedRace.raceName {
                title = "\(raceName)"
            }
            t1Slider.setValue(selectedRace.t1Time, animated: false)
            t1Pace.text = "T1: \(paceString(time: TimeInterval(selectedRace.t1Time))) mins"
            
            t2Slider.setValue(selectedRace.t2Time, animated: false)
            t2Pace.text = "T2: \(paceString(time: TimeInterval(selectedRace.t2Time))) mins"
            
            switch locale.usesMetricSystem {
            case true:
                swimPace.text = "Swim: \(paceString(time: TimeInterval(selectedRace.swimPace.rounded()))) /100m"
                bikePace.text = "Bike: \(selectedRace.bikePace.rounded()) kph"
                runPace.text = "Run: \(paceString(time: TimeInterval(selectedRace.runPace.rounded()))) /km"
            default:
                setImperialSliderRange()
                swimPace.text = "Swim: \(paceString(time: TimeInterval(selectedRace.swimPace.rounded()))) /100yds"
                bikePace.text = "Bike: \(selectedRace.bikePace.rounded()) mph"
                runPace.text = "Run: \(paceString(time: TimeInterval(selectedRace.runPace.rounded()))) /mile"
            }
            swimSlider.setValue(selectedRace.swimPace.rounded(), animated: false)
            bikeSlider.setValue(selectedRace.bikePace.rounded(), animated: false)
            runSlider.setValue(selectedRace.runPace.rounded(), animated: false)
        }
    }
    
    func loadUserDefaults() {
        
        // Check if the device uses metric system
        switch locale.usesMetricSystem {
        case true:
            swimPace.text = "Swim: \(paceString(time: TimeInterval(defaults.float(forKey: "swimPace").rounded()))) /100m"
            bikePace.text = "Bike: \(defaults.float(forKey: "bikePace").rounded()) kph"
            runPace.text = "Run: \(paceString(time: TimeInterval(defaults.float(forKey: "runPace").rounded()))) /km"
        default:
            setImperialSliderRange()
            swimPace.text = "Swim: \(paceString(time: TimeInterval(defaults.float(forKey: "swimPace").rounded()))) /100yds"
            bikePace.text = "Bike: \(defaults.float(forKey: "bikePace").rounded()) mph"
            runPace.text = "Run: \(paceString(time: TimeInterval(defaults.float(forKey: "runPace").rounded()))) /mile"
        }
        
        // Set slider values
        t1Slider.setValue(defaults.float(forKey: "t1Pace"), animated: false)
        t2Slider.setValue(defaults.float(forKey: "t2Pace"), animated: false)
        swimSlider.setValue(defaults.float(forKey: "swimPace").rounded(), animated: false)
        bikeSlider.setValue(defaults.float(forKey: "bikePace").rounded(), animated: false)
        runSlider.setValue(defaults.float(forKey: "runPace"), animated: false)
    }
    
    func setImperialSliderRange() {
        bikeSlider.minimumValue = 10
        bikeSlider.maximumValue = 30
        
        runSlider.minimumValue = 300
        runSlider.maximumValue = 960
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
    
    func calculateSavedSplits() {
        
        let savedRace = raceFromCD!
        
        switch locale.usesMetricSystem {
        case true:
            let convertedSwimTime = (savedRace.swimDistance / 100) * swimSlider.value.rounded()
            swimTotalTime = convertedSwimTime.rounded()
            
            let convertedBikeSpeed = bikeSlider.value.rounded() / 3.6 // kph to m/s
            let bikeSplit = savedRace.bikeDistance / convertedBikeSpeed
            bikeTotalTime = bikeSplit.rounded()
            
            let convertedRunSpeed = 16.667 / (runSlider.value.rounded() / 60) // m/km to m/s
            let runSplit = savedRace.runDistance / convertedRunSpeed
            runTotalTime = runSplit.rounded()
            
        default:
            let convertedSwimTime = ((savedRace.swimDistance * 1.094) / 100) * swimSlider.value.rounded() // Yds to meters
            swimTotalTime = convertedSwimTime.rounded()
            
            let convertedBikeSpeed = bikeSlider.value.rounded() / 2.237 // mph to m/s
            let bikeSplit = savedRace.bikeDistance / convertedBikeSpeed
            bikeTotalTime = bikeSplit.rounded()
            
            let convertedRunSpeed = 26.822 / (runSlider.value.rounded() / 60) // m/mi to m/s
            let runSplit = (savedRace.runDistance) / convertedRunSpeed
            runTotalTime = runSplit.rounded()
        }
    }
    
    func calculateUnsavedSplits() {
        
        let savedRace = receivedRace
        
        switch locale.usesMetricSystem {
        case true:
            let convertedSwimTime = (savedRace.swimDistance / 100) * swimSlider.value.rounded()
            swimTotalTime = convertedSwimTime.rounded()
            
            let convertedBikeSpeed = bikeSlider.value.rounded() / 3.6 // kph to m/s
            let bikeSplit = savedRace.bikeDistance / convertedBikeSpeed
            bikeTotalTime = bikeSplit.rounded()
            
            let convertedRunSpeed = 16.667 / (runSlider.value.rounded() / 60) // m/km to m/s
            let runSplit = savedRace.runDistance / convertedRunSpeed
            runTotalTime = runSplit.rounded()
            
        default:
            let convertedSwimTime = ((savedRace.swimDistance * 1.094) / 100) * swimSlider.value.rounded() // Yds to meters
            swimTotalTime = convertedSwimTime.rounded()
            
            let convertedBikeSpeed = bikeSlider.value.rounded() / 2.237 // mph to m/s
            let bikeSplit = savedRace.bikeDistance / convertedBikeSpeed
            bikeTotalTime = bikeSplit.rounded()
            
            let convertedRunSpeed = 26.822 / (runSlider.value.rounded() / 60) // m/mi to m/s
            let runSplit = (savedRace.runDistance) / convertedRunSpeed
            runTotalTime = runSplit.rounded()
        }
    }
    
    func calculateSplits() {
        
        t1TotalTime = t1Slider.value
        t2TotalTime = t2Slider.value
        
        switch isSavedRace {
        case true:
            calculateSavedSplits()
        default:
            calculateUnsavedSplits()
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
        raceTotalTime = accumulateTime
        
        if isSavedRace == false {
            defaults.set(accumulateTime, forKey: "totalRaceTime")
        }
    }
    
    // Update UI with slider values
    @IBAction func swimSliderChanged(_ sender: UISlider) {
        
        // Increments of 5
        let roundedSwimTime = round(swimSlider.value / step) * step
        swimSlider.value = roundedSwimTime
        
        calculateSplits()
        
        if locale.usesMetricSystem {
            swimPace.text = "Swim: \(paceString(time: TimeInterval(swimSlider!.value))) / 100m"
        } else {
            swimPace.text = "Swim: \(paceString(time: TimeInterval(swimSlider!.value))) / 100 yds"
        }
        swimTime.text = "\(timeString(time: TimeInterval(swimTotalTime)))"
        
        if isSavedRace == false {
            defaults.set(swimSlider.value, forKey: "swimPace")
        }
    }
    
    @IBAction func t1SliderChanged(_ sender: UISlider) {
        
        // Increments of 5 seconds
        let roundedT1Time = round(t1Slider.value / step) * step
        
        t1Slider.value = roundedT1Time
        t1TotalTime = roundedT1Time
        t1Pace.text = "T1: \(paceString(time: TimeInterval(t1Slider.value))) mins"
        
        if isSavedRace == false {
            defaults.set(t1Slider.value, forKey: "t1Pace")
        }
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
        
        if isSavedRace == false {
            defaults.set(bikeSlider.value, forKey: "bikePace")
        }
    }
    
    @IBAction func t2SliderChanged(_ sender: UISlider) {
        
        // Increments of 5
        let roundedT2Time = round(t2Slider.value / step) * step
        
        t2Slider.value = roundedT2Time
        t2TotalTime = roundedT2Time
        t2Pace.text = "T1: \(paceString(time: TimeInterval(t2Slider.value))) mins"
        
        if isSavedRace == false {
            defaults.set(t2Slider.value, forKey: "t2Pace")
        }
        calculateTotalTime()
    }
    
    @IBAction func runSliderChanged(_ sender: UISlider) {
        
        // Increments of 5 seconds
        let roundedRunTime = round(runSlider.value / step) * step
        runSlider.value = roundedRunTime
        
        calculateSplits()
        
        if locale.usesMetricSystem {
            runPace.text = "Run: \(paceString(time: TimeInterval(runSlider!.value.rounded()))) /km"
        } else {
            runPace.text = "Run: \(paceString(time: TimeInterval(runSlider!.value.rounded()))) /mile"
        }
        if isSavedRace == false {
            defaults.set(runSlider.value, forKey: "runPace")
        }
    }
    
    @objc func saveToCoreData() {
        
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            if let updatedRace = raceFromCD {
                
                updatedRace.swimPace = swimSlider.value
                updatedRace.t1Time = t1Slider.value
                updatedRace.bikePace = bikeSlider.value
                updatedRace.t2Time = t2Slider.value
                updatedRace.runPace = runSlider.value
                updatedRace.totalTime = raceTotalTime
                
                // Update core data
                do {
                    try context.save()
                } catch {
                    fatalError("Failure to save context: \(error)")
                }
            }
            
            let alert = UIAlertController(title: "Saved", message: nil, preferredStyle: .alert)
            self.present(alert, animated: true)
            
            // Dismiss confirmation alert after 1 second
            let when = DispatchTime.now() + 1
            DispatchQueue.main.asyncAfter(deadline: when){
                // your code with delay
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func deleteFromCoreData(_ sender: Any) {
        
        let alert = UIAlertController(title: "Are you sure you want to delete?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
            if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
                if let race = self.raceFromCD {
                    context.delete(race)
                    (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
                }
            }
            self.navigationController?.popViewController(animated: true)
        }))
        
        self.present(alert, animated: true)
    }
}

