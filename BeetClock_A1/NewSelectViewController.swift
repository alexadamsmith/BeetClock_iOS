//
//  NewSelectViewController.swift
//  BeetClock_A1
//
//  Created by user on 10/30/16.
//  Copyright © 2016 BeetWorks. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import GoogleAPIClient
import GTMOAuth2

class NewSelectViewController: UITableViewController, GIDSignInUIDelegate {

    @IBOutlet weak var txtSelect: UITextField!
    @IBOutlet weak var categoryText: UILabel!
    @IBOutlet weak var categorySegment: UISegmentedControl!
    
    @IBOutlet weak var sendToWorkbook: UIButton!
    @IBOutlet weak var signInButton: GIDSignInButton!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var selectWorkbook: UIButton!
    @IBOutlet weak var importEquipment: UIButton!

    @IBOutlet weak var statusText: UILabel!
    @IBOutlet weak var labelImport: UILabel!
    
    @IBOutlet weak var labelFile: UILabel!
    
    @IBOutlet weak var isBusy: UIActivityIndicatorView!
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    var selectName = "No name entered"
    var wasEntered = false
    var selectType = String()
    
    var categoryPrefix = "Other: "
    
    
    //####################### APPS SCRIPT EXECUTE OBJECTS
    
    var requestProcessing = Bool()
    
    var currentRequestName = String()
    
    var selectedFileIndex = Int()
    var selectedSheetIndex = Int()
    var selectedCropIndex = Int()
    
    var fileNames = [String]()
    var fileIds = [String]()
    var equipNames = [String]()
    var equipTypes = [String]()
    
    var selectItems = [String]()
    var selectIds = [String]()
    //var selectListView = SelectedListViewController()
    
    //RUNNING SCRIPT BeetClockiOS_ASE on BeetClockiOSASEproj, project # 846227359180
    fileprivate let kClientID = "846227359180-edthnvam3ch34r3n48k2os1utb4tddkv.apps.googleusercontent.com"
    
    //This is listed under deploy API executable as the API id, which I initially used
    fileprivate let kScriptId = "M3Zji8DpejtgOqC321-3L0zyKjfTj9dU6"
    
    
    fileprivate let service = GTLService()
    //let output = UITextView()
    
    var colorBank = ColorBank()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
         @IBOutlet weak var txtSelect: UITextField!
         @IBOutlet weak var categoryText: UILabel!
         @IBOutlet weak var categorySegment: UISegmentedControl!
         
         @IBOutlet weak var sendToWorkbook: UIButton!
         @IBOutlet weak var signInButton: GIDSignInButton!
         @IBOutlet weak var signOutButton: UIButton!
         @IBOutlet weak var selectWorkbook: UIButton!
         @IBOutlet weak var importEquipment: UIButton!
         
         @IBOutlet weak var statusText: UILabel!
         
 */
        
        // Set the button colors
        importEquipment.backgroundColor = colorBank.GetUIColor("navbar")
        selectWorkbook.backgroundColor = colorBank.GetUIColor("job")
        sendToWorkbook.backgroundColor = colorBank.GetUIColor("tractor")
        
        signOutButton.tintColor = colorBank.GetUIColor("navbar")


        //Set the background color
        self.tableView.backgroundColor = colorBank.GetUIColor("background")
        
        
        // Change the navigation bar background color
        navigationController!.navigationBar.barTintColor = colorBank.GetUIColor("navbar")
        
        // Change the color of the navigation bar button items to white.
        navigationController!.navigationBar.tintColor = UIColor.white
        
        // hide busy icon by default
        isBusy.isHidden = true
        
        self.txtSelect.becomeFirstResponder()
        
       // print("SELECT TYPE")
       // print(selectType)

        
        if selectType != "job" {
            categoryText.isHidden = true
            categorySegment.isHidden = true
        }
        
