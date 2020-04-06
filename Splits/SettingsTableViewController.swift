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
    var usesMetricSystem: Bool? = nil
    
    @IBOutlet weak var imperialCell: UITableViewCell!
    @IBOutlet weak var metricCell: UITableViewCell!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Settings"
        
        if usesMetricSystem != nil {
            setInitialUnits()
        } else {
            setSavedDefaults()
        }
    }
    
    func setInitialUnits() {
        switch locale.usesMetricSystem {
        case true :
            metricCell.accessoryType = .checkmark
            imperialCell.accessoryType = .none
            usesMetricSystem = true
        default:
            imperialCell.accessoryType = .checkmark
            metricCell.accessoryType = .none
            usesMetricSystem = false
        }
    }
    
    func setSavedDefaults() {
        switch defaults.bool(forKey: "usesMetricSystem") {
        case true:
            metricCell.accessoryType = .checkmark
            imperialCell.accessoryType = .none
        default:
            imperialCell.accessoryType = .checkmark
            metricCell.accessoryType = .none
        }
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
            imperialCell.accessoryType = .checkmark
            metricCell.accessoryType = .none
            
        default:
            usesMetricSystem = true
            defaults.set(usesMetricSystem, forKey: "usesMetricSystem")
            metricCell.accessoryType = .checkmark
            imperialCell.accessoryType = .none
        }
    }
}
