//
//  SelectionViewController.swift
//  BeetClock_A1
//
//  Created by user on 10/16/16.
//  Copyright © 2016 BeetWorks. All rights reserved.
//

import UIKit
import CoreData

class SelectionViewController: UITableViewController {

    //Will work with either crop, job or equipment objects.  Therefore must instantiate controllers for all three
    
        
    //Should not need to work directly with records here
    //var recordControl = Work_recordController()
    
    //This delegates to the crop, job or equip controller while hopefully mantaining context.
    //When I pass calls to delegate functions, I will need to pass the object type (Crop, Job, Equipment)
    //var cjeDelegate = cropJobEquipDelegator()
    
    //!
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    //var recordController = Work_recordController()
    //var recordController = cropJobEquipDelegator()
    
    //This var will set whether Selection selects crop, job or equip
    var selectType = "no selection"
    
    //This determines whether add and edit controls are displayed on the bar
    var canEdit = true
    
    //These lists will be populated as needed on poplist (load or reload) based on selectType
    var cropList = [Crop]()
    var jobList = [Job]()
    var equipList = [Equipment]()
    var tractorList = [Tractor]()
    
    var workList = [Work_record]()
    
    var ipList = [In_progress]()
    
    var colorBank = ColorBank()
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    var editMode = true
    
    //This string list will be displayed on poplist (load or reload)
    //var displayList = [String]()

    //The list # will be assigned as needed on selection based on selectType
    var listIndex = Int()

    //This creates an array of work record entities, or instances of the Work_record class declared in its own file
    //var workList = Array<Work_record>()
    
    func getList() -> [String] {
        
        var displayList = [String]()
        
        if selectType == "crop" || selectType == "cropWithRecord" {
            if cropList.count > 0{
            for i in 0...(cropList.count - 1) {
                let theEntity = cropList[i]
                displayList.append(theEntity.crop_name)}
          //  print("Crop List:")
          //  print(displayList.count)
            }
        }
        if selectType == "job" {
            if jobList.count > 0{
            for i in 0...(jobList.count - 1) {
                let theEntity = jobList[i]
                displayList.append(theEntity.job_name)}
          //  print("Job List:")
          //  print(displayList.count)
            }
        }
        if selectType == "equip" {
            if equipList.count > 0{
            for i in 0...(equipList.count - 1) {
                let theEntity = equipList[i]
                displayList.append(theEntity.equip_name)}
          //  print("Equip List:")
          //  print(displayList.count)
            }
        }
        if selectType == "tractor" {
            if tractorList.count > 0{
                for i in 0...(tractorList.count - 1) {
                    let theEntity = tractorList[i]
                    displayList.append(theEntity.tractor_name)}
            //    print("Tractor List:")
            //    print(displayList.count)
            }
        }
        
        return displayList
    }//end getList

