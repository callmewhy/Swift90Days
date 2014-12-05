//
//  ViewController.swift
//  BirdsCatsDogs
//
//  Created by why on 12/4/14.
//  Copyright (c) 2014 why. All rights reserved.
//

import UIKit

class SpeciesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
        
    var species: [String] = DataManager.sharedInstance.speciesList
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("SpeciesCell") as UITableViewCell
        cell.textLabel?.text = species[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        var racesViewController = storyboard?.instantiateViewControllerWithIdentifier("RacesViewController") as RacesViewController
        racesViewController.species = species[indexPath.row]
        navigationController?.pushViewController(racesViewController, animated: true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return species.count
    }

}

