//
//  RacesViewController.swift
//  BirdsCatsDogs
//
//  Created by why on 12/5/14.
//  Copyright (c) 2014 why. All rights reserved.
//

import UIKit

class RacesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return races.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("RaceCell") as UITableViewCell
        cell.textLabel?.text = races[indexPath.row]
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }
}
