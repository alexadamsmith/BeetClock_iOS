//
//  SynchViewController.swift
//  BeetClock_A1
//
//  Created by Alex Smith on 2/18/17.
//  Copyright © 2017 BeetWorks. All rights reserved.
//

import Foundation
import UIKit
import CoreData
//import MessageUI
import GoogleAPIClient
import GTMOAuth2


class SynchViewController: UITableViewController, GIDSignInUIDelegate {

    
    //Interface obj req
    //statusText
    //signInButton
    //signOutButton
    //selectWorkbook
    
    ////Interface objects
    @IBOutlet weak var statusText: UILabel!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var signInButton: GIDSignInButton!
    @IBOutlet weak var selectWorkbook: UIButton!
    @IBOutlet weak var exportDataButton: UIButton!
    @IBOutlet weak var workbookLabel: UILabel!
    @IBOutlet weak var startDateButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    //Select a start date
    var dateSelected = false
    var selectedDate = Double()
    
    
    
    // ##############GoogleAppsScriptObjects
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var requestProcessing = Bool()
    
    var currentRequestName = String()
    
    var userName = String()
    
    var selectedFileIndex = Int()

    var fileNames = [String]()
    var fileIds = [String]()
    
    //Data from the workbook
    var wsCropNames = [String]()
    var wsJobNames = [String]()
    var wsEquipNames = [String]()
    var wsUserNames = [String]()
    var wsRecordIds = [String]()
    
    //Data not present on the workbook
    var newCropNames = [String]()
    var newJobNames = [String]()
    var newEquipNames = [String]()
    var newUserNames = [String]()
    var newRecordIds = [String]()
    
    var newCJEUParameters = [String: String]()
    var newRecordParameters = [String: String]()
    
    
    var worksheetNames = [String]()
    //var worksheetIds = [String]()
    
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
     
        //SET COLORS
        
        // Set the button colors
        signOutButton.backgroundColor = colorBank.GetUIColor("navbar")
        exportDataButton.backgroundColor = colorBank.GetUIColor("navbar")
        selectWorkbook.backgroundColor = colorBank.GetUIColor("tractor")
        startDateButton.backgroundColor = colorBank.GetUIColor("job")
        
        //Set the background color
        self.tableView.backgroundColor = colorBank.GetUIColor("background")
        
        
        // Change the navigation bar background color
        navigationController!.navigationBar.barTintColor = colorBank.GetUIColor("navbar")
        
        // Change the color of the navigation bar button items to white.
        navigationController!.navigationBar.tintColor = UIColor.white
        
        ////
        
        //Start Google sign in service
        GIDSignIn.sharedInstance().uiDelegate = self
        
