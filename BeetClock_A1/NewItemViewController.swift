    //
//  NewItemViewController.swift
//  BeetClock_A1
//
//  Created by user on 10/12/16.
//  Copyright © 2016 BeetWorks. All rights reserved.
//

import UIKit
import CoreData

    

class NewItemViewController: UITableViewController {

    //@IBOutlet weak var txtCrop: UITextField!
    //@IBOutlet weak var txtJob: UITextField!
    //@IBOutlet weak var txtEquip: UITextField!
    
    
    @IBOutlet weak var txtWorked: UITextField! //Remove when spinners fully work
    
    @IBOutlet weak var buttonWorked: UIButton!
    
    @IBOutlet weak var txtWorkers: UITextField!
    @IBOutlet weak var txtNotes: UITextField!
    
    @IBOutlet weak var buttonCrop: UIButton!
    @IBOutlet weak var buttonJob: UIButton!
    @IBOutlet weak var buttonEquip: UIButton!
    @IBOutlet weak var buttonTractor: UIButton!
    @IBOutlet weak var buttonDate: UIButton!
    
    
    @IBOutlet weak var labelCropSelect: UILabel!
    @IBOutlet weak var labelJobSelect: UILabel!
    @IBOutlet weak var labelImplementSelect: UILabel!
    @IBOutlet weak var labelTractorSelect: UILabel!
    @IBOutlet weak var labelDateSelect: UILabel!
    
    @IBOutlet weak var labelTimeWorked: UILabel!
    
    
    
    var cropList = [Crop]()
    var jobList = [Job]()
    var equipList = [Equipment]()
    var tractorList = [Tractor]()

    
    //Params are crop, job, equipment, timeworked, workers
    var workParams = [0,0,0,0,1]
    
    var workTime = Double()
    
    var datePicked = false
    var pickedDate = Double()
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //These booleans used to determine if inputs have been made
    var cropSelected = false
    var jobSelected = false
    var timeEntered = false // remove after time picker implemented
    var timePicked = false
    
    
    //Accepting selected type from SelectionView; will use to assign index values to workParams
    var selectedType = String()
    
    //Called when returning setting defaults and when accepting return segue
    var selectView = SelectionViewController()
    
    var colorBank = ColorBank()
    
    //It seems I cannot easily pass selected CJE back to ViewController
    //var cropSelected = Crop()
    //var jobSelected = Job()
    //var equipSelected = Equipment()
    
    //This var exists only for the purpose of passing the same record controller from the initial view controller to the selection view controller
    //var recordControl = Work_recordController()
    
