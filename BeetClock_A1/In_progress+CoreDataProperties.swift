//
//  In_progress+CoreDataProperties.swift
//  BeetClock_A1
//
//  Created by user on 11/2/16.
//  Copyright © 2016 BeetWorks. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension In_progress {

    @NSManaged var start_time: Double
    @NSManaged var workers: NSNumber
    @NSManaged var cropRelate: Crop
    @NSManaged var jobRelate: Job
    @NSManaged var equipRelate: Equipment
    @NSManaged var tractorRelate: Tractor
    @NSManaged var notes: String

}
