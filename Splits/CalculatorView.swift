//
//  CalculatorView.swift
//  Splits
//
//  Created by Brad Booysen on 27/02/20.
//  Copyright © 2020 Booysenberry. All rights reserved.
//

import UIKit

class CalculatorView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self

    }
    
    // MARK: Tableview Data
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SplitCell") as! SplitsCell
        
        return cell
    }
}
