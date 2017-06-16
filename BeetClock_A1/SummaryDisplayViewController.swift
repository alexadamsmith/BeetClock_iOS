//
//  SummaryDisplayViewController.swift
//  BeetClock_A1
//
//  Created by user on 11/12/16.
//  Copyright © 2016 BeetWorks. All rights reserved.
//

import UIKit
import CoreData

class SummaryDisplayViewController: UITableViewController {
    
    
    //!
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //Select a crop
    var cropIndex = Int()
    var cropSelected = false
    
    //Select a date
    var dateSelected = false
    var selectedDate = Double()
    
    //Contains data to be summarized
    var cropList = [Crop]()
    var workList = [Work_record]()
    
    //String names of jobs, equipment, tractors in selectWork
    var jobSummary = [String]()
    var equipSummary = [String]()
    var tractorSummary = [String]()
    
    //Tallies of hours
    var totalHours = Double()
    var jobHours = [Double]()
    var equipHours = [Double]()
    var tractorHours = [Double]()
    
    //String summary outputs
    var outSummary = [String]()
    
    var colorBank = ColorBank()
    
    
    //Return all crops and work records
    func popLists() {
        
        let managedContext = appDelegate.managedObjectContext
        /*
        let cropRequest = NSFetchRequest(entityName: "Crop")
        do {
            //Retrieve crops
            let crops = try managedContext.executeFetchRequest(cropRequest)
            cropList = crops as! [Crop]
            cropList = cropList.sort{$0.crop_name < $1.crop_name}
        } catch let error as NSError {
            //  print("Could not fetch crops\(error), \(error.userInfo)")
        }
        */

        cropList = []
        
        var allCrops = [Crop]()
        
        let cropRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Crop")
        do {
            //Retrieve crops
            let crops = try managedContext.fetch(cropRequest)
            allCrops = crops as! [Crop]
            allCrops = allCrops.sorted{$0.crop_name < $1.crop_name}
        } catch let error as NSError {
            //  print("Could not fetch crops\(error), \(error.userInfo)")
        }
        
        var allWork = [Work_record]()
        
        let workRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Work_record")
        
        do {
            //Retrieve crops
            let records = try managedContext.fetch(workRequest)
            allWork = records as! [Work_record]
            
        } catch let error as NSError {
            // print("Could not fetch crops\(error), \(error.userInfo)")
        }
        
        //Now put only those crops which have records into the displayed crop list
        if (allWork.count > 0 && allCrops.count > 0){
            for i in 0...(allCrops.count - 1){
                var records = 0
                for j in 0...(allWork.count - 1){
                    
                    if (allWork[j].cropRelate.value(forKey: "crop_name") as! String == allCrops[i].crop_name) {
                        records = records + 1
                    }
                }
                if records > 0 {
                    cropList.append(allCrops[i])
                }
            }
        }//end if work and if crop
        
        //Sort the crop list for display
        cropList = cropList.sorted{$0.crop_name < $1.crop_name}


    }//end popLists
    
    
    
