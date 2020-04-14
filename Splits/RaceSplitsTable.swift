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
    
    var hasChangedUnits = false
    var usesMetricUnits = true
    var receivedRace = Race()
    var raceFromCD: SavedRace? = nil
    var isSavedRace = false
    var raceTotalTime: Float = 0.0
    var swimTotalTime: Float = 0.0
    var bikeTotalTime: Float = 0.0
    var runTotalTime: Float = 0.0
    var t1TotalTime: Float = 0.0
    var t2TotalTime: Float = 0.0
    let fiveSecondIncrements: Float = 5
    let sixtySecondIncrements: Float = 60
    
    let defaults = UserDefaults.standard
    let notificationCentre = NotificationCenter.default
    let locale = Locale.current
    let timeFormatter = DateFormatter()
    let measurementFormatter = MeasurementFormatter()
    let numberFormatter = NumberFormatter()
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Checks if the user has changed measurement units
        checkForPreferredUnits()
        
        for slider in [swimSlider, runSlider] {
            // Displays slowest speed on left
            slider?.semanticContentAttribute = .forceRightToLeft
            
            slider?.minimumTrackTintColor = .systemGray2
            slider?.maximumTrackTintColor = .systemBlue
            slider?.minimumValueImage = UIImage(named: "rabbit")
            slider?.maximumValueImage = UIImage(named: "tortoise")
            slider?.thumbTintColor = .systemBlue
        }
        
        for slider in [bikeSlider, t1Slider, t2Slider] {
            slider?.minimumTrackTintColor = .systemBlue
            slider?.maximumTrackTintColor = .systemGray2
            slider?.minimumValueImage = UIImage(named: "tortoise")
            slider?.maximumValueImage = UIImage(named: "rabbit")
            slider?.thumbTintColor = .systemBlue
        }
        
        timeFormatter.dateFormat = "HH:mm:ss"
        
        formatDistances()
        
        loadPresets()
        
        // Assign reference tags to distance labels during long press
        swimDistance.tag = 0
        bikeDistance.tag = 1
        runDistance.tag = 2
        
        let distanceLabels = [swimDistance, bikeDistance, runDistance]
        
        for distance in distanceLabels {
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(sender:)))
            distance?.addGestureRecognizer(longPress)
            distance?.isUserInteractionEnabled = true
        }
    }
    
    func loadPresets() {
        
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
    
    // Allows the user to change distance if long pressing on distance label
    @objc func longPress(sender: UILongPressGestureRecognizer) {
        guard let distanceLabel = sender.view else {
            fatalError("could not attach distance label to the gesturerecognizer")
        }
        
        let alert = UIAlertController(title: "Change Distance", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addTextField(configurationHandler: { textField in
            textField.autocapitalizationType = .words
            textField.keyboardType = .decimalPad
            
            
            if self.usesMetricUnits {
                textField.placeholder = "kilometers"
            } else {
                textField.placeholder = "miles"
            }
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
            if let distanceString = alert.textFields?.first?.text {
                if let convertedDistance = Float(distanceString) {
                    if distanceString != "" {
                        
                        switch distanceLabel.tag {
                        case 0:
                            self.receivedRace.swimDistance = convertedDistance * 1000
                            self.defaults.set((convertedDistance * 1000), forKey: "swimDistance")
                        case 1:
                            self.receivedRace.bikeDistance = convertedDistance * 1000
                            self.defaults.set((convertedDistance * 1000), forKey: "bikeDistance")
                        case 2:
                            self.receivedRace.runDistance = convertedDistance * 1000
                            self.defaults.set((convertedDistance * 1000), forKey: "runDistance")
                        default:
                            break
                        }
                        self.formatDistances()
                    }
                }
            }
        }))
        self.present(alert, animated: true)
    }
    
    // Checks if the user has changed measurement units
    func checkForPreferredUnits() {
        switch defaults.bool(forKey: "hasChangedUnits") {
        case true:
            hasChangedUnits = true
            setPreferredUnits()
        default:
            usesMetricUnits = locale.usesMetricSystem
        }
    }
    
    // Set preferred measurement units if previously changed by the user
    func setPreferredUnits() {
        switch defaults.bool(forKey: "usesMetricSystem") {
        case true:
            usesMetricUnits = true
        default:
            usesMetricUnits = false
        }
    }
    
    func formatDistances() {
        
        switch isSavedRace {
        case true:
            if let race = raceFromCD {
                let formattedSwimDistance = Measurement(value: Double(race.swimDistance), unit: UnitLength.meters)
                let formattedBikeDistance = Measurement(value: Double(race.bikeDistance), unit: UnitLength.meters)
                let formattedRunDistance = Measurement(value: Double(race.runDistance), unit: UnitLength.meters)
                
                // Display preferred unit measurement if changed by the user in settings
                switch usesMetricUnits {
                case true:
                    if locale.usesMetricSystem {
                        measurementFormatter.locale = locale
                        numberFormatter.maximumFractionDigits = 2
                        measurementFormatter.numberFormatter = numberFormatter
                        
                        swimDistance.text = measurementFormatter.string(from: formattedSwimDistance)
                        bikeDistance.text = measurementFormatter.string(from: formattedBikeDistance)
                        runDistance.text = measurementFormatter.string(from: formattedRunDistance)
                        
                    } else {
                        measurementFormatter.locale = Locale(identifier: "EN_NZ")
                        numberFormatter.maximumFractionDigits = 2
                        measurementFormatter.numberFormatter = numberFormatter
                        
                        measurementFormatter.numberFormatter = numberFormatter
                        swimDistance.text = measurementFormatter.string(from: formattedSwimDistance)
                        bikeDistance.text = measurementFormatter.string(from: formattedBikeDistance)
                        runDistance.text = measurementFormatter.string(from: formattedRunDistance)
                    }
                    
                case false:
                    if locale.usesMetricSystem == false {
                        measurementFormatter.locale = locale
                        numberFormatter.maximumFractionDigits = 1
                        measurementFormatter.numberFormatter = numberFormatter
                        
                        measurementFormatter.numberFormatter = numberFormatter
                        swimDistance.text = measurementFormatter.string(from: formattedSwimDistance)
                        bikeDistance.text = measurementFormatter.string(from: formattedBikeDistance)
                        runDistance.text = measurementFormatter.string(from: formattedRunDistance)
                        
                    } else {
                        measurementFormatter.locale = Locale(identifier: "EN_US")
                        numberFormatter.maximumFractionDigits = 1
                        measurementFormatter.numberFormatter = numberFormatter
                        
                        measurementFormatter.numberFormatter = numberFormatter
                        swimDistance.text = measurementFormatter.string(from: formattedSwimDistance)
                        bikeDistance.text = measurementFormatter.string(from: formattedBikeDistance)
                        runDistance.text = measurementFormatter.string(from: formattedRunDistance)
                    }
                }
            }
        default:
            let race = receivedRace
            let formattedSwimDistance = Measurement(value: Double(race.swimDistance), unit: UnitLength.meters)
            let formattedBikeDistance = Measurement(value: Double(race.bikeDistance), unit: UnitLength.meters)
            let formattedRunDistance = Measurement(value: Double(race.runDistance), unit: UnitLength.meters)
            
            // Display preferred unit measurement if changed by the user in settings
            switch usesMetricUnits {
            case true:
                if locale.usesMetricSystem {
                    measurementFormatter.locale = locale
                    numberFormatter.maximumFractionDigits = 2
                    measurementFormatter.numberFormatter = numberFormatter
                    
                    swimDistance.text = measurementFormatter.string(from: formattedSwimDistance)
                    bikeDistance.text = measurementFormatter.string(from: formattedBikeDistance)
                    runDistance.text = measurementFormatter.string(from: formattedRunDistance)
                    
                } else {
                    measurementFormatter.locale = Locale(identifier: "EN_NZ")
                    numberFormatter.maximumFractionDigits = 2
                    measurementFormatter.numberFormatter = numberFormatter
                    
                    measurementFormatter.numberFormatter = numberFormatter
                    swimDistance.text = measurementFormatter.string(from: formattedSwimDistance)
                    bikeDistance.text = measurementFormatter.string(from: formattedBikeDistance)
                    runDistance.text = measurementFormatter.string(from: formattedRunDistance)
                }
                
            case false:
                if locale.usesMetricSystem == false {
                    measurementFormatter.locale = locale
                    numberFormatter.maximumFractionDigits = 1
                    measurementFormatter.numberFormatter = numberFormatter
                    
                    measurementFormatter.numberFormatter = numberFormatter
                    swimDistance.text = measurementFormatter.string(from: formattedSwimDistance)
                    bikeDistance.text = measurementFormatter.string(from: formattedBikeDistance)
                    runDistance.text = measurementFormatter.string(from: formattedRunDistance)
                    
                } else {
                    measurementFormatter.locale = Locale(identifier: "EN_US")
                    numberFormatter.maximumFractionDigits = 1
                    measurementFormatter.numberFormatter = numberFormatter
                    
                    measurementFormatter.numberFormatter = numberFormatter
                    swimDistance.text = measurementFormatter.string(from: formattedSwimDistance)
                    bikeDistance.text = measurementFormatter.string(from: formattedBikeDistance)
                    runDistance.text = measurementFormatter.string(from: formattedRunDistance)
                }
            }
        }
        calculateSplits()
    }
    
    func loadFirstLaunch() {
        
        t1Pace.text = "T1: \(paceString(time: TimeInterval(t1Slider.value))) mins"
        t2Pace.text = "T2: \(paceString(time: TimeInterval(t2Slider.value))) mins"
        
        switch usesMetricUnits {
        case true:
            swimPace.text = "Swim: \(paceString(time: TimeInterval(swimSlider!.value))) /100m"
            bikePace.text = "Bike: \(Int(bikeSlider.value)) kph"
            runPace.text = "Run: \(paceString(time: TimeInterval(runSlider!.value))) /km"
        default:
            setImperialSliderRange()
            
            swimSlider.setValue(150, animated: false)
            swimPace.text = "Swim: \(paceString(time: TimeInterval(swimSlider!.value))) /100 yds"
            
            bikeSlider.setValue(20, animated: false)
            bikePace.text = "Bike: \(Int(bikeSlider.value)) mph"
            
            runSlider.setValue(630, animated: false)
            runPace.text = "Run: \(paceString(time: TimeInterval(runSlider!.value))) /mile"
        }
        // Save to defaults if user doesn't change slider values before closing the app
        defaults.set(swimSlider.value, forKey: "swimPace")
        defaults.set(t1Slider.value, forKey: "t1Pace")
        defaults.set(bikeSlider.value, forKey: "bikePace")
        defaults.set(t2Slider.value, forKey: "t2Pace")
        defaults.set(runSlider.value, forKey: "runPace")
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
            
            switch usesMetricUnits {
            case true:
                setMetricSliderRange()
                swimPace.text = "Swim: \(paceString(time: TimeInterval(selectedRace.swimPace))) /100m"
                bikePace.text = "Bike: \(Int(selectedRace.bikePace)) kph"
                runPace.text = "Run: \(paceString(time: TimeInterval(selectedRace.runPace))) /km"
            default:
                setImperialSliderRange()
                swimPace.text = "Swim: \(paceString(time: TimeInterval(selectedRace.swimPace))) /100yds"
                bikePace.text = "Bike: \(Int(selectedRace.bikePace)) mph"
                runPace.text = "Run: \(paceString(time: TimeInterval(selectedRace.runPace))) /mile"
            }
            swimSlider.setValue(selectedRace.swimPace, animated: false)
            bikeSlider.setValue(selectedRace.bikePace, animated: false)
            runSlider.setValue(selectedRace.runPace, animated: false)
        }
    }
    
    func loadUserDefaults() {
        
        t1Pace.text = "T1: \(paceString(time: TimeInterval(defaults.float(forKey: "t1Pace")))) mins"
        t2Pace.text = "T2: \(paceString(time: TimeInterval(defaults.float(forKey: "t2Pace")))) mins"
        
        // Check if the device uses metric system
        switch usesMetricUnits {
        case true:
            setMetricSliderRange()
            swimPace.text = "Swim: \(paceString(time: TimeInterval(defaults.float(forKey: "swimPace")))) /100m"
            bikePace.text = "Bike: \(Int(defaults.float(forKey: "bikePace"))) kph"
            runPace.text = "Run: \(paceString(time: TimeInterval(defaults.float(forKey: "runPace")))) /km"
        default:
            setImperialSliderRange()
            swimPace.text = "Swim: \(paceString(time: TimeInterval(defaults.float(forKey: "swimPace")))) /100yds"
            bikePace.text = "Bike: \(Int(defaults.float(forKey: "bikePace"))) mph"
            runPace.text = "Run: \(paceString(time: TimeInterval(defaults.float(forKey: "runPace")))) /mile"
        }
        
        // Set slider values
        t1Slider.setValue(defaults.float(forKey: "t1Pace"), animated: false)
        t2Slider.setValue(defaults.float(forKey: "t2Pace"), animated: false)
        swimSlider.setValue(defaults.float(forKey: "swimPace"), animated: false)
        bikeSlider.setValue(defaults.float(forKey: "bikePace"), animated: false)
        runSlider.setValue(defaults.float(forKey: "runPace"), animated: false)
    }
    
    func setImperialSliderRange() {
        
        bikeSlider.minimumValue = 10
        bikeSlider.maximumValue = 30
        
        runSlider.minimumValue = 240
        runSlider.maximumValue = 960
    }
    
    func setMetricSliderRange() {
        
        bikeSlider.minimumValue = 10
        bikeSlider.maximumValue = 50
        
        runSlider.minimumValue = 165
        runSlider.maximumValue = 600
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
        
        switch usesMetricUnits {
        case true:
            let convertedSwimTime = (savedRace.swimDistance / 100) * swimSlider.value
            swimTotalTime = convertedSwimTime
            
            let convertedBikeSpeed = bikeSlider.value.rounded(.down) / 3.6 // kph to m/s
            let bikeSplit = savedRace.bikeDistance / convertedBikeSpeed
            bikeTotalTime = bikeSplit
            
            let convertedRunSpeed = 16.667 / (runSlider.value / 60) // m/km to m/s
            let runSplit = savedRace.runDistance / convertedRunSpeed
            runTotalTime = runSplit
            
        default:
            let convertedSwimTime = ((savedRace.swimDistance * 1.094) / 100) * swimSlider.value // Yds to meters
            swimTotalTime = convertedSwimTime
            
            let convertedBikeSpeed = bikeSlider.value.rounded(.down) / 2.237 // mph to m/s
            let bikeSplit = savedRace.bikeDistance / convertedBikeSpeed
            bikeTotalTime = bikeSplit
            
            let convertedRunSpeed = 26.822 / (runSlider.value / 60) // m/mi to m/s
            let runSplit = (savedRace.runDistance) / convertedRunSpeed
            runTotalTime = runSplit
        }
    }
    
    func calculateUnsavedSplits() {
        
        let currentRace = receivedRace
        
        switch usesMetricUnits {
        case true:
            let convertedSwimTime = (currentRace.swimDistance / 100) * swimSlider.value
            swimTotalTime = convertedSwimTime
            
            let convertedBikeSpeed = bikeSlider.value.rounded(.down) / 3.6 // kph to m/s
            let bikeSplit = currentRace.bikeDistance / convertedBikeSpeed
            bikeTotalTime = bikeSplit
            
            let convertedRunSpeed = 16.667 / (runSlider.value / 60) // m/km to m/s
            let runSplit = currentRace.runDistance / convertedRunSpeed
            runTotalTime = runSplit
            
        default:
            let convertedSwimTime = ((currentRace.swimDistance * 1.094) / 100) * swimSlider.value // Yds to meters
            swimTotalTime = convertedSwimTime
            
            let convertedBikeSpeed = bikeSlider.value.rounded(.down) / 2.237 // mph to m/s
            let bikeSplit = currentRace.bikeDistance / convertedBikeSpeed
            bikeTotalTime = bikeSplit
            
            let convertedRunSpeed = 26.822 / (runSlider.value / 60) // m/mi to m/s
            let runSplit = (currentRace.runDistance) / convertedRunSpeed
            runTotalTime = runSplit
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
        bikeTime.text = "\(timeString(time: TimeInterval(bikeTotalTime).rounded()))"
        t2Time.text = "\(timeString(time: TimeInterval(t2Slider.value)))"
        runTime.text = "\(timeString(time: TimeInterval(runTotalTime).rounded()))"
        raceTotalTime = accumulateTime
        
        if isSavedRace == false {
            defaults.set(accumulateTime, forKey: "totalRaceTime")
        }
    }
    
    // Update UI with slider values
    @IBAction func swimSliderChanged(_ sender: UISlider) {
        
        // Increments of 5
        let roundedSwimTime = round(swimSlider.value / fiveSecondIncrements) * fiveSecondIncrements
        swimSlider.value = roundedSwimTime
        
        calculateSplits()
        
        if usesMetricUnits {
            swimPace.text = "Swim: \(paceString(time: TimeInterval(swimSlider!.value))) / 100m"
        } else {
            swimPace.text = "Swim: \(paceString(time: TimeInterval(swimSlider!.value))) / 100 yds"
        }
        
        if isSavedRace == false {
            defaults.set(swimSlider.value, forKey: "swimPace")
        }
    }
    
    @IBAction func t1SliderChanged(_ sender: UISlider) {
        
        // Increments of 5 seconds
        let roundedT1Time = round(t1Slider.value / sixtySecondIncrements) * sixtySecondIncrements
        
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
        
        if usesMetricUnits {
            bikePace.text = "Bike: \(Int(bikeSlider.value)) kph"
        } else {
            bikePace.text = "Bike: \(Int(bikeSlider.value)) mph"
        }
        
        if isSavedRace == false {
            defaults.set(bikeSlider.value, forKey: "bikePace")
        }
    }
    
    @IBAction func t2SliderChanged(_ sender: UISlider) {
        
        // Increments of 5
        let roundedT2Time = round(t2Slider.value / sixtySecondIncrements) * sixtySecondIncrements
        
        t2Slider.value = roundedT2Time
        t2TotalTime = roundedT2Time
        t2Pace.text = "T2: \(paceString(time: TimeInterval(t2Slider.value))) mins"
        
        if isSavedRace == false {
            defaults.set(t2Slider.value, forKey: "t2Pace")
        }
        calculateTotalTime()
    }
    
    @IBAction func runSliderChanged(_ sender: UISlider) {
        
        // Increments of 5 seconds
        let roundedRunTime = round(runSlider.value / fiveSecondIncrements) * fiveSecondIncrements
        runSlider.value = roundedRunTime
        
        calculateSplits()
        
        if usesMetricUnits {
            runPace.text = "Run: \(paceString(time: TimeInterval(runSlider!.value))) /km"
        } else {
            runPace.text = "Run: \(paceString(time: TimeInterval(runSlider!.value))) /mile"
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