    func popLists() {
        //!
        //Use a single managedObjectContext, stored in appDelegate, for the whole app
        //let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        //let managedContext = appDelegate.managedObjectContext
        let managedContext = appDelegate.managedObjectContext
        
        //Retrieves all crops, jobs or equipment in DB and populates corresp. lists
        if selectType == "crop" {
            let cropRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Crop")
            
            
            //Return all crops, jobs and equipment as cropList, jobList and equipList composed of their respective entity types
            do {
                //Retrieve crops
                let crops = try managedContext.fetch(cropRequest)
                cropList = crops as! [Crop]
    
            } catch let error as NSError {
               // print("Could not fetch crops\(error), \(error.userInfo)")
            }
            
            //self.cjeDelegate.popList(Crop)
            cropList = cropList.sorted{$0.crop_name < $1.crop_name}
            //Sorts new entries alphebetically; will need time to synch with other functions
        }
        if selectType == "cropWithRecord"{
            
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

        }
        
    if selectType == "job" {
            let jobRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Job")
            do {
                //Retrieve jobs
                let jobs = try managedContext.fetch(jobRequest)
                jobList = jobs as! [Job]

            } catch let error as NSError {
              //  print("Could not fetch jobs\(error), \(error.userInfo)")
            }
            //self.cjeDelegate.popList(Job)
            jobList = jobList.sorted{$0.job_name < $1.job_name}
        }
        if selectType == "equip" {
            let equipRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Equipment")
            do {
                //Retrieve equipment
                let equips = try managedContext.fetch(equipRequest)
                equipList = equips as! [Equipment]

            } catch let error as NSError {
              //  print("Could not fetch equipment\(error), \(error.userInfo)")
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
                  //  print("Could not save equipment\(error), \(error.userInfo)")
                }
            }// end if empty
            equipList = equipList.sorted{$0.equip_name < $1.equip_name}
        }//end if equipment
        if selectType == "tractor" {
            let tractorRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tractor")
            do {
                //Retrieve equipment
                let tractors = try managedContext.fetch(tractorRequest)
                tractorList = tractors as! [Tractor]
                
            } catch let error as NSError {
              //  print("Could not fetch tractor\(error), \(error.userInfo)")
            }
            
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
                  //  print("Could not save equipment\(error), \(error.userInfo)")
                }
            }// end if empty
            tractorList = tractorList.sorted{$0.tractor_name < $1.tractor_name}
        }//end if tractor
        

    }//end popLists
    
    override func viewDidLoad() {
   super.viewDidLoad()
        
        //Set the background color
        self.tableView.backgroundColor = colorBank.GetUIColor("background")
        
        
        // Change the navigation bar background color
        navigationController!.navigationBar.barTintColor = colorBank.GetUIColor("navbar")
        
        // Change the color of the navigation bar button items to white.
        navigationController!.navigationBar.tintColor = UIColor.white
        
        
        
        //print("select view loaded")
        //Here I will load values from the table corresponding to the selection type 
        //self.popList()
        
        //Assign a class to cjeDelegate based on selectType
        
        //selectList = self.cjeDelegate.popList(selectType)
        
        self.popLists()
        
        //enable edit button if editing is turned on; otherwise hide buttons
        if canEdit {
        self.editButton.title = "Edit"
        } else {
            self.addButton.isEnabled = false
            self.editButton.isEnabled = false
        }
        


        //Because I'm using mutiple bar buttons, I need to trigger editing mode with the action immediately below
        //self.editButton = self.editButtonItem()
        //self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
    }//end DidLoad
    
    
    @IBAction func editSelection(_ sender: AnyObject) {
        //toggles in and out of editing mode
 
        if tableView.isEditing == false {
            setEditing(true, animated: true)
            self.editButton.title = "Done"
            
//Throw a warning that records could be deleted
            var warnTxt = String()
            if selectType == "equip" {
                warnTxt = "implement"
            } else {
                warnTxt = selectType
            }
            
            let alert = UIAlertController(title: "Warning!", message: "If you delete a \(warnTxt) then all records containing that \(warnTxt) will also be deleted!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)

            

//end editing set to true
        } else {
            setEditing(false, animated: true)
            self.editButton.title = "Edit"
        }
        
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: animated)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        popLists()
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
        // Return the number of rows in the section from displayList

        let nRows = getList().count

        return nRows

    }
    
    //Populate table contents from displayList
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DisplayItem", for: indexPath)
        
        let displayList = getList()

        cell.textLabel?.text = displayList[indexPath.row]
        
                return cell
    }
    
    func getWorkList() {
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Work_record")
        
        //Return all Work_records as workList
        do {
            let results =
                try managedContext.fetch(fetchRequest)
            workList = results as! [Work_record]
            //workList = results as! [NSManagedObject]
        } catch let error as NSError {
           // print("Could not fetch \(error), \(error.userInfo)")
        }
    }//end getWorkList
    
    func getIPList() {
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "In_progress")
        
        //Return all Work_records as workList
        do {
            let results =
                try managedContext.fetch(fetchRequest)
            ipList = results as! [In_progress]
            //workList = results as! [NSManagedObject]
        } catch let error as NSError {
           // print("Could not fetch \(error), \(error.userInfo)")
        }
    }//end getWorkList
    
    
    //Runs when the deletion control is tapped
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.delete {
            //Run to get current list of selectable entities, values
          //  print("editingStyle.Delete")
     
            let managedContext = appDelegate.managedObjectContext
            
            if selectType == "crop" || selectType == "cropWithRecord" {
                
                ////Removes all work recoreds w/ selected crop
                getWorkList()

                if workList.count > 0 {
                var reduceIndex = 0
                for i in 0...(workList.count-1){
                    
                    if (workList[i - reduceIndex].cropRelate.value(forKey: "crop_name") as! String) == cropList[indexPath.row].crop_name {
                        
                        //delete object from context
                        managedContext.delete(workList[i - reduceIndex])
                        //Removes the selected entity from the list
                        workList.remove(at: i - reduceIndex)
                        //Save to memory
                        do {
                            // Saves the managed object context
                            try managedContext.save()
                        } catch let error as NSError  {
                         //   print("Could not save \(error), \(error.userInfo)")
                        }
                        reduceIndex += 1 //increment dynamic index by 1
                    }//end if
                    }//end for
                }//end if > 0
                
                ////Removes all in progress jobs w/ selected crop
                getIPList()
                if ipList.count > 0 {
                    var reduceIndex = 0
                for i in 0...(ipList.count-1){
                    
                    if (ipList[i - reduceIndex].cropRelate.value(forKey: "crop_name") as! String) == cropList[indexPath.row].crop_name {
                        
                        //delete object from context
                        managedContext.delete(ipList[i - reduceIndex])
                        //Removes the selected entity from the list
                        ipList.remove(at: i - reduceIndex)
                        //Save to memory
                        do {
                            // Saves the managed object context
                            try managedContext.save()
                        } catch let error as NSError  {
                          //  print("Could not save \(error), \(error.userInfo)")
                        }
                        reduceIndex += 1 //increment dynamic index by 1
                    }//end if
                }//end for
            }//end if > 0
            
                ////Deletes the selected crop and saves
                managedContext.delete(cropList[indexPath.row])
                
                do {
                    //Removes the selected entity from the list
                    self.cropList.remove(at: indexPath.row)
                    
                    //Removes the selected entity from the table view
                    self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                    
                    // Saves the managed object context
                    try managedContext.save()
                } catch let error as NSError  {
                  //  print("Could not save ip crop\(error), \(error.userInfo)")
                }
                
            }//end crop
            
            if selectType == "job" {
                
                ////Removes all work recoreds w/ selected job
                //fetching records
                //var workList = getWorkList()
                getWorkList()
                
                //deleting records w/ selected job
                //create variable to increment when a record is deleted, and decrease the index i by that variable on all subsequent passes
                if workList.count > 0 {
                    var reduceIndex = 0
                    for i in 0...(workList.count-1){
                        
                        if (workList[i - reduceIndex].jobRelate.value(forKey: "job_name") as! String) == jobList[indexPath.row].job_name {
                            
                            //delete object from context
                            managedContext.delete(workList[i - reduceIndex])
                            //Removes the selected entity from the list
                            workList.remove(at: i - reduceIndex)
                            //Save to memory
                            do {
                                // Saves the managed object context
                                try managedContext.save()
                            } catch let error as NSError  {
                             //   print("Could not save \(error), \(error.userInfo)")
                            }
                            reduceIndex += 1 //increment dynamic index by 1
                        }//end if
                    }//end for
                }//end if > 0
                
                ////Removes all in progress jobs w/ selected job
                getIPList()
                if ipList.count > 0 {
                    var reduceIndex = 0
                    for i in 0...(ipList.count-1){
                        
                        if (ipList[i - reduceIndex].jobRelate.value(forKey: "job_name") as! String) == jobList[indexPath.row].job_name {
                            
                            //delete object from context
                            managedContext.delete(ipList[i - reduceIndex])
                            //Removes the selected entity from the list
                            ipList.remove(at: i - reduceIndex)
                            //Save to memory
                            do {
                                // Saves the managed object context
                                try managedContext.save()
                            } catch let error as NSError  {
                              //  print("Could not save ip job\(error), \(error.userInfo)")
                            }
                            reduceIndex += 1 //increment dynamic index by 1
                        }//end if
                    }//end for
                }//end if > 0
                
                ////Deletes the selected job and saves
                managedContext.delete(jobList[indexPath.row])
                
                do {
                    //Removes the selected entity from the list
                    self.jobList.remove(at: indexPath.row)
                    
                    //Removes the selected entity from the table view
                    self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                    
                    // Saves the managed object context
                    try managedContext.save()
                } catch let error as NSError  {
                  //  print("Could not save \(error), \(error.userInfo)")
                }
                
            } //end job
            
            if selectType == "equip" {
                
                ////Removes all work recoreds w/ selected equipment
                //fetching records
                //var workList = getWorkList()
                getWorkList()
              //  print("this is the SelectionView work list:")
              //  print(workList)
                
              //  print("!!")
                
                //deleting records w/ selected equipment
                //create variable to increment when a record is deleted, and decrease the index i by that variable on all subsequent passes
                if workList.count > 0 {
                    var reduceIndex = 0
                    for i in 0...(workList.count-1){
    
                        
                        if (workList[i - reduceIndex].equipRelate.value(forKey: "equip_name") as! String) == equipList[indexPath.row].equip_name {
                            
                            //delete object from context
                            managedContext.delete(workList[i - reduceIndex])
                            //Removes the selected entity from the list
                            workList.remove(at: i - reduceIndex)
                            //Save to memory
                            do {
                                // Saves the managed object context
                                try managedContext.save()
                            } catch let error as NSError  {
                             //   print("Could not save \(error), \(error.userInfo)")
                            }
                            reduceIndex += 1 //increment dynamic index by 1
                        }//end if
                    }//end for
                }//end if > 0
                
                ////Removes all in progress jobs w/ selected equipment
                getIPList()
                if ipList.count > 0 {
                    var reduceIndex = 0
                    for i in 0...(ipList.count-1){
                        
                        if (ipList[i - reduceIndex].equipRelate.value(forKey: "equip_name") as! String) == equipList[indexPath.row].equip_name {
                            
                            //delete object from context
                            managedContext.delete(ipList[i - reduceIndex])
                            //Removes the selected entity from the list
                            ipList.remove(at: i - reduceIndex)
                            //Save to memory
                            do {
                                // Saves the managed object context
                                try managedContext.save()
                            } catch let error as NSError  {
                             //   print("Could not save ip job\(error), \(error.userInfo)")
                            }
                            reduceIndex += 1 //increment dynamic index by 1
                        }//end if
                    }//end for
                }//end if > 0
                
                ////Deletes the selected crop and saves
                managedContext.delete(equipList[indexPath.row])
                
                do {
                    //Removes the selected entity from the list
                    self.equipList.remove(at: indexPath.row)
                    
                    //Removes the selected entity from the table view
                    self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                    
                    // Saves the managed object context
                    try managedContext.save()
                } catch let error as NSError  {
                 //   print("Could not save \(error), \(error.userInfo)")
                }
                
            } //end equip

            if selectType == "tractor" {
                
                ////Removes all work recoreds w/ selected equipment
                //fetching records
                //var workList = getWorkList()
                getWorkList()
              //  print("this is the SelectionView work list:")
               // print(workList)
                
              //  print("!!")
                
                //deleting records w/ selected equipment
                //create variable to increment when a record is deleted, and decrease the index i by that variable on all subsequent passes
                if workList.count > 0 {
                    var reduceIndex = 0
                    for i in 0...(workList.count-1){
                        
                        
                        if (workList[i - reduceIndex].tractorRelate.value(forKey: "tractor_name") as! String) == tractorList[indexPath.row].tractor_name {
                            
                            //delete object from context
                            managedContext.delete(workList[i - reduceIndex])
                            //Removes the selected entity from the list
                            workList.remove(at: i - reduceIndex)
                            //Save to memory
                            do {
                                // Saves the managed object context
                                try managedContext.save()
                            } catch let error as NSError  {
                             //   print("Could not save \(error), \(error.userInfo)")
                            }
                            reduceIndex += 1 //increment dynamic index by 1
                        }//end if
                    }//end for
                }//end if > 0
                
                ////Removes all in progress jobs w/ selected equipment
                getIPList()
                if ipList.count > 0 {
                    var reduceIndex = 0
                    for i in 0...(ipList.count-1){
                        
                        if (ipList[i - reduceIndex].tractorRelate.value(forKey: "tractor_name") as! String) == tractorList[indexPath.row].tractor_name {
                            
                            //delete object from context
                            managedContext.delete(ipList[i - reduceIndex])
                            //Removes the selected entity from the list
                            ipList.remove(at: i - reduceIndex)
                            //Save to memory
                            do {
                                // Saves the managed object context
                                try managedContext.save()
                            } catch let error as NSError  {
                             //   print("Could not save ip job\(error), \(error.userInfo)")
                            }
                            reduceIndex += 1 //increment dynamic index by 1
                        }//end if
                    }//end for
                }//end if > 0
                
                ////Deletes the selected crop and saves
                managedContext.delete(tractorList[indexPath.row])
                
                do {
                    //Removes the selected entity from the list
                    self.tractorList.remove(at: indexPath.row)
                    
                    //Removes the selected entity from the table view
                    self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                    
                    // Saves the managed object context
                    try managedContext.save()
                } catch let error as NSError  {
                  //  print("Could not save \(error), \(error.userInfo)")
                }
                
            } //end tractor

            
            self.popLists()
            
        }//end editing style = delete
        
    }//end commit editing style
    
    
    //Receives incoming data from newSelectable, adds to DB and updates
    @IBAction func
        unwindWithNewSelectable(_ segue:UIStoryboardSegue){
        //was previously makeSelection
        
        let incoming = segue.source as! NewSelectViewController
        let newEntry = incoming.selectName
        
        let managedContext = appDelegate.managedObjectContext
        
        // actual savign to DB will need to be accompanied by a willAppear method to reload entries from DB
        if selectType == "crop" || selectType == "cropWithRecord"{
            //This inserts a new crop entity into the managed object context
            let entity =  NSEntityDescription.entity(forEntityName: "Crop", in:managedContext)
            let record = Crop(entity: entity!, insertInto: managedContext)
            
            //This sets the values of the entity attributes
            record.setValue(newEntry, forKey: "crop_name")
            
            do {
                // Save the managed object context
                try managedContext.save()
                //Add the new record to the crop list
                cropList.append(record)
            } catch let error as NSError  {
              //  print("Could not save \(error), \(error.userInfo)")
            }
        }
        if selectType == "job" {
            //This inserts a new crop entity into the managed object context
            let entity =  NSEntityDescription.entity(forEntityName: "Job", in:managedContext)
            let record = Job(entity: entity!, insertInto: managedContext)
            
            //This sets the values of the entity attributes
            record.setValue(newEntry, forKey: "job_name")
            
            do {
                // Save the managed object context
                try managedContext.save()
                //Add the new record to the work list
                jobList.append(record)
            } catch let error as NSError  {
              //  print("Could not save \(error), \(error.userInfo)")
            }
        }
        if selectType == "equip" {
            //This inserts a new crop entity into the managed object context
            let entity =  NSEntityDescription.entity(forEntityName: "Equipment", in:managedContext)
            let record = Equipment(entity: entity!, insertInto: managedContext)
            
            //This sets the values of the entity attributes
            record.setValue(newEntry, forKey: "equip_name")
            
            do {
                // Save the managed object context
                try managedContext.save()
                //Add the new record to the work list
                equipList.append(record)
            } catch let error as NSError  {
              //  print("Could not save \(error), \(error.userInfo)")
            }
        }//end equip
        
        if selectType == "tractor" {
            //This inserts a new crop entity into the managed object context
            let entity =  NSEntityDescription.entity(forEntityName: "Tractor", in:managedContext)
            let record = Tractor(entity: entity!, insertInto: managedContext)
            
            //This sets the values of the entity attributes
            record.setValue(newEntry, forKey: "tractor_name")
            
            do {
                // Save the managed object context
                try managedContext.save()
                //Add the new record to the work list
                tractorList.append(record)
            } catch let error as NSError  {
              //  print("Could not save tractor \(error), \(error.userInfo)")
            }
        }//end tractor
        
    }//End make selection receiver
    
    @IBAction func
        cancelNewSelection(_ segue:UIStoryboardSegue){
        //manually calling viewDidLoad is not recommended, and does not appear to work.
        //viewDidLoad()
    }
    
    @IBAction func
        didImport(_ segue:UIStoryboardSegue){

    }
    
    
 
