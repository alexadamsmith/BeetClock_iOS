//
//  IPJobsViewController.swift
//  BeetClock_A1
//
//  Created by user on 11/3/16.
//  Copyright © 2016 BeetWorks. All rights reserved.
//

import UIKit
import CoreData

/*
//Converts millis date to readable format - thanks dvdblk!!
typealias UnixTime = Int32

extension UnixTime {
    private func formatType(form: String) -> NSDateFormatter {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        dateFormatter.dateFormat = form
        return dateFormatter
    }
    var dateFull: NSDate {
        return NSDate(timeIntervalSince1970: Double(self))
    }
    var toHour: String {
        return formatType("HH:mm").stringFromDate(dateFull)
    }
    var toDay: String {
        return formatType("MM/dd/yyyy").stringFromDate(dateFull)
    }
}
 */

class IPJobsViewController: UITableViewController {
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var colorBank = ColorBank()
    
    //Array of jobs in progress
    var jobList = [In_progress]()
    
    //Selected row
    var rowSelected = 0
    


    
    func getJobs () {
        //Loads all jobs in progress from DB
        let managedContext = appDelegate.managedObjectContext
        
        //First clear job list
        jobList = []
        
        //Request objects of name In_progress
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "In_progress")
        
        //Return all Work_records as jobList
        do {
            let results =
                try managedContext.fetch(fetchRequest)
            self.jobList = results as! [In_progress]
            
        } catch let error as NSError {
        //    print("Could not fetch \(error), \(error.userInfo)")
        }
    }//end getJobs
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Clear jobList to limit # cells
        jobList = []
        
        //Set the background color
        self.tableView.backgroundColor = colorBank.GetUIColor("background")
        
        
        
        
        //Set the background color
        self.tableView.backgroundColor = colorBank.GetUIColor("background")
        
        //This should enable scrolling within the table view - thanks Adam Young!
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160.0
        tableView.isScrollEnabled = true

        self.getJobs()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        self.getJobs()
        self.tableView.reloadData()
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
        return jobList.count
    }

    
    
    //This gets current date/time in millis; Thanks Rajan Maneshwari!
    func getCurrentMillis()->Double{
        return  Double(Date().timeIntervalSince1970 * 1000)
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "displayJob", for: indexPath)

        let jobEntity = jobList[indexPath.row]
        //This enables word wrapping within the cell
        cell.textLabel!.numberOfLines=0
        cell.textLabel!.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        let startTime = jobEntity.start_time
        let currentTime = getCurrentMillis()
        let elapsedHours = Double((currentTime - startTime) / 3600000)
        
        cell.textLabel!.text = "Crop: \(jobEntity.cropRelate.value(forKey: "crop_name") as! String), Job: \(jobEntity.jobRelate.value(forKey: "job_name") as! String), Equip: \(jobEntity.equipRelate.value(forKey: "equip_name") as! String), Tractor: \(jobEntity.tractorRelate.value(forKey: "tractor_name") as! String), Workers: \(jobEntity.workers.stringValue), Started \(String(format:"%.2f", elapsedHours)) hours ago"
        //Start time: \(jobEntity.start_time.stringValue)"

        return cell
    }
    
    
    //This will delete tapped cells from the in progress DB and update the table view
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        rowSelected = indexPath.row
        
        //Call notification
         NotificationCenter.default.post(name: Notification.Name(rawValue: "addRecord"), object: nil)
        
        
        
        //Now we can delete the in-progress job from jobList and save
        let managedContext = appDelegate.managedObjectContext
        managedContext.delete(jobList[indexPath.row])
        do {
            
            //Removes the selected entity from the list
            self.jobList.remove(at: indexPath.row)
            
            //Removes the selected entity from the table view
            self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            
            // Saves the managed object context
            try managedContext.save()
        } catch let error as NSError  {
         //   print("Could not save \(error), \(error.userInfo)")
        }
        
        
        
        
    }// end didSelectRow

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
