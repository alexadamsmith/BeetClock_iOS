//
//  TimerViewController.swift
//  BeetClock_A1
//
//  Created by user on 11/2/16.
//  Copyright © 2016 BeetWorks. All rights reserved.
//

import UIKit
import CoreData

class TimerViewController: UITableViewController {
    
    //Access to the managed object context
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //These buttons trigger segues
    @IBOutlet weak var timerCrop: UIButton!
    @IBOutlet weak var timerJob: UIButton!
    @IBOutlet weak var timerEquip: UIButton!
    @IBOutlet weak var timerTractor: UIButton!

    @IBOutlet weak var cropSelectedLabel: UILabel!
    @IBOutlet weak var jobSelectedLabel: UILabel!
    @IBOutlet weak var implementSelectedLabel: UILabel!
    @IBOutlet weak var tractorSelectedLabel: UILabel!
    
    //Container view
    @IBOutlet weak var ipContainer: UIView!
    
    //# workers and notes text entry
    @IBOutlet weak var timerWorkers: UITextField!
    @IBOutlet weak var timerNotes: UITextField!
    
    
    
    //In progress jobs table view
    //***************
    /*
    //https://github.com/codepath/ios_guides/wiki/container-view-controllers-quickstart
    private var subViewController: UIViewController? {
        didSet {
            updateActiveViewController()
        }
    }
    */
    
    //CJE lists
    var cropList = [Crop]()
    var jobList = [Job]()
    var equipList = [Equipment]()
    var tractorList = [Tractor]()
    
    var colorBank = ColorBank()
    
    //Jobs in progress
    //var ipJobs = self.ipContainer.childViewControllers[0] as! IPJobsViewController
    var ipJobs = IPJobsViewController()


    
    //Rather than triggering a segue, this button will trigger an action within the scene
    @IBOutlet weak var timerStart: UIButton!

    
    //add target in DidLoad
    
    //Params are crop, job, equipment, timeworked, workers
    var workParams = [0,0,0,0,1]
    
    //Accepting selected type from SelectionView; will use to assign index values to workParams
    var selectedType = String()

    //These booleans used to determine if inputs have been made
    var cropSelected = false
    var jobSelected = false
    
    
    //************
    //https://github.com/codepath/ios_guides/wiki/container-view-controllers-quickstart
    /*
    private func updateActiveViewController() {
        if let activeVC = subViewController {
            // call before adding child view controller's view as subview
            addChildViewController(activeVC)
            
            activeVC.view.frame = ipContainer.bounds
            ipContainer.addSubview(activeVC.view)

            activeVC.didMoveToParentViewController(self)
        }
    }
    
    */
    
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the button colors
        timerCrop.backgroundColor = colorBank.GetUIColor("crop")
        timerJob.backgroundColor = colorBank.GetUIColor("job")
        timerEquip.backgroundColor = colorBank.GetUIColor("implement")
        timerTractor.backgroundColor = colorBank.GetUIColor("tractor")
        timerStart.backgroundColor = colorBank.GetUIColor("navbar")
        
        //Set the background color
        self.tableView.backgroundColor = colorBank.GetUIColor("background")
        
        
        // Change the navigation bar background color
        navigationController!.navigationBar.barTintColor = colorBank.GetUIColor("navbar")
        
        // Change the color of the navigation bar button items to white.
        navigationController!.navigationBar.tintColor = UIColor.white

        
        //########### Get system icon for use in UIButton
        
        
        
