//
//  Job+CoreDataProperties.swift
//  BeetClock_A1
//
//  Created by user on 10/1/16.
//  Copyright © 2016 BeetWorks. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Job {

    @NSManaged var job_name: String
    @NSManaged var recordRelate: NSSet
    @NSManaged var progressRelate: NSSet

}
