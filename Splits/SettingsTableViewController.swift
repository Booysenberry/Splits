//
//  SettingsTableViewController.swift
//  Splits
//
//  Created by Brad Booysen on 7/04/20.
//  Copyright © 2020 Booysenberry. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    let locale = Locale.current
    let defaults = UserDefaults.standard
    var usesMetricSystem = true
    var hasChangedUnits = false
    
    @IBOutlet weak var imperialCell: UITableViewCell!
    @IBOutlet weak var metricCell: UITableViewCell!
    
    override func viewWillAppear(_ animated: Bool) {
        
        title = "Settings"
        checkIfUserHasChangedUnits()
    }
    
    func checkIfUserHasChangedUnits() {
        switch defaults.bool(forKey: "hasChangedUnits") {
        case true:
            setUserDefaults()
        default:
            setUnits()
        }
    }
    
    func setUserDefaults() {
        switch defaults.bool(forKey: "usesMetricSystem") {
        case true:
            setMetricUnits()
        default:
            setImperialUnits()
        }
    }
    
    func setUnits() {
        switch locale.usesMetricSystem {
        case true:
            setMetricUnits()
            defaults.set(usesMetricSystem, forKey: "usesMetricSystem")
        default:
            setImperialUnits()
        }
    }
    
    func setMetricUnits() {
        metricCell.accessoryType = .checkmark
        imperialCell.accessoryType = .none
    }
    
    func setImperialUnits() {
        imperialCell.accessoryType = .checkmark
        metricCell.accessoryType = .none
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            usesMetricSystem = false
            defaults.set(usesMetricSystem, forKey: "usesMetricSystem")
            setImperialUnits()
            
        default:
            usesMetricSystem = true
            defaults.set(usesMetricSystem, forKey: "usesMetricSystem")
            setMetricUnits()
        }
        hasChangedUnits = true
        hasSaved()
        
    }
    
    func hasSaved() {
        switch hasChangedUnits {
        case true:
            defaults.set(hasChangedUnits, forKey: "hasChangedUnits")
        default:
            break
        }
    }
}
