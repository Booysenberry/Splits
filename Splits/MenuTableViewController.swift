//
//  MenuTableViewController.swift
//  Splits
//
//  Created by Brad Booysen on 26/03/20.
//  Copyright © 2020 Booysenberry. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController {
    
    @IBOutlet weak var savedRacesCell: UITableViewCell!
    @IBOutlet weak var settingsCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide empty cells
        tableView.tableFooterView = UIView()
        
        settingsCell.imageView?.image = UIImage(named: "settings")
        savedRacesCell.imageView?.image = UIImage(named: "save")
        
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
}
