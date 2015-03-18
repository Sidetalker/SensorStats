//
//  DataEntry.swift
//  SensorStats
//
//  Created by Kevin Sullivan on 3/18/15.
//  Copyright (c) 2015 SideApps. All rights reserved.
//

import Foundation
import CoreData

class DataEntry: NSManagedObject {

    @NSManaged var lat: NSNumber
    @NSManaged var long: NSNumber
    @NSManaged var altitude: NSNumber
    @NSManaged var floor: NSNumber
    @NSManaged var horizAcc: NSNumber
    @NSManaged var verAcc: NSNumber
    @NSManaged var speed: NSNumber
    @NSManaged var course: NSNumber
    @NSManaged var gyroX: NSNumber
    @NSManaged var gyroY: NSNumber
    @NSManaged var gyroZ: NSNumber
    @NSManaged var accX: NSNumber
    @NSManaged var accY: NSNumber
    @NSManaged var accZ: NSNumber
    @NSManaged var session: Session

}