    func summarizeCrop(){
        
        let managedContext = appDelegate.managedObjectContext
        
        self.popLists()
        
        //Clear the lists of selected records, jobs, equipment, tractors, display entries
        workList = []
        jobSummary = []
        equipSummary = []
        tractorSummary = []
        outSummary = []
        
        //Clear out hours arrays
        totalHours = 0
        jobHours = []
        equipHours = []
        tractorHours = []

        if cropSelected {
            //let cropName = cropList[cropIndex].crop_name
            let cropSelect = cropList[cropIndex]
            
            let workRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Work_record")
            let cropPredicate = NSPredicate(format: "cropRelate == %@", cropSelect)
            if dateSelected {
                //If date selected, search by crop and date with a compound predicate
                let predSelect = NSNumber(value: selectedDate as Double)
                let datePredicate = NSPredicate(format: "%K > %@", "timestamp", predSelect)
                //Create a compound predicate as workPred AND datePred
                let workDatePredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [cropPredicate, datePredicate])
                workRequest.predicate = workDatePredicate
                //workRequest.predicate = NSPredicate(format: "%K > %@ && cropRelate == %@", "timestamp", predSelect, cropSelect)
                //Previously timestamp > %@
            } else { //Otherwise search by crop only
                workRequest.predicate = cropPredicate
            }
            
            do {
                //Retrieve crops
                let records = try managedContext.fetch(workRequest)
                workList = records as! [Work_record]
            } catch let error as NSError {
            //    print("Could not fetch work records\(error), \(error.userInfo)")
            }
            if workList.count > 0 {
            //The first go-around will construct lists of all unique jobs, equipment and tractors
            for i in 0...(workList.count - 1){

                //First see if job, equip and tractor for this entry already exist in lists.  If not, add them
                    var newJob = true
                    var newEquip = true
                    var newTractor = true
                
                let jobName = workList[i].jobRelate.value(forKey: "job_name") as! String
                let equipName = workList[i].equipRelate.value(forKey: "equip_name") as! String
                let tractorName = workList[i].tractorRelate.value(forKey: "tractor_name") as! String
                    
                    if jobSummary.count > 0 {
                        for j in 0...(jobSummary.count - 1){
                            if jobName == jobSummary[j]{
                                newJob = false
                            }
                        }
                 }
                        if equipSummary.count > 0 {
                            for j in 0...(equipSummary.count - 1){
                                if equipName == equipSummary[j]{
                                    newEquip = false
                                }
                            }
                 }
                            if tractorSummary.count > 0 {
                                for j in 0...(tractorSummary.count - 1){
                                    if tractorName == tractorSummary[j]{
                                        newTractor = false
                                    }
                                }
                 }
                //Add unlisted job, equip or tractor to lists
                if newJob {
                    jobSummary.append(jobName)
                    //outSummary.append(jobName)
                }
                if newEquip {
                    equipSummary.append(equipName)
                    //outSummary.append(equipName)
                }
                if newTractor {
                    tractorSummary.append(tractorName)
                    //outSummary.append(tractorName)
                }

                //Finally, compile total hours worked on that crop
                totalHours = totalHours + (workList[i].ms_worked * Double(workList[i].workers))
                
            }//end for workList
            }//end if workList > 0
            
            
            outSummary.append("Total hours worked: \(String(format:"%.2f", totalHours))")
            outSummary.append("")
            
            //The second go-around will tally hours worked within each category and append them to the output array
            //jobs
            if workList.count > 0 && jobSummary.count > 0 {
            for i in 0...(jobSummary.count - 1){
                var hours = Double(0)
            for j in 0...(workList.count - 1){
                if workList[j].jobRelate.value(forKey: "job_name") as! String == jobSummary[i] {
                    hours = hours + (workList[j].ms_worked  * Double(workList[j].workers))
                }
                }
                
                jobHours.append(hours)
                outSummary.append("\(jobSummary[i]) hours: \(String(format:"%.2f", hours))")
                
            }//end jobSummary for
                outSummary.append("")
            }//end >0 if
            
            //equipment
            if workList.count > 0 && equipSummary.count > 0 {
                var hasEquip = false
                for i in 0...(equipSummary.count - 1){
                        var hours = Double(0)
                    for j in 0...(workList.count - 1){  
                        if workList[j].equipRelate.value(forKey: "equip_name") as! String == equipSummary[i] {
                            hours = hours + workList[j].ms_worked
                        }
                    }
                    if equipSummary[i] != "No Implement" {
                        hasEquip = true
                    equipHours.append(hours)
                    outSummary.append("\(equipSummary[i]) hours: \(String(format:"%.2f", hours))")
                    } //end if no implement
                }//end equipSummary for
                    if hasEquip {
                        outSummary.append("")
                    }
            }//end >0 if
            
            //tractors
            if workList.count > 0 && tractorSummary.count > 0 {
                var hasTractor = false
                for i in 0...(tractorSummary.count - 1){
                    var hours = Double(0)
                    for j in 0...(workList.count - 1){
                        if workList[j].tractorRelate.value(forKey: "tractor_name") as! String == tractorSummary[i] {
                            hours = hours + workList[j].ms_worked
                        }
                    }
                    if tractorSummary[i] != "No Tractor" {
                        hasTractor = true
                    tractorHours.append(hours)
                    outSummary.append("\(tractorSummary[i]) hours: \(String(format:"%.2f", hours))")
                    }
                }//end jobSummary for
                if hasTractor {
                    outSummary.append("")
                }
            }//end >0 if
        
            if workList.count > 0 {
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM-dd-yy"
                
                
                for i in 0...(workList.count-1) {
                    
                    //Same formatting as in all records view
                    let dateFormat = dateFormatter.string(from: Date(timeIntervalSince1970:(workList[i].timestamp/1000)))
                    
                    outSummary.append("Crop: \(workList[i].cropRelate.value(forKey: "crop_name") as! String), Job: \(workList[i].jobRelate.value(forKey: "job_name") as! String), Implement: \(workList[i].equipRelate.value(forKey: "equip_name") as! String), Tractor: \(workList[i].tractorRelate.value(forKey: "tractor_name") as! String), Workers: \(workList[i].workers.stringValue), Hours: \(String(format:"%.2f", workList[i].ms_worked)), On \(dateFormat), Notes: \(workList[i].notes)")
                    
                }//end for workList
            }//end >0 if
            
            
            
        }// end if crop selected
        }//end summarize crop
    

    override func viewDidLoad() {
        super.viewDidLoad()

        //Set the background color
        self.tableView.backgroundColor = colorBank.GetUIColor("background")
        
        
        //This should enable scrolling within the table view - thanks Adam Young!
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50.0
        tableView.isScrollEnabled = true
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.popLists()
        //self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return outSummary.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "displaySummary", for: indexPath)
        
        let summaryLine = outSummary[indexPath.row]
        
        //This enables word wrapping within the cell
        cell.textLabel!.numberOfLines=0
        cell.textLabel!.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.textLabel!.text = summaryLine
    
        //cell.textLabel!.adjustsFontSizeToFitWidth = true
/*
        let workEntity = workList[indexPath.row]
        //let workEntity = selectWork[indexPath.row]

        
        
        //Formatting timestamp as string
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yy"
        let dateFormat = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970:(workEntity.timestamp/1000)))
        
        //set text
        cell.textLabel!.text = "Crop: \(workEntity.cropRelate.valueForKey("crop_name") as! String), Job: \(workEntity.jobRelate.valueForKey("job_name") as! String), Equip: \(workEntity.equipRelate.valueForKey("equip_name") as! String), Tractor: \(workEntity.tractorRelate.valueForKey("tractor_name") as! String), Workers: \(workEntity.workers.stringValue), Hours: \(String(format:"%.2f", workEntity.ms_worked)), On \(dateFormat)"
*/
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
