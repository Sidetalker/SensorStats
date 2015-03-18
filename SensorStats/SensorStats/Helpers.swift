//
//  Helpers.swift
//  SensorStats
//
//  Created by Kevin Sullivan on 3/18/15.
//  Copyright (c) 2015 SideApps. All rights reserved.
//

import UIKit
import CoreData

let managedObjectContext: NSManagedObjectContext? = {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    if let managedObjectContext = appDelegate.managedObjectContext { return managedObjectContext }
    else { return nil } }()

// Inserts an object into the CoreData stack and the new object
func insertObject(name: String) -> AnyObject {
    return NSEntityDescription.insertNewObjectForEntityForName(name, inManagedObjectContext: managedObjectContext!)
}

// Fetches all specified records from the CoreData stack
func getObjects(name: String, predicate: NSPredicate?) -> [AnyObject] {
    let fetchRequest = NSFetchRequest(entityName: name)
    fetchRequest.predicate = predicate
    
    return managedObjectContext!.executeFetchRequest(fetchRequest, error: nil)!
}

// Saves the CoreData stacks
func save() {
    var error : NSError?
    
    managedObjectContext!.save(&error)
    
    if error != nil {
        println(error?.localizedDescription)
    }
}