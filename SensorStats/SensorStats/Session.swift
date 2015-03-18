//
//  Session.swift
//  SensorStats
//
//  Created by Kevin Sullivan on 3/18/15.
//  Copyright (c) 2015 SideApps. All rights reserved.
//

import Foundation
import CoreData

class Session: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var date: NSDate
    @NSManaged var data: DataEntry

}
