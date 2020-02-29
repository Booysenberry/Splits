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
    var embeddedVC: RaceSplitsTable!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func didChangeRaceDistance(_ sender: Any) {
        
        switch distanceSelector.selectedSegmentIndex {
            
        case 0:
            race.swimDistance = 500
            race.bikeDistance = 20000
            race.runDistance = 5000
            
        case 1:
            race.swimDistance = 1500
            race.bikeDistance = 40000
            race.runDistance = 10000
            
        case 2:
            race.swimDistance = 2000
            race.bikeDistance = 90000
            race.runDistance = 21100
            
        case 3:
            race.swimDistance = 3800
            race.bikeDistance = 180000
            race.runDistance = 42200
            
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "embeddedSegue") {
            
            if let raceDistanceVC = segue.destination as? RaceSplitsTable {
                raceDistanceVC.receivedRace = race
            }
        }
    }
}
