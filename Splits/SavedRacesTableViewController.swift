//
//  SavedRacesTableViewController.swift
//  Splits
//
//  Created by Brad Booysen on 26/03/20.
//  Copyright © 2020 Booysenberry. All rights reserved.
//

import UIKit

class SavedRacesTableViewController: UITableViewController {
    
    var savedRacesFromCD = [SavedRace]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Saved Races"
        savedRacesFromCD.removeAll()
        getSavedRaces()
        navigationItem.rightBarButtonItem = editButtonItem
        
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
        cell.raceTimeLabel.text = "\(timeString(time: TimeInterval(savedRacesFromCD[indexPath.row].totalTime)))"
        
        return cell
    }
    
    // Fetch saved races from Core Data
    func getSavedRaces() {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            if let racesFromCD = try? context.fetch(SavedRace.fetchRequest()) {
                if let races = racesFromCD as? [SavedRace] {
                    savedRacesFromCD = races
                    tableView.reloadData()
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRace = savedRacesFromCD[indexPath.row]
        performSegue(withIdentifier: "showSavedRace", sender: selectedRace)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let splitsVC = segue.destination as? RaceSplitsTable {
            if let selectedRace = sender as? SavedRace {
                
                splitsVC.isSavedRace = true
                splitsVC.receivedRace.runPace = selectedRace.runPace
                splitsVC.receivedRace.bikePace = selectedRace.bikePace
                splitsVC.receivedRace.swimPace = selectedRace.swimPace
                splitsVC.receivedRace.t1Time = selectedRace.t1Time
                splitsVC.receivedRace.t2Time = selectedRace.t2Time
                
                if let name = selectedRace.raceName {
                    splitsVC.receivedRace.raceName = name
                }
                
                switch selectedRace.raceType {
                case 0:
                    splitsVC.receivedRace.swimDistance = 500
                    splitsVC.receivedRace.bikeDistance = 20000
                    splitsVC.receivedRace.runDistance = 5000
                    
                case 1:
                    splitsVC.receivedRace.swimDistance = 1500
                    splitsVC.receivedRace.bikeDistance = 40000
                    splitsVC.receivedRace.runDistance = 10000
                    
                case 2:
                    splitsVC.receivedRace.swimDistance = 2000
                    splitsVC.receivedRace.bikeDistance = 90000
                    splitsVC.receivedRace.runDistance = 21100
                    
                case 3:
                    splitsVC.receivedRace.swimDistance = 3800
                    splitsVC.receivedRace.bikeDistance = 180000
                    splitsVC.receivedRace.runDistance = 42200
                    
                default:
                    break
                    
                }
                splitsVC.tableView.reloadData()
            }
        }
    }
    
    
    // Format time string
    func timeString(time: TimeInterval) -> String {
        let hour = Int(time) / 3600
        let minute = Int(time) / 60 % 60
        
        // return formated string
        return String(format: "%02i:%02i", hour, minute)
    }
    
    // Reorder races
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let rowToMove = savedRacesFromCD[sourceIndexPath.row]
        savedRacesFromCD.remove(at: sourceIndexPath.row)
        savedRacesFromCD.insert(rowToMove, at: destinationIndexPath.row)
    }
    
    // Swipe to delete saved race
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
                let race = savedRacesFromCD[indexPath.row]
                context.delete(race)
                (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
                getSavedRaces()
            }
        }
    }
}