        if (GIDSignIn.sharedInstance().hasAuthInKeychain()){
            GIDSignIn.sharedInstance().signOut()
        }
        
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(ExportViewController2.receiveToggleAuthUINotification(_:)),
                                               name: NSNotification.Name(rawValue: "ToggleAuthUINotification"), object: nil)

        ////Re-activate when I get this running!
        toggleAuthUI()
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "selectListCrewSegue"{
            let nav = segue.destination as! UINavigationController
            let selectListView = nav.topViewController as! SelectListViewController
            selectListView.selectList = selectItems
        }
    }
    
    
    @objc func receiveToggleAuthUINotification(_ notification: Notification) {
        // if (notification.name == "ToggleAuthUINotification") {
        self.toggleAuthUI()
        if notification.userInfo != nil {
            let userInfo:Dictionary<String,String?> =
                notification.userInfo as! Dictionary<String,String?>
            self.statusText.text = userInfo["statusText"]!
            
            //####!!!!####
            //First, no idea why I need two !s  That's wierd
            //More importantly, I need to clip off the first 25 and last 2 characters in statusText to get only the straight user name
            let userInfoText = userInfo["statusText"]!!
            //First clip the initial 25 characters
            let userNameSub1 = (userInfoText as NSString).substring(from: 25)
            //Then the last two.  This should produce the straight user name
            userName = (userNameSub1 as NSString).substring(to: (userNameSub1.characters.count - 2) )
            print("USER INFO TEXT")
            print(userInfoText)
            print("USER NAME TEXT")
            print(userName)
            
        }
        //}
    }// end func
    
    @IBAction func tappedSignOut(_ sender: Any) {
        GIDSignIn.sharedInstance().signOut()
        statusText.text = "Signed out."
        toggleAuthUI()
    }
    

    @IBAction func tappedSelectWorkbook(_ sender: Any) {
        if !requestProcessing {
            currentRequestName = "getFilesUnderRoot"
            callAppsScript(currentRequestName)
            requestProcessing = true
            statusText.text = "Accessing Google Drive..."
        } else{
            let alert = UIAlertController(title: "Alert:", message: "Please wait for a response from Google Drive.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }

    
    

    @IBAction func selectDate(_ segue:UIStoryboardSegue){
        
        let incoming = segue.source as! SelectDateViewController
        
        dateSelected = true
        selectedDate = incoming.pickedDate
        
        //Formatting timestamp as string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yy"
        let dateFormat = dateFormatter.string(from: Date(timeIntervalSince1970:(selectedDate/1000)))
        
        //chooseDate.setTitle("Start date: \(dateFormat)", forState: UIControlState.Normal)
        dateLabel.text = "\(dateFormat)"
        //   print("Date selected:")
        //   print(dateFormat)
        
    }
    
    
    ////Select sheet and return
    @IBAction func
        makeListSelection(_ segue:UIStoryboardSegue){
        
        let incoming = segue.source as! SelectListViewController
        let selectedEntry = incoming.chosenName
        //  print("INCOMING SEGUE")
        //  print(incoming)
        
        if currentRequestName == "getFilesUnderRoot" {
            selectedFileIndex = incoming.chosenIndex
            
            workbookLabel.text = selectedEntry
            
            
        }
        
        if selectedEntry == "" {
            //      print("SELECTED ENTRY IS BLANK")
        }
        
    } //end makeListSeelction
    
    
    ////Write records to sheet
    @IBAction func exportData(_ sender: Any) {
        
        if !requestProcessing {
            currentRequestName = "getCrewData"
            callAppsScript(currentRequestName)
            requestProcessing = true
            statusText.text = "Accessing Google Drive..."
        } else{
            let alert = UIAlertController(title: "Alert:", message: "Please wait for a response from Google Drive.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        
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
            signInButton.isHidden = false
            signOutButton.isHidden = true
            selectWorkbook.isHidden = true
            
        }
    }
    
    //Process
    //1 get all cjeu from ws
    //2 compare w/ db
    //3 add new cjeu as needed
    //4 get all records from ws for ser
    //5 compare w/ db on the basis of milli timestamps
    //6 delete records as needed
    //7 add records as needed

    ////Functions to retrieve all crops, jobs, equipment, usernames, records

    
    //Initiate process by retrieving crops
    func checkCJEUR(){
        wsCropNames = []
        wsJobNames = []
        wsEquipNames = []
        wsUserNames = []
        wsRecordIds = []
        
        //Break out returned values by type
        for i in 0...(selectIds.count - 1) {
            if selectIds[i].contains("crop"){
                wsCropNames.append(selectItems[i])
            }
            if selectIds[i].contains("job"){
                wsJobNames.append(selectItems[i])
            }
            if selectIds[i].contains("equip"){
                wsEquipNames.append(selectItems[i])
            }
            if selectIds[i].contains("user"){
                wsUserNames.append(selectItems[i])
            }
            if selectIds[i].contains("record"){
                wsRecordIds.append("\(selectItems[i])")
            } //Record IDs are numeric, but for now I am treating them as strings
            
        }
        print("CROP NAMES")
        print(wsCropNames)
        print("JOB NAMES")
        print(wsJobNames)
        print("EQUIP NAMES")
        print(wsEquipNames)
        print("USER NAMES")
        print(wsUserNames)
        print("RECORD IDS")
        print(wsRecordIds)

        //Generate lists of NEW crops, jobs, equip and records!
        populateWorkbook()
    }
    
    
    
    //continue down chain using getResultWithTicket in doScriptExecute
    //May consider boolean haveCrops, haveJobs, haveEquip, haveUsers, along with some kind of getting CJEUR switch, if I intend to use the get functions elseqhere in this activity.  If not, I can just rope them copletely into the chain.
  
    func callAppsScript(_ scriptName: String) {
        
        print("CALLING ASE!")
        print(scriptName)
        
        
        let baseUrl = "https://script.googleapis.com/v1/scripts/\(kScriptId):run"
        let url = GTLUtilities.url(with: baseUrl, queryParameters: nil)
    
        //print("REQUEST URL")
        //print(url)
        
        // Create an execution request object.
        let request = GTLObject()
        request.setJSONValue(scriptName, forKey: "function")
        
        
        if scriptName == "getCrewData" {
            
            print("GETTING DATA FROM CREW WORKBOOK")
            let fileId = fileIds[selectedFileIndex]
            
            let requestParams = [["header", fileId]]
            print("SELECTED FILE ID")
            print(requestParams[0][1])
            
            request.setJSONValue(requestParams, forKey: "parameters")
        } else if scriptName == "sendNewCJEU" {
            print("SENDING CROP, JOB, EQUIPMENT AND USER DATA TO WORKBOOK")

            let requestParams = newCJEUParameters
                print("DATA SEND PARAMETERS")
            print(newCJEUParameters)
            
            request.setJSONValue(requestParams, forKey: "parameters")
            
        } else if scriptName == "sendNewRecords" {
            print("SENDING NEW RECORDS TO WORKBOOK")
            
            let requestParams = newRecordParameters
            print("DATA SEND PARAMETERS")
            print(newRecordParameters)
            
            request.setJSONValue(requestParams, forKey: "parameters")
        }
        
        
        //end if sheetNames
        

        
        //   print("REQUEST OBJECT")
        //   print(request)
        
        // Make the API request.
        service.fetchObject(byInserting: request,
                            for: url!,
                            delegate: self,
                            didFinish: #selector(ExportViewController2.displayResultWithTicket(_:finishedWithObject:error:)))
    }
    
    // Displays the retrieved folders returned by the Apps Script function.
    func displayResultWithTicket(_ ticket: GTLServiceTicket,
                                 finishedWithObject object : GTLObject,
                                 error : NSError?) {
        if let error = error {
            // The API encountered a problem before the script
            // started executing.
            
            print("API ERROR BEFORE SCRIPT EXECUTION")
            let showAlert = "The API returned the error: /(message: error.localizedDescription)"
            statusText.text = showAlert
            
            print(showAlert)
            
            requestProcessing = false
            return
        }
        
        if let apiError = object.json["error"] as? [String: AnyObject] {
            // The API executed, but the script returned an error.
            
            // Extract the first (and only) set of error details and cast as
            // a Dictionary. The values of this Dictionary are the script's
            // 'errorMessage' and 'errorType', and an array of stack trace
            // elements (which also need to be cast as Dictionaries).
            
            //   print("SCRIPT EXECUTED; ERROR RETURNED")
            
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
            print("APPS SCRIPT EXECUTION RETURNED AN ERROR")
            print(errMessage)
            
            //!!!!!!!
            
            requestProcessing = false
        } else {
            
            if currentRequestName == "sendNewCJEU" {
                //Once crops, jobs, equipment and users are sent, begin sending new records
                currentRequestName = "sendNewRecords"
                callAppsScript(currentRequestName)
                //Don't return message until records are populated. 
                
            } else if currentRequestName == "sendNewRecords"{
                statusText.text = "Workbook "+fileNames[selectedFileIndex]+" populated successfully!"
                requestProcessing = false
                
            } else {
                
                let response = object.json["response"] as! [String: AnyObject]
                let responseSet = response["result"] as! [String: AnyObject]
                print("SCRIPT RESPONSE:")
                print(response)
                print("SCRIPT RESPONSE SET:")
                print(responseSet)
                
                
                if responseSet.count == 0 {
                    
                    
                    statusText.text = "No items returned!\n"
                    requestProcessing = false
                } else {
                    //Start by clearing selected items and ids
                    selectItems = []
                    selectIds = []
                    
                    for (id, item) in responseSet {
                        //sheetString += "\t\(sheet)\n"
                        //selectItems.append(item as! String)
                        // apparently as! doesn't work in this case...
                        selectItems.append("\(item)")
                        selectIds.append(id)
                        print("NEW SELECTITEM")
                        print(item)
                    }
                    
                    if currentRequestName == "getFilesUnderRoot" {
                        
                        print("ALL SELECTITEMS")
                        print(selectItems)
                        
                        fileNames = selectItems
                        fileIds = selectIds
                        requestProcessing = false
                        statusText.text = "Ready"
                        self.performSegue(withIdentifier: "selectListCrewSegue", sender: self)
                        
                        print("WORKSHEET IDS")
                        print("ALL SELECTITEMS")
                        print(selectItems)

                    }
 
                    if currentRequestName == "getCrewData" {
                        
                        checkCJEUR()
                        requestProcessing = false
                        statusText.text = "Ready"
                        
                    }
                    
                    
                    //Send user to make selection
                    //presentViewController(selectListView, animated: true, completion: nil)

                    //self.performSegue(withIdentifier: "selectListCrewSegue", sender: self)
                    //}//end else current request name not getEquip
                    
                }
            }//end else not sending values
        } // end else not error
            
    }// end displayResult

 
    
    
    
    //##################All functions below generate data summaries for populating the sheet
    
    //####!!!!####
    
    
    //This function retrieves crops, jobs, equipment and records, checks them against records retrieved from the worksheet, and writes NEW items to the worksheet!
    func populateWorkbook(){
        
        let managedContext = appDelegate.managedObjectContext

        //Start by setting all lists of new assets to zero
        newCropNames = []
        newJobNames = []
        newEquipNames = []
        newUserNames = []
        newRecordIds = []
        
        var workList = [Work_record]()

        
        //Getting all records after the start date
        let workRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Work_record")
        if dateSelected {
            //If date selected, search by crop and date with a compound predicate
            let predSelect = NSNumber(value: selectedDate as Double)
            let datePredicate = NSPredicate(format: "%K > %@", "timestamp", predSelect)
            workRequest.predicate = datePredicate

        }
        
        do {
            //Retrieve work records
            let records = try managedContext.fetch(workRequest)
            workList = records as! [Work_record]
        } catch let error as NSError {
            //    print("Could not fetch work records\(error), \(error.userInfo)")
        }
        //!!!!!
        //If there are work records in the selected time period, proceed
        if workList.count > 0 {
 
   
//Time to identify non-duplicate records in the database that are not already present on the worksheet
            
//Make lists of the crops, jobs, tractors, implements and users contained in the work records
            var workCrops = [String]()
            var workJobs = [String]()
            var workImplems = [String]()
            var workTractors = [String]()
            var workIDS = [String]()
            
            
//Now go through all work records and append values to the lists above
 for i in 0...(workList.count - 1){
    workCrops.append( workList[i].cropRelate.value(forKey: "crop_name") as! String )
    workJobs.append( workList[i].jobRelate.value(forKey: "job_name") as! String )
    workImplems.append( workList[i].equipRelate.value(forKey: "equip_name") as! String )
    workTractors.append( workList[i].tractorRelate.value(forKey: "tractor_name") as! String )
    workIDS.append( String(workList[i].timestamp) )
 
            }//end workList for
            
            //Now I can use the checkWSandDuplicates function to populate the newCropNames and newJobNames arrays
            newCropNames = checkWSandDuplicates(dbNames: workCrops, wsNames: wsCropNames)
            
            newJobNames = checkWSandDuplicates(dbNames: workJobs, wsNames: wsJobNames)

            newRecordIds = checkWSandDuplicates(dbNames: workIDS, wsNames: wsRecordIds)
            //For equipment, which combines both implements and tractors, I will have to be tricky.
                //??What info / format is wsEquipNames??
            //wsEquipNames includes both tractors and implements, prefixed w/ tractor: and implement:
            //However it should be fine to use the full list, as tractors and implements should not share the same name
            //Worst case, two copies of a single name will show up on the WS.  not a big problem
            var newTractorNames = checkWSandDuplicates(dbNames: workTractors, wsNames: wsEquipNames)
            var newImplemNames = checkWSandDuplicates(dbNames: workImplems, wsNames: wsEquipNames)

            
            
            if newTractorNames.count > 0 {
            for i in 0...(newTractorNames.count - 1){
                newEquipNames.append("Tractor: "+newTractorNames[i])
                }
            }//end newTractorNames
            
            if newImplemNames.count > 0 {
                for i in 0...(newImplemNames.count - 1){
                    newEquipNames.append("Implement: "+newImplemNames[i])
                }
            }
            

            //There is only one local user name, so I do not have to iterate this check
            // if the current user is not contined in the worksheet, add to a list of new users
            var isNewUser = true

            print("WORKSHEET USER NAMES")
            print(wsUserNames)
            
            if wsUserNames.count > 0 {
            for j in 0...(wsUserNames.count - 1){
                if wsUserNames[j].contains(userName) {
                    isNewUser = false
                } //end if worklist
            } // end for
            }// end if wsUserNames
            
            if isNewUser {
                newUserNames.append(userName)
                print ("NEW USER NAME TO APPEND")
                print (userName)
                print ("NEW USER NAMES APPENDED")
                print (newUserNames)

            }
            
            //COMBINE ALL NEW VALUES INTO THE DICTIONARY newCJEUParameters
            
            //first we must clear the dictionary
            newCJEUParameters = [String:String]()
            
            //then we can add new values to it
            print("NEW CROP NAMES COUNT")
            print(newCropNames.count)
            if newCropNames.count > 0 {
            //Add crop names to the dictionary of parameters
            for i in 0...(newCropNames.count - 1) {
                let labelValue = "crop"+String(i)
                newCJEUParameters[labelValue] = newCropNames[i]
                print("NEW CROP PARAMETERS")
                print(newCJEUParameters)
            }
            }
            if newJobNames.count > 0 {
            //Job names
            for i in 0...(newJobNames.count - 1) {
                let labelValue = "job"+String(i)
                newCJEUParameters[labelValue] = newJobNames[i]
            }
            }
            if newEquipNames.count > 0 {
            //Equip names
            for i in 0...(newEquipNames.count - 1) {
                let labelValue = "equip"+String(i)
                newCJEUParameters[labelValue] = newEquipNames[i]
            }
            }
            if newUserNames.count > 0 {
            //User names
            for i in 0...(newUserNames.count - 1) {
                let labelValue = "user"+String(i)
                newCJEUParameters[labelValue] = newUserNames[i]
            }
            }
            
            //Finally we need to attach the current sheet name to the request
            newCJEUParameters["fileId"] = fileIds[selectedFileIndex]

            //call the script to populate worksheets with CJEU values
            currentRequestName = "sendNewCJEU"
            callAppsScript(currentRequestName)


//Sending work records with unique IDs
//for each work list entry, check if it is new.  If new, write all values to newRecordParameters
            var recordNumber = 0
            for i in 0...(workList.count - 1) {
                let recordId = workList[i].timestamp
                var isNewRecord = false
                if newRecordIds.count > 0 {
                for j in 0...(newRecordIds.count - 1) {
                    if newRecordIds[j].contains(String(recordId)) {
                       isNewRecord = true
                                    }//end if newRecords
                }//end for recordId
                }//end if newRecordIds
                if isNewRecord {
                    
                newRecordParameters["wked"+String(recordNumber)] = String(workList[i].ms_worked)
                newRecordParameters["wkrs"+String(recordNumber)] = String(describing: workList[i].workers)
                newRecordParameters["rcid"+String(recordNumber)] = String(workList[i].timestamp)
                newRecordParameters["crop"+String(recordNumber)] = workList[i].cropRelate.value(forKey: "crop_name") as! String
                newRecordParameters["jobn"+String(recordNumber)] = workList[i].jobRelate.value(forKey: "job_name") as! String
                newRecordParameters["user"+String(recordNumber)] = userName
                
                //We need to replace blank notes fields with a placeholder, as the crew workbook doesn't handle missing values well.
                    if workList[i].notes == "" {
                        newRecordParameters["note"+String(recordNumber)] = "NA"
                    } else {
                        newRecordParameters["note"+String(recordNumber)] = workList[i].notes
                    }
                
                
                //Now we need to string together tractors and implements into a single equipment entry
                let currentImplem = workList[i].equipRelate.value(forKey: "equip_name") as! String
                let currentTractor = workList[i].tractorRelate.value(forKey: "tractor_name") as! String
                newRecordParameters["eqip"+String(recordNumber)] = "Tractor: "+currentTractor+"; Implement: "+currentImplem
                
                //Now we will need to parse the timestamp into a date string, and index as date
                //Formatting timestamp as string
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM-dd-yy"
                
                let recordDate = workList[i].timestamp
                let dateFormat = dateFormatter.string(from: Date(timeIntervalSince1970:(recordDate/1000)))
                newRecordParameters["date"+String(recordNumber)] = dateFormat
                
                    //and finally advance recordNumber by one
                    recordNumber += 1
                    
                }//end if isNewRecord
                
            }//end for workList
        
            //Finally we need to attach the current sheet name to the request
            newRecordParameters["fileId"] = fileIds[selectedFileIndex]
            
            //And the length of the record sheet being produced
            newRecordParameters["recordCount"] = String(recordNumber)
  
            //The actual request will be called once sendNewCJEU is done executing (called in getResultWithTicket)
            
        }//end if worklist > 0
        
        }//end populate workbook
    
    
    //!!!!!BOOKMARK
    //This function checks each name in the database (dbNames) to see if it is already present on the worksheet (wsNaames)  It returns a list of new names WITHOUT DUPLICATES
    func checkWSandDuplicates (dbNames: [String], wsNames: [String]) -> [String]{
    
    //if a record contains equipment not already in the worksheet, add to a list of new equipment
    var newNames = [String]()
    
    //Cycle through all names in the local database
        for i in 0...(dbNames.count - 1) {
        
    var isNew = true
            
    //First I will check if the equip name is already on the worksheet
    for j in 0...(wsNames.count - 1){
        //for some reason, this comparison does not work when non-Roman characters are used...
        //I'll leave it for now, as the app is currently only enabled for English
    if String(wsNames[j]).contains(String(dbNames[i])) {
    isNew = false
    } //end if
    } // end for
    
    //Then I will see if it has already been added to the list of new equipment
    if newNames.count > 0 {
    for j in 0...(newNames.count - 1){
    if newNames[j].contains(dbNames[i]){
    isNew = false
    }//end if
    }//end for
    }//end if
    
    //Finally, if the value is neither in the worksheet nor already on the new list, add it to the new list
    if isNew {
    newNames.append(dbNames[i])
    }
            
    }//end for dbNames
    
        return(newNames)
        
    }//end checkWSAndDuplicates
 
  }//End SynchViewController
