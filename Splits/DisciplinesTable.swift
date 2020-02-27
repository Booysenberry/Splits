//
//  DisciplinesTable.swift
//  Splits
//
//  Created by Brad Booysen on 28/02/20.
//  Copyright © 2020 Booysenberry. All rights reserved.
//

import UIKit

class DisciplinesTable: UITableViewController {
    
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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Remove unused rows
        tableView.tableFooterView = UIView()

    }
}