        //Sets up a notification receiver to get triggered when an in-progress job is selected
        NotificationCenter.default.addObserver(self, selector: #selector(TimerViewController.addRecord(_:)), name:NSNotification.Name(rawValue: "addRecord"), object: nil)
        
        //Executes a function when the workers field is changed
        timerWorkers.addTarget(self, action: #selector(TimerViewController.workersEntered(_:)), for: UIControlEvents.editingChanged)
        
        //Sets equipment and tractor defaults
        //equipTractorDefault()
        databaseDefault()
        
        //Add the list of active jobs as a child view controller
        //subViewController = ipJobs
        
        
        //THIS CAN SET TEXT IN EXISTING VIEW ELEMENTS
        //self.helloLabel.text = @"default text";
        //[self.clickyButton setTitle:@"Clicky" forState:UIControlStateNormal];
        
        //self.startPressed(timerStart)
        //timerStart.addTarget(self, action: "saveClicked:", forControlEvents: .TouchUpInside)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
/* Not necessary given static cells
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
 */
    
    func workersEntered(_ txtWorkers: UITextField) {
        if timerWorkers.text != "" {
            //Set of non-numeric characters to check text box against - thanks TwoStraws!!
            let badCharacters = CharacterSet.decimalDigits.inverted
            
            if txtWorkers.text!.rangeOfCharacter(from: badCharacters) == nil {
                self.workParams[4] = Int(timerWorkers.text!)!
            } else {
                let alert = UIAlertController(title: "Alert:", message: "This field only accepts numbers", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                
                //Removes the most recently entered character which is not of the appropriate char set
                let entry = txtWorkers.text
                let truncated = String(entry!.characters.dropLast())
                txtWorkers.text = truncated
                
            }//end bad character else
        }//end if timeWorkers contains characters
    }//end workersEntered
    
    
    
    //This gets current date/time in millis; Thanks Rajan Maneshwari!
    func getCurrentMillis()->Double{
        return  Double(Date().timeIntervalSince1970 * 1000)
    }
    
    
    //Saves data to In_progress when the START button is clicked
    //Created in the storyboard as an action
    @IBAction func startPressed(_ sender: AnyObject) {
    //func saveClicked() {
        //Opens the managed object context
        let managedContext = appDelegate.managedObjectContext
        
        //print("START PRESSED!!!")
        
        //checks if all values have been selected
        if cropSelected && jobSelected {
        
        //Worker values already entered into array on edit
        //if timerWorkers.text != "" {
        //self.workParams[3] = Int(timerWorkers.text!)!
        //}
        //Populating lists of CJE from DB
        let cropRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Crop")
        let jobRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Job")
        let equipRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Equipment")
        let tractorRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tractor")
        
        do {
            //Retrieve CJE
            let crops = try managedContext.fetch(cropRequest)
            cropList = crops as! [Crop]
                cropList = cropList.sorted{$0.crop_name < $1.crop_name}
            let jobs = try managedContext.fetch(jobRequest)
            jobList = jobs as! [Job]
                jobList = jobList.sorted{$0.job_name < $1.job_name}
            let equips = try managedContext.fetch(equipRequest)
            equipList = equips as! [Equipment]
                equipList = equipList.sorted{$0.equip_name < $1.equip_name}
            let tractors = try managedContext.fetch(tractorRequest)
            tractorList = tractors as! [Tractor]
                tractorList = tractorList.sorted{$0.tractor_name < $1.tractor_name}
            
        } catch let error as NSError {
          //  print("Could not fetch \(error), \(error.userInfo)")
        }
        
        
        //This inserts a new In_progress entity into the managed object context
        let entity =  NSEntityDescription.entity(forEntityName: "In_progress", in:managedContext)
        let record = In_progress(entity: entity!, insertInto: managedContext)
        //let record = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        
        //Sets values in the In_progress entity based on workParams
        record.setValue(cropList[workParams[0]], forKey: "cropRelate")
        record.setValue(jobList[workParams[1]], forKey: "jobRelate")
        record.setValue(equipList[workParams[2]], forKey: "equipRelate")
        record.setValue(tractorList[workParams[3]], forKey: "tractorRelate")
        record.setValue(workParams[4], forKey: "workers")
        record.setValue(timerNotes.text!, forKey: "notes")
        
        
        //Sets the start_time value from the current system time
        let startTime = Double(getCurrentMillis())
        //had ot cast getCurrrentMillis to Int becaues setValue would not accept Int64
        record.setValue(startTime, forKey: "start_time")

        
        do {
            // Save the managed object context
            try managedContext.save()
        } catch let error as NSError  {
          //  print("Could not save \(error), \(error.userInfo)")
        }
        
        //Refreshes data in ipJobs by forcing viewWillAppear state
        self.ipJobs.viewWillAppear(true)
        //self.subViewController!.viewWillAppear(true)
            
            //Displays popup notice alarting to start of job!
            let alert = UIAlertController(title: "Timer started!", message: "Tap entry below to stop", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            
        
        } else {
            //If start conditions are not met, display a message.
            let alert = UIAlertController(title: "Alert:", message: "Please complete all fields before starting work", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }//end if start conditions met
        
    }//end START
    
    
    
    
    
    
    func databaseDefault() {
        
        let managedContext = appDelegate.managedObjectContext
        
        //Populating lists of CJE from DB
        let cropRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Crop")
        let jobRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Job")
        let equipRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Equipment")
        let tractorRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tractor")
        
        do {
            //Retrieve CJE
            let crops = try managedContext.fetch(cropRequest)
            cropList = crops as! [Crop]
                cropList = cropList.sorted{$0.crop_name < $1.crop_name}
            let jobs = try managedContext.fetch(jobRequest)
            jobList = jobs as! [Job]
                 jobList = jobList.sorted{$0.job_name < $1.job_name}
            let equips = try managedContext.fetch(equipRequest)
            equipList = equips as! [Equipment]
                equipList = equipList.sorted{$0.equip_name < $1.equip_name}
            let tractors = try managedContext.fetch(tractorRequest)
            tractorList = tractors as! [Tractor]
                tractorList = tractorList.sorted{$0.tractor_name < $1.tractor_name}
        } catch let error as NSError {
          //  print("Could not fetch \(error), \(error.userInfo)")
        }
        
        //Populate jobs from list
        if jobList.count == 0 {
            
            var jobListMaster = [String]()
            
            let soilPrepJobs = ["Disk", "Chisel", "Rototill", "Bedform", "Spread fertilizer", "Spread manure/ compost", "Other", "Plastic mulch/ drip"]
            for i in 0...(soilPrepJobs.count - 1) {
                jobListMaster.append("Soil prep: "+soilPrepJobs[i])
            }
            
            jobListMaster.append("Seed/transplant: Seed in field")
            jobListMaster.append("Seed/transplant: Transplant")
            
            let cultivationJobs = ["Row cover on/ off", "Hoe","Handweed","Vegetable mulch","Irrigate","Tractor cultivate","Sidedress", "Spray", "Flame weed", "Other"]
            for i in 0...(cultivationJobs.count - 1) {
                jobListMaster.append("Cultivation: "+cultivationJobs[i])
            }
            
            jobListMaster.append("Harvest: Harvest")
            jobListMaster.append("Harvest: Wash/ pack")
            
            let postHarvestJobs = ["Mow crop", "Remove mulch", "Disk", "Sow cover crop", "Other"]
            for i in 0...(postHarvestJobs.count - 1) {
                jobListMaster.append("Post harvest: "+postHarvestJobs[i])
            }
            
            for i in 0...(jobListMaster.count - 1){
                
                
                let entity =  NSEntityDescription.entity(forEntityName: "Job", in:managedContext)
                let record = Job(entity: entity!, insertInto: managedContext)
                
                record.setValue(jobListMaster[i], forKey: "job_name")
                
                do {
                    // Save the managed object context
                    try managedContext.save()
                    //Add the new record to the work list
                    jobList.append(record)
                } catch let error as NSError  {
                 //   print("Could not save job\(error), \(error.userInfo)")
                }
            }
            
        }// end if jobList empty
        
        
        //Set default crops
        if cropList.count == 0 {
            
            //First compile a master list of all jobs in the worksheet
            var cropListMaster = ["Beans","Beets","Broccoli","Brussels","Cabbage","Carrots","Cauliflower","Celery","Corn","Cucumbers","Eggplant","Kale","Leeks","Lettuce","Melons","Okra","Onions","Peas","Peppers","Potatoes","Pumpkins","Radishes","Spinach","Summer Squash","Sweet Potatoes","Swiss Chard","Tomatoes","Turnips","Winter Squash"]
            
            for i in 0...(cropListMaster.count - 1){
                
                
                let entity =  NSEntityDescription.entity(forEntityName: "Crop", in:managedContext)
                let record = Crop(entity: entity!, insertInto: managedContext)
                
                record.setValue(cropListMaster[i], forKey: "crop_name")
                
                do {
                    // Save the managed object context
                    try managedContext.save()
                    //Add the new record to the work list
                    cropList.append(record)
                } catch let error as NSError  {
               //     print("Could not save crop\(error), \(error.userInfo)")
                }
            }
            
        }// end if jobList empty
        
        
        
        
        //If equipment list is empty, add a 'no equipment' entry
        if equipList.count == 0 {
            let entity =  NSEntityDescription.entity(forEntityName: "Equipment", in:managedContext)
            let record = Equipment(entity: entity!, insertInto: managedContext)
            
            record.setValue("No Implement", forKey: "equip_name")
            
            do {
                // Save the managed object context
                try managedContext.save()
                //Add the new record to the work list
                equipList.append(record)
            } catch let error as NSError  {
            //    print("Could not save equipment\(error), \(error.userInfo)")
            }
        }// end if empty
        
        //If tractor list is empty, add a 'no tractor' entry
        if tractorList.count == 0 {
            let entity =  NSEntityDescription.entity(forEntityName: "Tractor", in:managedContext)
            let record = Tractor(entity: entity!, insertInto: managedContext)
            
            record.setValue("No Tractor", forKey: "tractor_name")
            
            do {
                // Save the managed object context
                try managedContext.save()
                //Add the new record to the work list
                tractorList.append(record)
            } catch let error as NSError  {
            //    print("Could not save equipment\(error), \(error.userInfo)")
            }
        }// end if empty
        
        //select default entries
        for i in 0...(equipList.count - 1){
            if equipList[i].equip_name == "No Implement"{
                workParams[2] = i
                //Set text
                //timerEquip.setTitle("Select Implement (default = none)", forState: UIControlState.Normal)
                implementSelectedLabel.text = "No Implement"
            }
        }//end equip for
        
        for i in 0...(tractorList.count - 1){
            if tractorList[i].tractor_name == "No Tractor"{
                workParams[3] = i
                //Set text
                //timerTractor.setTitle("Select Tractor (default = none)", forState: UIControlState.Normal)
                tractorSelectedLabel.text = "No Tractor"
            }
        }//end tractor for
        
    }//end equipTractorDefault

    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        /* In this case, I plan to save locally rather than unwinding w/ a new record.
        if segue.identifier == "unwindWithNewRecord" {
            //This takes time and workers from text entry fields; other values were filled at selection
            self.workParams[3] = Int(timerWorkers.text!)!
        }
        */

        //Controls segue to contained view which lists active jobs
        if segue.identifier == "jobsContainedSegue" {
            //********
            //http://stackoverflow.com/questions/33857210/access-container-view-child-properties-swift
            //subViewController = segue.destinationViewController as? IPJobsViewController
            ipJobs = segue.destination as! IPJobsViewController
        }
        
        
//Controls segues from the four selector buttons
        if segue.identifier == "selectCrop"{
            let nav = segue.destination as! UINavigationController
            let tvc = nav.topViewController as! SelectionViewController
            tvc.selectType = "crop"
            cropSelected = true
            //Passing recordControl on from the initial view controller
            //tvc.recordControl = self.recordControl
            
        }
        if segue.identifier == "selectJob"{
            let nav = segue.destination as! UINavigationController
            let tvc = nav.topViewController as! SelectionViewController
            tvc.selectType = "job"
            jobSelected = true
            //Passing recordControl on from the initial view controller
            //tvc.recordControl = self.recordControl
        }
        if segue.identifier == "selectEquip"{
            let nav = segue.destination as! UINavigationController
            let tvc = nav.topViewController as! SelectionViewController
            tvc.selectType = "equip"
            //Passing recordControl on from the initial view controller
            //tvc.recordControl = self.recordControl
            
        }
        if segue.identifier == "selectTractor"{
            let nav = segue.destination as! UINavigationController
            let tvc = nav.topViewController as! SelectionViewController
            tvc.selectType = "tractor"
            //Passing recordControl on from the initial view controller
            //tvc.recordControl = self.recordControl
            
        }
    }// end PrepareForSegue

    //This receives actions after the selection is made
    @IBAction func
        makeSelection(_ segue:UIStoryboardSegue){
        
        //Use a single managedObjectContext, stored in appDelegate, for the whole app
        //let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        //let managedContext = appDelegate.managedObjectContext
        
        let incoming = segue.source as! SelectionViewController
        
        // let selectedIndex = incoming.selectIndex
        let selectedType = incoming.selectType
        
        if selectedType == "crop" {
            workParams[0] = incoming.listIndex
            //Alter button text to indicate selection
            let nameCrop = incoming.cropList[incoming.listIndex].crop_name
            //timerCrop.setTitle("Selected crop: "+nameCrop, forState: UIControlState.Normal)
            cropSelectedLabel.text = nameCrop
        }
        if selectedType == "job" {
            workParams[1] = incoming.listIndex
            //Alter button text to indicate selection
            let nameJob = incoming.jobList[incoming.listIndex].job_name
            //timerJob.setTitle("Selected Job: "+nameJob, forState: UIControlState.Normal)
            jobSelectedLabel.text = nameJob
        }
        if selectedType == "equip" {
            workParams[2] = incoming.listIndex
            //Alter button text to indicate selection
            let nameEquip = incoming.equipList[incoming.listIndex].equip_name
            //timerEquip.setTitle("Selected Implement: "+nameEquip, forState: UIControlState.Normal)
            implementSelectedLabel.text = nameEquip
        }
        if selectedType == "tractor" {
            workParams[3] = incoming.listIndex
            //Alter button text to indicate selection
            let nameTractor = incoming.tractorList[incoming.listIndex].tractor_name
            //timerTractor.setTitle("Selected Tractor: "+nameTractor, forState: UIControlState.Normal)
            tractorSelectedLabel.text = nameTractor
        }
        
    }//End make selection receiver
    
    
    //Finally, this saves IPJobs as Work_records when an in-progress job is selected in the IPJobsView
    //Also deletes IPJob ??
    //It is triggered when a notification is received from IPJobsview
    func addRecord(_ notification: Notification){
        
        let managedContext = appDelegate.managedObjectContext
        
        //Save the completed job as a new entry in the work list
        
        //First load the work list
        //var workList = [Work_record]()
        
        
        /*
        //Request objects of name In_progress
        let fetchRequest = NSFetchRequest(entityName: "Work_record")
        
        
        //Return all Work_records as jobList
        do {
            let results =
                try managedContext.executeFetchRequest(fetchRequest)
            workList = results as! [Work_record]
            
        } catch let error as NSError {
          //  print("Could not fetch work records\(error), \(error.userInfo)")
        }
 */
        
        //Then get the elapsed time (currently tracking time in hours; should probably change)
        let currentTime = getCurrentMillis()
        let startTime = self.ipJobs.jobList[self.ipJobs.rowSelected].start_time
        let elapsedTime = currentTime - startTime        
        let elapsedHours = elapsedTime / 3600000
        
        //Finally, save the new Work_record
        
        //This inserts a new entity into the managed object context
        let entity =  NSEntityDescription.entity(forEntityName: "Work_record", in:managedContext)
        let record = Work_record(entity: entity!, insertInto: managedContext)
        //let record = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        
        //This sets the values of the entity attributes based on the info in the selected job
        record.setValue(self.ipJobs.jobList[self.ipJobs.rowSelected].cropRelate, forKey: "cropRelate")
        record.setValue(self.ipJobs.jobList[self.ipJobs.rowSelected].jobRelate, forKey: "jobRelate")
        record.setValue(self.ipJobs.jobList[self.ipJobs.rowSelected].equipRelate, forKey: "equipRelate")
        record.setValue(self.ipJobs.jobList[self.ipJobs.rowSelected].tractorRelate, forKey: "tractorRelate")
        //Passes entered values for time worked and workers as Int directly from NewItem
        record.setValue(elapsedHours, forKey: "ms_worked")
        record.setValue(self.ipJobs.jobList[self.ipJobs.rowSelected].workers, forKey: "workers")
        record.setValue(self.ipJobs.jobList[self.ipJobs.rowSelected].notes, forKey: "notes")
        
        record.setValue(currentTime, forKey: "timestamp")
        
        do {
            // Save the managed object context
            try managedContext.save()
            //Add the new record to the work list
            //workList.append(record)
        } catch let error as NSError  {
         //   print("Could not save \(error), \(error.userInfo)")
        }
        
    }
    
    
    @IBAction func
        doneRecords(_ segue:UIStoryboardSegue){

    }
    
    @IBAction func
        cancelNewItem(_ segue:UIStoryboardSegue){

    }
    
    @IBAction func
        doneNewItem(_ segue:UIStoryboardSegue){

    }
    
    @IBAction func
        cancelSelection(_ segue:UIStoryboardSegue){
        
    }

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