        if selectType == "equip" || selectType == "tractor"{
            signInButton.isHidden = true
            signOutButton.isHidden = true
            selectWorkbook.isHidden = true
            importEquipment.isHidden = true
        } else {
            sendToWorkbook.isHidden = true
            signInButton.isHidden = true
            signOutButton.isHidden = true
            selectWorkbook.isHidden = true
            importEquipment.isHidden = true
            statusText.isHidden = true
            labelImport.isHidden = true
        }
        

        //Executes function when txtSelect modified
        txtSelect.addTarget(self, action: #selector(NewSelectViewController.txtEntered(_:)), for: UIControlEvents.editingChanged)

        //Start Google sign in service
        GIDSignIn.sharedInstance().uiDelegate = self
        
        if (GIDSignIn.sharedInstance().hasAuthInKeychain()){
            GIDSignIn.sharedInstance().signOut()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(ExportViewController2.receiveToggleAuthUINotification(_:)),
            name: NSNotification.Name(rawValue: "ToggleAuthUINotification"), object: nil)
    
        toggleAuthUI()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func txtEntered(_ txtEntry: UITextField) {
        if txtEntry.text != "" {
            
            //Set of non-numeric characters to check text box against - thanks TwoStraws!!
            let badCharacters = NSMutableCharacterSet() //create an empty mutable set
            badCharacters.addCharacters(in: ",")

            if txtEntry.text!.rangeOfCharacter(from: badCharacters as CharacterSet) != nil {
                let alert = UIAlertController(title: "Alert:", message: "disallowed character", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                
                //Removes the most recently entered character which is not of the appropriate char set
                let entry = txtEntry.text
                let truncated = String(entry!.characters.dropLast())
                txtEntry.text = truncated
                
            }//end bad character else
   
        }
        
        if txtEntry.text != "" {
            wasEntered = true
        }
    }
    
    
    // !!!!!!

    //This blocks the unwind segue if the selections are incomplete or if the action has been canceled.
    //Thanks Shaun and AppDevGuy!!
    
    /*
    override func shouldPerformSegue(withIdentifier identifier: String!, sender: Any!) -> Bool {
        
        var allowSegue = false
        
        if identifier == "unwindWithNewSelectable" {
            
            //Present popup warning if text was not entered and block segue
            if !wasEntered {
                let alert = UIAlertController(title: "Alert:", message: "Please complete all fields", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                // prevent segue from occurring
                allowSegue = false
            } else if categoryPrefix == "Other: " || categoryPrefix == "Seed/transplant: " || categoryPrefix == "Harvest: " {
                //Present an alternate warning if categories are Seed/Tr. Harvest or Other
                //User may cancel or continue
                
                let alert = UIAlertController(title: "Notice:", message: "New jobs in the Seed/Transplant, Harvest and Other categories cannot be sent to the NOFA Enterprise Analysis Workbook.  Would you like to proceed?", preferredStyle: UIAlertControllerStyle.alert)
                //alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in allowSegue = true}))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in allowSegue = false}))
                
                self.present(alert, animated: true, completion: nil)
            } else {
                allowSegue = true
            }
        }
        
        if allowSegue {
            return true
        } else {
            return false
        }
    }
 */
    
    //This is executed when 'done' is tapped.  Checks if name field is complete, and if the catetgories 'other', 'seed/trans' or 'harvest havue been used (presents a confirm/cancel popup if so). If complete and if confirmed, triggers unwindWithNewSelectable segue.  Otherwise not.
    @IBAction func tappedDone(_ sender: Any) {
        
        //Segue is blocked by default
        var allowSegue = false
            
            //Present popup warning if text was not entered
            if !wasEntered {
                let alert = UIAlertController(title: "Alert:", message: "Please complete all fields", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            } else if selectType == "job" {
                
                if categoryPrefix == "Other: " || categoryPrefix == "Seed/transplant: " || categoryPrefix == "Harvest: " {
                //Present an alternate warning if categories are Seed/Tr. Harvest or Other
                //User may cancel or continue; if continue, un-block segue
                
                let alert = UIAlertController(title: "Notice:", message: "New jobs in the Seed/Transplant, Harvest and Other categories cannot be sent to the NOFA Enterprise Analysis Workbook.  Would you like to proceed?", preferredStyle: UIAlertControllerStyle.alert)
                
//Add actions to the Ok and Cancel buttons
                    let Ok: UIAlertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction) -> Void in
                        alert.dismiss(animated: true, completion: { _ in })
                        //Unwind on OK
                        //Calling this alert basically puts me into anotehr thread (?), so I can no longer rely on the conditional it is imbedded in to trigger the unwind segue.  Must trigger it directly!
                        self.performSegue(withIdentifier: "unwindWithNewSelectable", sender: self)

                    })
                    alert.addAction(Ok)
                    
                    let Cancel: UIAlertAction = UIAlertAction(title: "Cancal", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction) -> Void in
                        alert.dismiss(animated: true, completion: { _ in })
                        //Do nothing on cancel
                    })
                    alert.addAction(Cancel)
                    
                    //This logic is not working; 'in allowSegue = true' does not flip the switch!
                    // alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in allowSegue = true}))
                
                
                self.present(alert, animated: true, completion: nil)
    
            } else {
                //If text is not blank and category warning does not trigger, unblock segue
                allowSegue = true
            }//end if categoryPrefix
        
            } else {
             //end if selectType job
                allowSegue = true
        }
        //Execute the unwindWithNewSelectable segue if allowed
        if allowSegue {
            self.performSegue(withIdentifier: "unwindWithNewSelectable", sender: self)

        }
    }
    
    
    
    
    @IBAction func tappedCategory(_ sender: AnyObject) {
        switch categorySegment.selectedSegmentIndex
        {
            case 0:
            categoryText.text = "Selected category: Soil prep"
            categoryPrefix = "Soil prep: "
            case 1:
            categoryText.text = "Selected category: Seed/Transplant"
            categoryPrefix = "Seed/transplant: "
            case 2:
            categoryText.text = "Selected category: Cultivation"
            categoryPrefix = "Cultivation: "
            case 3:
            categoryText.text = "Selected category: Harvest"
            categoryPrefix = "Harvest: "
            case 4:
            categoryText.text = "Selected category: Post harvest"
            categoryPrefix = "Post harvest: "
            
            default:
            break; 
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "unwindWithNewSelectable" {
            if selectType == "job"{
                if txtSelect.text != "" {
                    self.selectName = categoryPrefix+txtSelect.text!
                    
                }
            } else {
            if txtSelect.text != "" {
            self.selectName = txtSelect.text!
            }
            //Now that I have the selectName, I will add it to the DB
                if selectName != ""{
                }//end selectName if
            }//end selectType job else

        }
        
        if segue.identifier == "selectListEquipSegue"{
            let nav = segue.destination as! UINavigationController
            //let tvc = nav.topViewController as! SelectionViewController
            let selectListView = nav.topViewController as! SelectListViewController
            selectListView.selectList = selectItems
        }
    }
    
    
    //############################################################################### Start ASE functions

    @IBAction func tappedImportEquipment(_ sender: AnyObject) {
        if !(GIDSignIn.sharedInstance().hasAuthInKeychain()){
            signInButton.isHidden = false
        }
    }

    @objc func receiveToggleAuthUINotification(_ notification: Notification) {
        //if NSNotification.Name == "ToggleAuthUINotification" {
            self.toggleAuthUI()
            if notification.userInfo != nil {
                let userInfo:Dictionary<String,String?> =
                    notification.userInfo as! Dictionary<String,String?>

                //Clip userInfo to obtain user name
                let userInfoText = userInfo["statusText"]!!
                //First clip the initial 25 characters
                let userNameSub1 = (userInfoText as NSString).substring(from: 25)
                //Then the last two.  This should produce the straight user name
                let userNameDisplay = (userNameSub1 as NSString).substring(to: (userNameSub1.characters.count - 2) )
                
                //self.statusText.text = userInfo["statusText"]!
                self.statusText.text = "User name: "+userNameDisplay
            }
        //} //NSNotification.Name is no longer comparable to string values.  However, I don't believe this if clause is used.
    }
    
    func toggleAuthUI() {
        if (GIDSignIn.sharedInstance().hasAuthInKeychain()){
            // Signed in
            signInButton.isHidden = true
            signOutButton.isHidden = false
            selectWorkbook.isHidden = false
            
            //Set user credentials and make request
            self.service.authorizer = appDelegate.myAuth
            
        } else {
            //signInButton.hidden = false
            signOutButton.isHidden = true
            selectWorkbook.isHidden = true
        }
    }


    @IBAction func tappedSignOut(_ sender: AnyObject) {
         GIDSignIn.sharedInstance().signOut()
         statusText.text = "Signed out."
         toggleAuthUI()
    }
    
    
    func callAppsScript(_ scriptName: String) {
        
     //   print("CALLING ASE!")
        
        statusText.text = "Accessing Google Drive..."
        let baseUrl = "https://script.googleapis.com/v1/scripts/\(kScriptId):run"
        let url = GTLUtilities.url(with: baseUrl, queryParameters: nil)
        
     //   print("REQUEST URL")
     //   print(url)
        
        // Create an execution request object.
        let request = GTLObject()
        request.setJSONValue(scriptName, forKey: "function")
        
        if scriptName == "getEquip" {
            let fileId = fileIds[selectedFileIndex]
            
            let requestParams = [["header", fileId]]
       //     print("SELECTED FILE ID")
       //     print(requestParams[0][1])
            
            request.setJSONValue(requestParams, forKey: "parameters")
        } //end if getEquip
        

        
    //    print("REQUEST OBJECT")
    //    print(request)
        
        // Make the API request.
        service.fetchObject(byInserting: request,
                                             for: url!,
                                             delegate: self,
                                             didFinish: #selector(NewSelectViewController.displayResultWithTicket(_:finishedWithObject:error:)))
        requestProcessing = true
        isBusy.isHidden = false
        statusText.text = "Accessing Google Drive..."
    }
    
    // Displays the items returned by the Apps Script function.
    func displayResultWithTicket(_ ticket: GTLServiceTicket,
                                 finishedWithObject object : GTLObject,
                                                    error : NSError?) {
        if let error = error {
            // The API encountered a problem before the script
            // started executing.
            
         //   print("API ERROR BEFORE SCRIPT EXECUTION")
            let showAlert = "The API returned the error: /(message: error.localizedDescription)"
            statusText.text = showAlert
            return
        }
        
        if let apiError = object.json["error"] as? [String: AnyObject] {
            // The API executed, but the script returned an error.
            
            // Extract the first (and only) set of error details and cast as
            // a Dictionary. The values of this Dictionary are the script's
            // 'errorMessage' and 'errorType', and an array of stack trace
            // elements (which also need to be cast as Dictionaries).
            
      //      print("SCRIPT EXECUTED; ERROR RETURNED")
            
            let details = apiError["details"] as! [[String: AnyObject]]
            var errMessage = String(
                format:"Script error message: %@\n",
                details[0]["errorMessage"] as! String)
            
            if let stacktrace =
                details[0]["scriptStackTraceElements"] as? [[String: AnyObject]] {
                // There may not be a stacktrace if the script didn't start
                // executing.
                for trace in stacktrace {
                    let f = trace["function"] as? String ?? "Unknown"
                    let num = trace["lineNumber"] as? Int ?? -1
                    errMessage += "\t\(f): \(num)\n"
                }
            }
            
            // Set the output as the compiled error message.
            statusText.text = errMessage
        } else {
                
                let response = object.json["response"] as! [String: AnyObject]
                let responseSet = response["result"] as! [String: AnyObject]
                if responseSet.count == 0 {
                    //Show alert if no items returned
                    let alert = UIAlertController(title: "Alert:", message: "No equipment found. Please make sure you have selected the correct workbook.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    //Hide busy animation and toggle requestProcessing
                    requestProcessing = false
                    isBusy.isHidden = true
                    statusText.text = "Ready"
                    
                } else {
                    //Start by clearing selected items and ids
                    selectItems = []
                    selectIds = []
                    
                    for (id, sheet) in responseSet {
                        //sheetString += "\t\(sheet)\n"
                        selectItems.append(sheet as! String)
                        selectIds.append(id )
                    }
                    
               
               /*     print("ASE SUCCESS!!")
                    //print(sheetString)
                    
               //     print("NAME ARRAY")
                    for i in 0...(selectItems.count-1) {
                       print(selectItems[i])
                    }
                    
               //     print("ID ARRAY")
                    for i in 0...(selectIds.count-1) {
                        print(selectIds[i])
                    }
 */
                    
                    //Save to appropriate array
                    if currentRequestName == "getFilesUnderRoot" {
                        fileNames = selectItems
                        fileIds = selectIds
                        requestProcessing = false
                        isBusy.isHidden = true
                        statusText.text = "Ready"
                        self.performSegue(withIdentifier: "selectListEquipSegue", sender: self)
                    }
                    if currentRequestName == "getEquip" {
                        equipNames = selectIds // here, the name is the unique identifier in the JSON pair
                        equipTypes = selectItems // and the item value is now type (tractor/ equip)
                        requestProcessing = false
                        isBusy.isHidden = true
                        statusText.text = "Ready"
                       clearAndOverWrite()

                        //####SEND USER BACK TO MAKE SELECTION SCENE
                        self.performSegue(withIdentifier: "didImportSegue", sender: self)
                        
                        
                    }
                    
                }
        } // end else not error
    }// end displayResult


    @IBAction func tappedSelectWorkbook(_ sender: AnyObject) {
        if !requestProcessing {
        currentRequestName = "getFilesUnderRoot"
        callAppsScript(currentRequestName)
        } else {
            let alert = UIAlertController(title: "Alert:", message: "Please wait for a response from Google Drive.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func
        makeListSelection(_ segue:UIStoryboardSegue){
        
        let incoming = segue.source as! SelectListViewController
        let selectedEntry = incoming.chosenName
    //    print("INCOMING SEGUE")
    //    print(incoming)
        
        if currentRequestName == "getFilesUnderRoot" {
            selectedFileIndex = incoming.chosenIndex
        //    Set the labelFile next to the select workbook button w/ the file name
            labelFile.text = selectedEntry
            
            importEquipment.isHidden = false

            
        }
        
    //    print("CHOSEN NAME")
      //  print(selectedEntry)
        if selectedEntry == "" {
       //     print("SELECTED ENTRY IS BLANK")
        }
    //    print("Index selected:")
    //    print(incoming.chosenIndex)
    }
    
    
    @IBAction func tappedDoImport(_ sender: AnyObject) {
        if !requestProcessing {
        currentRequestName = "getEquip"
        callAppsScript(currentRequestName)
        } else{
            let alert = UIAlertController(title: "Alert:", message: "Please wait for a response from Google Drive.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }

    //Delete all existing records with tractors and / or equipment
    
    func clearAndOverWrite() {
        
        //first obtain separate lists of tractors and implements
        var tractorNames = [String]()
        var implementNames = [String]()
        
        var tractorListStart = [Tractor]()
        var implementListStart = [Equipment]()
        
        var tractorsToAdd = [String]()
        var implementsToAdd = [String]()
        
        
        for i in 0...(equipNames.count - 1){
            if equipTypes[i] == "tractor" {
                tractorNames.append(equipNames[i])
            } else {
                implementNames.append(equipNames[i])
            }
        }
        
        //get tractors and implements from DB
            let managedContext = appDelegate.managedObjectContext
            
            let equipRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Equipment")
            do {
                //Retrieve equipment
                let equips = try managedContext.fetch(equipRequest)
                implementListStart = equips as! [Equipment]
                
            } catch let error as NSError {
          //      print("Could not fetch equipment\(error), \(error.userInfo)")
            }
            

            let tractorRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tractor")
            do {
                //Retrieve equipment
                let tractors = try managedContext.fetch(tractorRequest)
                tractorListStart = tractors as! [Tractor]
                
            } catch let error as NSError {
          //      print("Could not fetch tractor\(error), \(error.userInfo)")
            }
            
            //Add "No tractor" and "No equipment" to lists if not already present
            if !tractorNames.contains("No Tractor") {
                tractorNames.append("No Tractor")
            }
            if !implementNames.contains("No Implement") {
                implementNames.append("No Implement")
            }
            
            //Get tractors to add
            for i in 0...(tractorNames.count - 1){
                var isPresent = false
                for j in 0...(tractorListStart.count - 1){
                    if tractorNames[i] == tractorListStart[j].tractor_name {
                        isPresent = true
                    }
                }
                if !isPresent {
                    tractorsToAdd.append(tractorNames[i]) }
            }
        //    print("Tractors to add:")
        //    print(tractorsToAdd)
            
            //Get implements to add
            for i in 0...(implementNames.count - 1){
                var isPresent = false
                for j in 0...(implementListStart.count - 1){
                    if implementNames[i] == implementListStart[j].equip_name {
                        isPresent = true
                    }
                }
                if !isPresent {
                    implementsToAdd.append(implementNames[i]) }
            }
         //   print("Implements to add:")
         //   print(implementsToAdd)
        
        //Disabling delete - populate now synchs equipment with equip on list
            /*
            //Delete tractors not contined in tractorNames
            for i in 0...(tractorListStart.count - 1){
                if !tractorNames.contains(tractorListStart[i].tractor_name){

                    managedContext.deleteObject(tractorListStart[i])
                    //Removes the selected entity from the list
                    tractorListStart.removeAtIndex(i)
                    //Save to memory
                    do {
                        // Saves the managed object context
                        try managedContext.save()
                    } catch let error as NSError  {
                        print("Could not save \(error), \(error.userInfo)")
                    }

                }
            } //end delete tractors
            
            //Delete implements not contined in implementNames
            for i in 0...(implementListStart.count - 1){
                if !implementNames.contains(implementListStart[i].equip_name){

                    managedContext.deleteObject(implementListStart[i])
                    //Removes the selected entity from the list
                    implementListStart.removeAtIndex(i)
                    //Save to memory
                    do {
                        // Saves the managed object context
                        try managedContext.save()
                    } catch let error as NSError  {
                        print("Could not save \(error), \(error.userInfo)")
                    }
                    
                }
            }//end delete implements
            */
        
            //Add new tractors
            if tractorsToAdd.count > 0 {
            for i in 0...(tractorsToAdd.count - 1){
                
                let entity =  NSEntityDescription.entity(forEntityName: "Tractor", in:managedContext)
                let record = Tractor(entity: entity!, insertInto: managedContext)
                
                //This sets the values of the entity attributes
                record.setValue(tractorsToAdd[i], forKey: "tractor_name")
                
                do {
                    // Save the managed object context
                    try managedContext.save()
                } catch let error as NSError  {
              //      print("Could not save \(error), \(error.userInfo)")
                }
                
            }
            }//end add new tractors
            
            //Add new implements
            if implementsToAdd.count > 0 {
            for i in 0...(implementsToAdd.count - 1){
                
                let entity =  NSEntityDescription.entity(forEntityName: "Equipment", in:managedContext)
                let record = Equipment(entity: entity!, insertInto: managedContext)
                
                //This sets the values of the entity attributes
                record.setValue(implementsToAdd[i], forKey: "equip_name")
                
                do {
                    // Save the managed object context
                    try managedContext.save()
                } catch let error as NSError  {
             //       print("Could not save \(error), \(error.userInfo)")
                }
                
            }
            }//end add new implements
        
    }//end clearAndOverWrite
    
    
    
    
    //########################################################################################### Done with ASE
    

    
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
