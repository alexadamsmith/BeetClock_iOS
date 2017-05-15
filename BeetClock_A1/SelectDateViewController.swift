//
//  SelectDateViewController.swift
//  BeetClock_A1
//
//  Created by user on 11/13/16.
//  Copyright © 2016 BeetWorks. All rights reserved.
//

import UIKit

class SelectDateViewController: UITableViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var pickedDate = Double()
    
    var colorBank = ColorBank()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set the background color
        self.tableView.backgroundColor = colorBank.GetUIColor("background")
        datePicker.backgroundColor = colorBank.GetUIColor("background")
        
        // Change the navigation bar background color
        navigationController!.navigationBar.barTintColor = colorBank.GetUIColor("navbar")
        
        // Change the color of the navigation bar button items to white.
        navigationController!.navigationBar.tintColor = UIColor.white
        
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func datePicked(_ sender: AnyObject) {
        
        pickedDate = Double(datePicker.date.timeIntervalSince1970 * 1000)
    }
    
    //This blocks the unwind segue if the selections are incomplete.  Thanks Shaun and App Dev Guy!!
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any!) -> Bool {
        if identifier == "unwindWithNewRecord" {
            // perform your computation to determine whether segue should occur
            
            var segueShouldOccur = false
            if pickedDate > 0 {
                segueShouldOccur = true
            }
            
            //Present popup warning if not all conditions for segue are met
            if !segueShouldOccur {
                let alert = UIAlertController(title: "Alert:", message: "Please select a date", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                // prevent segue from occurring
                return false
            }
        }
        return true
    }
    // MARK: - Table view data source
/*
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
 */

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
