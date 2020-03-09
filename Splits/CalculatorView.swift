//
//  CalculatorView.swift
//  Splits
//
//  Created by Brad Booysen on 28/02/20.
//  Copyright © 2020 Booysenberry. All rights reserved.
//

import UIKit

class CalculatorView: UIViewController {
    
    @IBOutlet weak var distanceSelector: UISegmentedControl!
    
    var race = Race()
    var embeddedVC: RaceSplitsTable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
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
}
