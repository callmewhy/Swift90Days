//
//  DataManager.swift
//  BirdsCatsDogs
//
//  Created by why on 12/5/14.
//  Copyright (c) 2014 why. All rights reserved.
//

import Foundation

class DataManager {
    
    
    var species: [String:[String]]
    
    var speciesList: [String] {
        var list: [String] = []
        for speciesName in species.keys {
            list.append(speciesName)
        }
        list.sort(<)
        return list
    }
    
    init() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let speciesInfo = userDefaults.valueForKey("species") as? [String:[String]] {
            species = speciesInfo
        } else {
            species = [
                "Birds": ["Swift"],
                "Cats" : ["Persian Cat"],
                "Dogs" : ["Labrador Retriever"]
            ]
        }
    }

    struct Static {
        static var onceToken : dispatch_once_t = 0
        static var instance : DataManager? = nil
    }
    
    class var sharedInstance : DataManager {
        dispatch_once(&Static.onceToken) {
            Static.instance = DataManager()
        }
        return Static.instance!
    }
    
    func saveData() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setValue(species, forKey: "species")
    }
    
    func addRace(species inSpecies: String, race: String) {
        if var races = species[inSpecies] {
            races.append(race)
            species[inSpecies] = races
        }
        
        saveData()
    }
    
    func removeRace(species inSpecies: String, race inRace: String) {
        if var races = species[inSpecies] {
            var index = -1
            
            for (idx, race) in enumerate(races) {
                if race == inRace {
                    index = idx
                    break
                }
            }
            
            if index != -1 {
                races.removeAtIndex(index)
                species[inSpecies] = races
                saveData()
            }
            
        }
    }


}