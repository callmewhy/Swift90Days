//
//  RacesViewController.swift
//  BirdsCatsDogs
//
//  Created by why on 12/5/14.
//  Copyright (c) 2014 why. All rights reserved.
//

import UIKit

class RacesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate {
    
    @IBOutlet weak var myTableView: UITableView!
    
    var species: String!
    var races: [String] {
        return DataManager.sharedInstance.species[species]!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = species
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapAdd() {
        var alert = UIAlertView(title: "New Race", message: "Type in a new race", delegate: self,
            cancelButtonTitle: "Cancel", otherButtonTitles: "Add")
        alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
        alert.show()
    }
    
    // MARK: - UITableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return races.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("RaceCell") as UITableViewCell
        cell.textLabel?.text = races[indexPath.row]
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        var raceToRemove = races[indexPath.row]
        DataManager.sharedInstance.removeRace(species: species, race: raceToRemove)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    // MARK: - UIAlertView
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            var textField = alertView.textFieldAtIndex(0)!
            var newRace = textField.text
            DataManager.sharedInstance.addRace(species: species, race: newRace)
            var newIndexPath = NSIndexPath(forRow: races.count - 1, inSection: 0)
            myTableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
}
