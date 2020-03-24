//
//  CalculatorView.swift
//  Splits
//
//  Created by Brad Booysen on 28/02/20.
//  Copyright © 2020 Booysenberry. All rights reserved.
//

import UIKit
import CoreData

class CalculatorView: UIViewController {
    
    @IBOutlet weak var distanceSelector: UISegmentedControl!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var menuLeadingConstraint: NSLayoutConstraint!
    
    var race = Race()
    var menuShowing = false
    let defaults = UserDefaults.standard
    let notificatioCentre = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuShowing = false
        
        // Menu initial position
        menuLeadingConstraint.constant = -260
        
        // Menu border radius and colour
        menuView.layer.cornerRadius = 3
        menuView.layer.borderWidth = 1.5
        menuView.layer.borderColor = UIColor.systemGray3.cgColor
    
        
        // Remember last race distance and load it
        distanceSelector.selectedSegmentIndex = defaults.integer(forKey: "raceType")
        didChangeRaceDistance(UIButton())
        
        // Notification when app moves to background
        notificatioCentre.addObserver(self, selector: #selector(saveCurrentRaceType), name: UIApplication.willResignActiveNotification, object: nil)
        
        // Notification when app terminates
        notificatioCentre.addObserver(self, selector: #selector(saveCurrentRaceType), name: UIApplication.willTerminateNotification, object: nil)
        
    }
    
    @IBAction func didChangeRaceDistance(_ sender: Any) {
        
        let raceDistanceVC = self.children.first as! RaceSplitsTable
        
        switch distanceSelector.selectedSegmentIndex {
            
        case 0:
            raceDistanceVC.receivedRace.swimDistance = 500
            raceDistanceVC.receivedRace.bikeDistance = 20000
            raceDistanceVC.receivedRace.runDistance = 5000
            
        case 1:
            raceDistanceVC.receivedRace.swimDistance = 1500
            raceDistanceVC.receivedRace.bikeDistance = 40000
            raceDistanceVC.receivedRace.runDistance = 10000
            
        case 2:
            raceDistanceVC.receivedRace.swimDistance = 2000
            raceDistanceVC.receivedRace.bikeDistance = 90000
            raceDistanceVC.receivedRace.runDistance = 21100
            
        case 3:
            raceDistanceVC.receivedRace.swimDistance = 3800
            raceDistanceVC.receivedRace.bikeDistance = 180000
            raceDistanceVC.receivedRace.runDistance = 42200
            
        default:
            break
        }
        raceDistanceVC.tableView.reloadData()
        raceDistanceVC.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "embeddedSegue") {
            
            let raceDistanceVC = segue.destination as! RaceSplitsTable
            raceDistanceVC.receivedRace.swimDistance = 500
            raceDistanceVC.receivedRace.bikeDistance = 20000
            raceDistanceVC.receivedRace.runDistance = 5000
        }
    }
    
    @IBAction func saveRace(_ sender: Any) {
        
        let alert = UIAlertController(title: "Race name?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Input the name of the race here"
        })

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in

            if let name = alert.textFields?.first?.text {
                self.defaults.set(name, forKey: "raceName")
            }
        }))

        self.present(alert, animated: true)
        
        saveToCoreData()
    }
    
    //MARK: - Toggle menu
    @IBAction func menuButtonTapped(_ sender: Any) {

            if menuShowing {
                menuLeadingConstraint.constant = -260
            } else {
                menuLeadingConstraint.constant = 0
                UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
                    self.view.layoutIfNeeded()
                })
            }
            menuShowing = !menuShowing
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            menuLeadingConstraint.constant = -260
            menuShowing = false
        }

    func saveToCoreData() {
        
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            let race = SavedRace(context: context)
            
            race.swimPace = defaults.float(forKey: "swimPace")
            race.t1Time = defaults.float(forKey: "t1Pace")
            race.bikePace = defaults.float(forKey: "bikePace")
            race.t2Time = defaults.float(forKey: "t2Pace")
            race.runPace = defaults.float(forKey: "runPace")
            race.raceType = Int32(defaults.integer(forKey: "raceType"))
            race.raceName = defaults.string(forKey: "raceName")
            
            // Save to core data
            (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
        }
    }
    
    @objc func saveCurrentRaceType() {
        defaults.set(distanceSelector.selectedSegmentIndex, forKey: "raceType")
    }
}


