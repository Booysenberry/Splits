//
//  SavedRacesTableView.swift
//  Splits
//
//  Created by Brad Booysen on 25/03/20.
//  Copyright © 2020 Booysenberry. All rights reserved.
//

import UIKit

class SavedRacesTableView: UITableViewController {
    
    var savedRacesFromCD = [SavedRace]()

    override func viewDidLoad() {
        getSavedRaces()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedRacesFromCD.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "savedRaceCell") as! SavedRaceCell

        cell.raceNameLabel.text = savedRacesFromCD[indexPath.row].raceName

        return cell
    }
    
    // Fetch saved races from Core Data
    func getSavedRaces() {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            if let racesFromCD = try? context.fetch(SavedRace.fetchRequest()) {
                if let races = racesFromCD as? [SavedRace] {
                    savedRacesFromCD = races
                }
            }
        }
    }
}
