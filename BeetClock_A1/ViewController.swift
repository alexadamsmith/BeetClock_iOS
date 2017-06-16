//
//  ViewController.swift
//  BeetClock_A1
//
//  Created by user on 10/1/16.
//  Copyright © 2016 BeetWorks. All rights reserved.
//

import UIKit
import CoreData

//class ViewController: UITableViewController {
class ViewController: UITableViewController {

    //This creates an array of work record entities, or instances of the Work_record class declared in its own file
    
    //var cjeDelegate = cropJobEquipDelegator()
    
    var workList = [Work_record]()
    
    var cropList = [Crop]()
    var jobList = [Job]()
    var equipList = [Equipment]()
    var tractorList = [Tractor]()
    
    var colorBank = ColorBank()
    
    //var recordControl = Work_recordController()
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    //var managedContext = appDelegate.managedObjectContext()

    
    func popList() {
        //!
        //Use a single managedObjectContext, stored in appDelegate, for the whole app
        //let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        //let managedContext = appDelegate.managedObjectContext
        let managedContext = appDelegate.managedObjectContext
        
        //Retrieves all crops, jobs or equipment in DB and populates corresp. lists

            let workRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Work_record")
            
            
            //Return all crops, jobs and equipment as cropList, jobList and equipList composed of their respective entity types
            do {
                //Retrieve crops
                let records = try managedContext.fetch(workRequest)
                workList = records as! [Work_record]
                
            } catch let error as NSError {
                // print("Could not fetch crops\(error), \(error.userInfo)")
            }
        
            //self.cjeDelegate.popList(Crop)
            workList = workList.sorted(by: { $0.timestamp > $1.timestamp})
            //Sorts new entries alphebetically; will need time to synch with other functions

        
    }//end popList


    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set the background color
        self.tableView.backgroundColor = colorBank.GetUIColor("background")
        
        
        // Change the navigation bar background color
        navigationController!.navigationBar.barTintColor = colorBank.GetUIColor("navbar")
        
        // Change the color of the navigation bar button items to white.
        navigationController!.navigationBar.tintColor = UIColor.white
        
        
        //This should enable scrolling within the table view - thanks Adam Young!
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 160.0
            tableView.isScrollEnabled = true
        
        //gets work records from DB
        popList()
        
        //print("this is the SelectionView work list:")
        //print(self.workList)
        
        //print URLs
        //let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        //print(urls);
        
        //Use a single managedObjectContext, stored in appDelegate, for the whole app
        //let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
                //Now I will enable editing controls for the table view
        self.navigationItem.rightBarButtonItem =
            self.editButtonItem
    }
    
    //This should run before the view reloads; it should refresh workList to accomodate any deletions or insertions that may have occurred
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        popList()
        self.tableView.reloadData()
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections (in tableView: UITableView) -> Int {
        // Return the number of sections; in this case 1 as a single datatype is being displayed
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        //return self.workRecordControl.entityList.count
        //let recList = cjeDelegate.returnRecord()
        
        let recCount = workList.count
        
       // print("Number of records:")
       // print(workList.count)
        
        return recCount
        //return workList.count
    }
    
    
    //Populate table contents from workList or entityList
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "DisplayRecord", for: indexPath)
    
    // Configure the cell...
        //I probably got carried away using syntax self.xx  Not necessary when var already declared in script!
       // let workList = self.cjeDelegate.returnRecord()
       // let workEntity = workList[indexPath.row]
        
        //Sorting the displayed list aint where its at!  This results in incorrect deletions.  Instead, I must sort the actual list on popList!
        //let workSort = workList.sort({ $0.timestamp > $1.timestamp})
        
        let workEntity = workList[indexPath.row]
        //let workEntity = workSort[indexPath.row]
        
        
        //This enables word wrapping within the cell
        cell.textLabel!.numberOfLines=0
        cell.textLabel!.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        //let workEntity = workList[indexPath.row]
        //Sicne i created a linked database, rather than pulling straight values for crop and job, I need to access the name via the crop name property of a crop object.
    //I'm not sure I have the data objects structured correctly for relationships in the sqlite file.  Instead I will use objects that have no relationships.
        //cell.textLabel?.text = workEntity.cropRelate?.valueForKey("crop_name") as? String
        //cell.detailTextLabel?.text = workEntity.jobRelate?.valueForKey("job_name") as? String
        
    //Workers and millis do display, though the stringValue caughs up extra junk as well
        //cell.textLabel!.text = "Workers: \(workEntity.workers.stringValue), Millis: \(workEntity.ms_worked.stringValue)"
        
        //Formatting timestamp as string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yy"
        let dateFormat = dateFormatter.string(from: Date(timeIntervalSince1970:(workEntity.timestamp/1000)))
        
        
    //Retrieve DB entry and display as text
        cell.textLabel!.text = "Crop: \(workEntity.cropRelate.value(forKey: "crop_name") as! String), Job: \(workEntity.jobRelate.value(forKey: "job_name") as! String), Implement: \(workEntity.equipRelate.value(forKey: "equip_name") as! String), Tractor: \(workEntity.tractorRelate.value(forKey: "tractor_name") as! String), Workers: \(workEntity.workers.stringValue), Hours: \(String(format:"%.2f", workEntity.ms_worked)), On \(dateFormat), Notes: \(workEntity.notes)"
        //Hours: \(workEntity.ms_worked.stringValue),
        
        //print("RECORD "+String(indexPath.row))
        //print(workEntity)
        
        
        //Job: \(workEntity.jobRelate?.valueForKey("job_name") as? String)"
       
        
    //detailTextLabel does not show up in my current cell configuration
        //cell.detailTextLabel?.text = workEntity.ms_worked?.stringValue
        
        
    //\(workEntity.city) ,
    //\(workEntity.region)
    //\(workEntity.postalCode)"
    
    return cell
}

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newItemSegue" {
        //Passing recordControl on from the initial view controller
            //let nav = segue.destinationViewController as! UINavigationController
            //let tvc = nav.topViewController as! NewItemViewController

            //tvc.recordControl = self.workRecordControl
        }
    }//end prepare for segue





    
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
             //Runs when the deletion control is tapped
     if editingStyle == UITableViewCellEditingStyle.delete {
     //Run to get current list of selectable entities, values
     //print("editingStyle.Delete")
        
        //!
        
        //Use a single managedObjectContext, stored in appDelegate, for the whole app
        //let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        //let managedContext = appDelegate.managedObjectContext
        //let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        //Deletes the object and saves
        managedContext.delete(workList[indexPath.row])
        do {
            
            //Removes the selected entity from the list
            self.workList.remove(at: indexPath.row)
            
            //Removes the selected entity from the table view
            self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            
            // Saves the managed object context
            try managedContext.save()
        } catch let error as NSError  {
           // print("Could not save \(error), \(error.userInfo)")
        }
        
        self.popList()
  /*
        
        //Refreshes all Work_records as workList
        let fetchRequest = NSFetchRequest(entityName: "Work_record")
        do {
            let results =
                try managedContext.executeFetchRequest(fetchRequest)
            workList = results as! [Work_record]
            //workList = results as! [NSManagedObject]
        } catch let error as NSError {
           // print("Could not fetch \(error), \(error.userInfo)")
        }
        
        */
        
        
        /*
     self.cjeDelegate.deleteRecord(indexPath.row)
     //self.workRecordControl.removeRecord(indexPath.row)
     
     self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
     //Run again to update list of selectable values after deletion
        self.cjeDelegate.popRecord()
        //self.workRecordControl.popList()
     */
     }//end editing stype = delete
     
     }//end commit editing style
    
    
}