    //Calling the selection view controller
    //var controlSelection = SelectionViewController()
    //This approach does not allow me to set new values that are present in new controller
    
    
    func equipTractorDefault() {
    
        let managedContext = appDelegate.managedObjectContext
    
        let equipRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Equipment")
        do {
            //Retrieve equipment
            let equips = try managedContext.fetch(equipRequest)
            equipList = equips as! [Equipment]
            equipList = equipList.sorted{$0.equip_name < $1.equip_name}
            
        } catch let error as NSError {
            //print("Could not fetch equipment\(error), \(error.userInfo)")
        }
        
        let tractorRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tractor")
        do {
            //Retrieve equipment
            let tractors = try managedContext.fetch(tractorRequest)
            tractorList = tractors as! [Tractor]
            tractorList = tractorList.sorted{$0.tractor_name < $1.tractor_name}
            
        } catch let error as NSError {
           // print("Could not fetch tractor\(error), \(error.userInfo)")
        }

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
               // print("Could not save equipment\(error), \(error.userInfo)")
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
                //print("Could not save equipment\(error), \(error.userInfo)")
            }
        }// end if empty
        
        //select default entries
        for i in 0...(equipList.count - 1){
            if equipList[i].equip_name == "No Implement"{
                workParams[2] = i
                //Set text
                //buttonEquip.setTitle("Select Implement (default = none)", forState: UIControlState.Normal)
                labelImplementSelect.text = "No Implement"
            }
        }//end equip for
        
        for i in 0...(tractorList.count - 1){
            if tractorList[i].tractor_name == "No Tractor"{
                workParams[3] = i
                //Set text
                //buttonTractor.setTitle("Select Tractor (default = none)", forState: UIControlState.Normal)
                labelTractorSelect.text = "No tractor"
            }
        }//end tractor for
        
    }//end equipTractorDefault
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        
        // Set the button colors
        buttonCrop.backgroundColor = colorBank.GetUIColor("crop")
        buttonJob.backgroundColor = colorBank.GetUIColor("job")
        buttonEquip.backgroundColor = colorBank.GetUIColor("implement")
        buttonTractor.backgroundColor = colorBank.GetUIColor("tractor")
        buttonWorked.backgroundColor = colorBank.GetUIColor("crop")
        buttonDate.backgroundColor = colorBank.GetUIColor("job")
        
        
        
        //Set the background color
        self.tableView.backgroundColor = colorBank.GetUIColor("background")
        
        
        // Change the navigation bar background color
        navigationController!.navigationBar.barTintColor = colorBank.GetUIColor("navbar")
        
        // Change the color of the navigation bar button items to white.
        navigationController!.navigationBar.tintColor = UIColor.white
        
        
        
        
        //Allows functions to be triggered when data are entered into the text feilds
 //  txtWorked.addTarget(self, action: #selector(NewItemViewController.timeEntered(_:)), for: UIControlEvents.editingChanged)
   txtWorkers.addTarget(self, action: #selector(NewItemViewController.workersEntered(_:)), for: UIControlEvents.editingChanged)

        //sets default values for equipment and tractor
        equipTractorDefault()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    
    
    //***Do/catch does not prevent app from crashing if non-numeric characters are entered....  Change input to number selector!!
    
    //Functions triggered when text fields are modified
  /*  func timeEntered(_ txtWorked: UITextField) {
        if txtWorked.text != "" {
            
            //Set of non-numeric characters to check text box against - thanks TwoStraws!!
            let characterSet1 = NSMutableCharacterSet() //create an empty mutable set
            characterSet1.addCharacters(in: "1234567890")
            let characterSet2 = NSMutableCharacterSet() //create an empty mutable set
            characterSet2.addCharacters(in: "1234567890.")
            
            //Set bad character values based on order entered
            var badCharacters = CharacterSet()
            
            if txtWorked.text!.characters.count == 1 {
                badCharacters = characterSet1.inverted
            }else{
                badCharacters = characterSet2.inverted
            }
            
                if txtWorked.text!.rangeOfCharacter(from: badCharacters) == nil{
                self.workTime = Double(txtWorked.text!)!
                self.timeEntered = true
            } else {
                let alert = UIAlertController(title: "Alert:", message: "This field only accepts numbers", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)

                //Removes the most recently entered character which is not of the appropriate char set
                let entry = txtWorked.text
                let truncated = String(entry!.characters.dropLast())
                txtWorked.text = truncated
                
            }//end txtWorked else

        } //end if text not empty
    } //end timeEntered */
    func workersEntered(_ txtWorkers: UITextField) {
        if txtWorkers.text != "" {
            //Set of non-numeric characters to check text box against - thanks TwoStraws!!
            let badCharacters = CharacterSet.decimalDigits.inverted
            
            if txtWorkers.text!.rangeOfCharacter(from: badCharacters) == nil {
                self.workParams[4] = Int(txtWorkers.text!)!
            } else {
                let alert = UIAlertController(title: "Alert:", message: "This field only accepts numbers", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                //Removes the most recently entered character which is not of the appropriate char set
                let entry = txtWorkers.text
                let truncated = String(entry!.characters.dropLast())
                txtWorkers.text = truncated
                
            }//end else
        }//end if text not empty
    }//end workersEntered
    
    
    //This blocks the unwind segue if the selections are incomplete.  Thanks Shaun and App Dev Guy!!
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any!) -> Bool {
        if identifier == "unwindWithNewRecord" {
            // perform your computation to determine whether segue should occur
            
            var segueShouldOccur = false
            if cropSelected && jobSelected && timeEntered {
                segueShouldOccur = true
            }
            
            //Present popup warning if not all conditions for segue are met
            if !segueShouldOccur {
                let alert = UIAlertController(title: "Alert:", message: "Please complete all fields before starting work", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                // prevent segue from occurring
                return false
            }
        }
        
        // by default perform the segue transition
        return true
    }
    
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindWithNewRecord" {
            //This takes time and workers from text entry fields; other values were filled at selection

            saveItem()
            
            //var workLength = workRecord.count
            //print(String(workLength))
        }
        
        //I first access the nav controller, then the 'top view controller' - i.e. the view associated w/ that nav

        
        if segue.identifier == "selectCrop"{
            let nav = segue.destination as! UINavigationController
            //let tvc = nav.topViewController as! SelectionViewController
            selectView = nav.topViewController as! SelectionViewController
            selectView.selectType = "crop"
            //Passing recordControl on from the initial view controller
                //tvc.recordControl = self.recordControl
            self.cropSelected = true
            
        }
        if segue.identifier == "selectJob"{
            let nav = segue.destination as! UINavigationController
            selectView = nav.topViewController as! SelectionViewController
            selectView.selectType = "job"
            self.jobSelected = true
        }
        if segue.identifier == "selectEquip"{
            let nav = segue.destination as! UINavigationController
            selectView = nav.topViewController as! SelectionViewController
            selectView.selectType = "equip"
        }
        if segue.identifier == "selectTractor"{
            let nav = segue.destination as! UINavigationController
            selectView = nav.topViewController as! SelectionViewController
            selectView.selectType = "tractor"
        }
        
        if segue.identifier == "chooseDateSegue"{
            //Nothing needs to happen here, far as I know...
        }
        
    }// end PrepareForSegue
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //This gets current date/time in millis; Thanks Rajan Maneshwari!
    func getCurrentMillis()->Double{
        return  Double(Date().timeIntervalSince1970 * 1000)
    }
    
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
            //buttonCrop.setTitle("Selected crop: "+nameCrop, forState: UIControlState.Normal)
            labelCropSelect.text = nameCrop
            
        }
        if selectedType == "job" {
            workParams[1] = incoming.listIndex
            //Alter button text to indicate selection
            let nameJob = incoming.jobList[incoming.listIndex].job_name
            //buttonJob.setTitle("Selected job: "+nameJob, forState: UIControlState.Normal)
            labelJobSelect.text = nameJob
            
        }
        if selectedType == "equip" {
            workParams[2] = incoming.listIndex
            //Alter button text to indicate selection
            let nameEquip = incoming.equipList[incoming.listIndex].equip_name
            //buttonEquip.setTitle("Selected implement: "+nameEquip, forState: UIControlState.Normal)
            labelImplementSelect.text = nameEquip
        }
        if selectedType == "tractor" {
            workParams[3] = incoming.listIndex
            //Alter button text to indicate selection
            let nameTractor = incoming.tractorList[incoming.listIndex].tractor_name
            //buttonTractor.setTitle("Selected tractor: "+nameTractor, forState: UIControlState.Normal)
            labelTractorSelect.text = nameTractor
        }
        
    }//End make selection receiver
    
    @IBAction func
        cancelSelection(_ segue:UIStoryboardSegue){
        
    }
    
    @IBAction func selectDate(_ segue:UIStoryboardSegue){
        
        let incoming = segue.source as! SelectDateViewController
        
        datePicked = true
        pickedDate = incoming.pickedDate
        
        //Formatting timestamp as string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yy"
        let dateFormat = dateFormatter.string(from: Date(timeIntervalSince1970:(pickedDate/1000)))
        
        //buttonDate.setTitle("Date chosen: \(dateFormat)", forState: UIControlState.Normal)
        labelDateSelect.text = "\(dateFormat)"
    }
    
    
    @IBAction func selectTime(_ segue:UIStoryboardSegue){
        
        let incoming = segue.source as! SelectTimeViewController
        
        timePicked = true
        workTime = Double(incoming.pickedTime)
        
        //buttonDate.setTitle("Date chosen: \(dateFormat)", forState: UIControlState.Normal)
        
        //Rounding to two decimal places using ROUND function
        labelTimeWorked.text = String(round(workTime*100)/100)+" hours"
    //Flip time entered toggle, allowing record to be saved provided cropEntered and jobEntered were also flipped
        timeEntered = true
    } // end selectTime
    
    //!!!!!!!
    
    @IBAction func tappedButtonWorked(_ sender: Any) {
        
        
    }

    
    

    
    
    
    func saveItem(){
    
    //!
    
    //Use a single managedObjectContext, stored in appDelegate, for the whole app
    //let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    //let managedContext = appDelegate.managedObjectContext
    //let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
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
    //print("Could not fetch \(error), \(error.userInfo)")
    }
    
    
    //This inserts a new entity into the managed object context
    let entity =  NSEntityDescription.entity(forEntityName: "Work_record", in:managedContext)
    let record = Work_record(entity: entity!, insertInto: managedContext)
    //let record = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
    
        //Get a timestamp for the new record
        var currentTime = getCurrentMillis()
        if datePicked {
            currentTime = pickedDate
        }
    
    //This sets the values of the entity attributes based on the info in newRecord
    //Accesses crop, job and equip entites corresponding to indicies selected in NewItem
    record.setValue(cropList[workParams[0]], forKey: "cropRelate")
    record.setValue(jobList[workParams[1]], forKey: "jobRelate")
    record.setValue(equipList[workParams[2]], forKey: "equipRelate")
    record.setValue(tractorList[workParams[3]], forKey: "tractorRelate")
    //Passes entered values for workers as Int directly from NewItem
    record.setValue(workParams[4], forKey: "workers")
    //Passes work time as Double
    record.setValue(workTime, forKey: "ms_worked")
        //Appends notes
        record.setValue(txtNotes.text!, forKey: "notes")
        //Sets the timestamp
        record.setValue(currentTime, forKey: "timestamp")
    
    do {
    // Save the managed object context
    try managedContext.save()

    } catch let error as NSError  {
    //print("Could not save \(error), \(error.userInfo)")
    }
    
    //This executes the addRecordToList function in the WorkRecordController using the array constructed in NewItemViewController
    
    //    self.cjeDelegate.addRecord(newRecord)
    //self.workRecordControl.addRecordToList(newRecord)
    
    //Set an index path to the last row of the Work_record entitySubtract 1 from entityList.count because the list index starts at zero
    //let indexPath = NSIndexPath(forRow: (workList.count - 1), inSection: 0)
    //       let recList = self.cjeDelegate.returnRecord()
    //let indexPath = NSIndexPath(forRow: (recList.count - 1), inSection: 0)
    //let indexPath = NSIndexPath(forRow: (self.workRecordControl.entityList.count - 1), inSection: 0)
    
  //  self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    
  //  self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
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
