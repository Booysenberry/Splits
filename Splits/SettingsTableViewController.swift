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
    
    @IBOutlet weak var imperialCell: UITableViewCell!
    @IBOutlet weak var metricCell: UITableViewCell!
    
    override func viewWillAppear(_ animated: Bool) {
        title = "Settings"
        
        setUnits()
    
    }
    
    func setUnits() {
        switch locale.usesMetricSystem {
        case true:
            setMetricUnits()
        default:
            setImperialUnits()
        }
        checkUserDefaults()
    }
    
    func checkUserDefaults() {
        switch defaults.bool(forKey: "usesMetricSystem") {
        case true:
            setMetricUnits()
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
    }
}