// Prepare for segue can go forward or back.  This sets the selectedRow variable in SelectionViewController on click, which then becomes available to NewItemViewController.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        
        if segue.identifier == "newSelectSegue"{
            let nav = segue.destination as! UINavigationController
            let newItemView = nav.topViewController as! NewSelectViewController
            newItemView.selectType = selectType
        }
        
        
        if segue.identifier == "unwindWithNewItem" {
        let tvc = segue.source as! SelectionViewController
        let selectedRow = tvc.tableView.indexPathForSelectedRow?.row
            //selectIndex = selectedRow!
        
       // print("Selected index:")
       // print (selectedRow)
        
        listIndex = selectedRow!
        }//end if unwind w/ new item
        
        
        
        
        /* It seems I can't pass on actual managed objects w/o difficulty.  Settling for index #
        if selectType == "Crop" {
            cropSelect = cropList[selectedRow!]
            print("Selected crop")
            print(cropSelect.valueForKey("crop_name") as! String)
        }
        if selectType == "Job" {
            jobSelect = jobList[selectedRow!]
        }
        if selectType == "Equip" {
            equipSelect = equipList[selectedRow!]
        }
 */
        
        //This dismisses the NewItemViewController.  So apparently current view controller is already dismissed at segue
        //self.dismissViewControllerAnimated(true, completion: nil)
        
    } //end prepareForSegue
 
}
