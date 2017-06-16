//
//  SummaryViewController.swift
//  BeetClock_A1
//
//  Created by user on 11/12/16.
//  Copyright © 2016 BeetWorks. All rights reserved.
//

import UIKit
import CoreData
import StoreKit


class SummaryViewController: UITableViewController, SKStoreProductViewControllerDelegate {

    var summaryDisplay = SummaryDisplayViewController()

    @IBOutlet weak var buttonCrop: UIButton!
    
    @IBOutlet weak var labelCropName: UILabel!
    @IBOutlet weak var labelStartDate: UILabel!
    
    @IBOutlet weak var buttonDate: UIButton!
    
    @IBOutlet weak var buttonReview: UIButton!
    
    
    //!
    var appDelegate = UIApplication.shared.delegate as! AppDelegate

    var colorBank = ColorBank()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonCrop.backgroundColor = colorBank.GetUIColor("crop")
        buttonDate.backgroundColor = colorBank.GetUIColor("job")
        buttonReview.tintColor = colorBank.GetUIColor("navbar")
        
        //Set the background color
        self.tableView.backgroundColor = colorBank.GetUIColor("background")
        
        
        // Change the navigation bar background color
        navigationController!.navigationBar.barTintColor = colorBank.GetUIColor("navbar")
        
        // Change the color of the navigation bar button items to white.
        navigationController!.navigationBar.tintColor = UIColor.white
        
        
        
        summaryDisplay.popLists()
        
        self.labelCropName.text = "No crop selected"

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    if segue.identifier == "selectCrop"{
    let nav = segue.destination as! UINavigationController
    let tvc = nav.topViewController as! SelectionViewController
    tvc.selectType = "cropWithRecord"
    
    }
            //This opens SummaryDisplay in the container view
            
            if segue.identifier == "summaryContainedSegue" {
                //********
                //http://stackoverflow.com/questions/33857210/access-container-view-child-properties-swift
                //subViewController = segue.destinationViewController as? IPJobsViewController
                summaryDisplay = segue.destination as! SummaryDisplayViewController
            }
    
    }//end prepare for segue
    
    
    //This receives actions after the selection is made
    @IBAction func
        makeSelection(_ segue:UIStoryboardSegue){

        let incoming = segue.source as! SelectionViewController
        
        // let selectedIndex = incoming.selectIndex
        let selectedType = incoming.selectType
        
        if selectedType == "cropWithRecord" {
            //Alter button text to indicate selection
            let nameCrop = incoming.cropList[incoming.listIndex].crop_name
            self.labelCropName.text = "\(nameCrop):"
            
            //Set crop in summaryDisplay
            summaryDisplay.cropSelected = true
            summaryDisplay.cropIndex = incoming.listIndex
            summaryDisplay.summarizeCrop()
            summaryDisplay.tableView.reloadData()

        }
    }// end makeSelection
    
    
    @IBAction func cropSelected(_ sender: AnyObject) {
        
    }
    
    @IBAction func
        doneEditRecords(_ segue:UIStoryboardSegue){
        
    }
    
    @IBAction func
        cancelSelection(_ segue:UIStoryboardSegue){
        
    }
    
    @IBAction func
        cancelExport(_ segue:UIStoryboardSegue){
        
    }
    
    @IBAction func selectDate(_ segue:UIStoryboardSegue){
        
        let incoming = segue.source as! SelectDateViewController
        
        //Set date in summaryDisplay
        summaryDisplay.dateSelected = true
        summaryDisplay.selectedDate = incoming.pickedDate
        summaryDisplay.summarizeCrop()
        summaryDisplay.tableView.reloadData()
        
        
        //Formatting timestamp as string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yy"
        let dateFormat = dateFormatter.string(from: Date(timeIntervalSince1970:(incoming.pickedDate/1000)))
        
        //buttonDate.setTitle("Summary of records since \(dateFormat)", forState: UIControlState.Normal)
        labelStartDate.text = "\(dateFormat)"
        
      //  print("Date selected:")
      //  print(dateFormat)
        
    }

    @IBAction func reviewSelected(_ sender: Any) {

            //Thanks Ramis!!
            let appID = "1184076793"
            let storeViewController = SKStoreProductViewController()
            storeViewController.delegate = self
            
            let parameters = [ SKStoreProductParameterITunesItemIdentifier : appID]
            storeViewController.loadProduct(withParameters: parameters) { [weak self] (loaded, error) -> Void in
                if loaded {
                    // Parent class of self is UIViewContorller
                    self?.present(storeViewController, animated: true, completion: nil)
                }
            }
            
            //UIApplication.shared.openURL(URL(string: "https://itunes.apple.com/us/app/beetclock/id1184076793?mt=8")!)

    }
    
    //Allows this view to delegate to the storeViewController
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    // MARK: - Table view data source
/*Not necessary w/ static cells
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    @IBAction func chooseCrop(sender: AnyObject) {
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
