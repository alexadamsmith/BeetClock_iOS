//
//  ExportViewController2.swift
//  BeetClock_A1
//
//  Created by Alex Smith on 11/30/16.
//  Copyright © 2016 BeetWorks. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MessageUI
import GoogleAPIClient
import GTMOAuth2

@objc(ExportViewController2)

class ExportViewController2: UITableViewController, GIDSignInUIDelegate, MFMailComposeViewControllerDelegate  {
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    

    
    @IBOutlet weak var sendEmail: UIButton!
    @IBOutlet weak var chooseDate: UIButton!
    @IBOutlet weak var sendToWorkbook: UIButton!
    //@IBOutlet weak var sendToCrew: UIButton!
    @IBOutlet weak var worksheetSegment: UISegmentedControl!
    
    @IBOutlet weak var signInButton: GIDSignInButton!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var statusText: UILabel!
    
    @IBOutlet weak var labelWorkbook: UILabel!
    @IBOutlet weak var labelSheet: UILabel!
    @IBOutlet weak var labelCrop: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    
    @IBOutlet weak var selectWorkbook: UIButton!
    @IBOutlet weak var selectSheet: UIButton!
    @IBOutlet weak var selectCrop: UIButton!
    
    @IBOutlet weak var populateSheet: UIButton!
    
    @IBOutlet weak var isBusy: UIActivityIndicatorView!
    
    //Am I sending data to the crew workbook?  Toggle to adjust functionality
    var popCrew = true
    
    //Select a date
    var dateSelected = false
    var selectedDate = Double()
    
    //Contains data to be summarized
    var cropList = [Crop]()
    var workList = [Work_record]()
    
    //String summary outputs
    var outSummary = [String]()
    var outHeaders = [String]()
    var outCrops = [String]()
    
    //Tallies of hours
    var totalHours = Double()
    var jobHours = [Double]()
    var equipHours = [Double]()
    var tractorHours = [Double]()
    
    //Data objects for worksheet summary
    var jobEquipHours = [Double]()
    var jobImplements = [String]()
    var jobTractors = [String]()
    
    
    
    //######################### GOOGLE APPS SCRIPT EXECUTE OBJECTS
    
    var requestProcessing = Bool()
    
    var popValues = ["72","BCS 740","Rototiller","94"]
    
    var currentRequestName = String()
    
    var userName = String()
    
    var selectedFileIndex = Int()
    var selectedSheetIndex = Int()
    var selectedCropIndex = Int()
    
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
    
    var equipNames = [String]()
    var equipTypes = [String]()
    
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
        
        /*
         @IBOutlet weak var sendEmail: UIButton!
         @IBOutlet weak var sendToWorkbook: UIButton!
         @IBOutlet weak var chooseDate: UIButton!
         
         @IBOutlet weak var signInButton: GIDSignInButton!
         @IBOutlet weak var signOutButton: UIButton!
         @IBOutlet weak var statusText: UILabel!
         
         @IBOutlet weak var labelWorkbook: UILabel!
         @IBOutlet weak var labelSheet: UILabel!
         @IBOutlet weak var labelCrop: UILabel!
         
         
         @IBOutlet weak var selectWorkbook: UIButton!
         @IBOutlet weak var selectSheet: UIButton!
         @IBOutlet weak var selectCrop: UIButton!
         
         @IBOutlet weak var populateSheet: UIButton!
         
 */
        
        
        // Set the button colors
        sendEmail.backgroundColor = colorBank.GetUIColor("crop")
        chooseDate.backgroundColor = colorBank.GetUIColor("job")
        sendToWorkbook.backgroundColor = colorBank.GetUIColor("implement")
        selectWorkbook.backgroundColor = colorBank.GetUIColor("tractor")
        selectSheet.backgroundColor = colorBank.GetUIColor("job")
        selectCrop.backgroundColor = colorBank.GetUIColor("crop")
        
        signOutButton.tintColor = colorBank.GetUIColor("navbar")
        
        populateSheet.backgroundColor = colorBank.GetUIColor("navbar")

        //Set the background color
        self.tableView.backgroundColor = colorBank.GetUIColor("background")
        
        
        // Change the navigation bar background color
        navigationController!.navigationBar.barTintColor = colorBank.GetUIColor("navbar")
        
        // Change the color of the navigation bar button items to white.
        navigationController!.navigationBar.tintColor = UIColor.white
        
        // Hides the busy icon
        isBusy.isHidden = true
        
        //Start Google sign in service
        GIDSignIn.sharedInstance().uiDelegate = self
        
        if (GIDSignIn.sharedInstance().hasAuthInKeychain()){
            GIDSignIn.sharedInstance().signOut()
        }
        
        //Hide ASE-related interface controls
        signInButton.isHidden = true
        //signOutButton.hidden = true
        //sendToWorkbook.hidden = false
        //selectWorkbook.hidden = true
        //selectSheet.hidden = true
        //selectCrop.hidden = true
        populateSheet.isHidden = true
        
        //Hide the worksheet selector segmented control until worksheet is tapped
        worksheetSegment.isHidden = true
        
        
        //####GIDSignIn.sharedInstance().scopes.append(scopes)
        
        // Uncomment to automatically sign in the user.
        //GIDSignIn.sharedInstance().signInSilently()
        
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(ExportViewController2.receiveToggleAuthUINotification(_:)),
                                                         name: NSNotification.Name(rawValue: "ToggleAuthUINotification"), object: nil)
        
        toggleAuthUI()
        
        //End Google sign in
        
        //print URLs
     //   let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
     //   print(urls);
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    
    @IBAction func tappedSendToWorkbook(_ sender: AnyObject) {
        //Make sign in button visible ONLY if user is not authorized.
//        if (GIDSignIn.sharedInstance().hasAuthInKeychain()){
//        }else{
            signInButton.isHidden = false
            signOutButton.isHidden = true
        //Reveal segmented controller to select worksheet type
            worksheetSegment.isHidden = false
//        }
    }
    
    //Tap send records to crew workbook
    
    /*
    @IBAction func tappedSendToCrew(_ sender: Any) {
        popCrew = true
        signInButton.isHidden = false
    }
 */
    
    @objc func receiveToggleAuthUINotification(_ notification: Notification) {
        
        //####!!!!####
        //This is where I am receiving the user name from Google
        //I need to extract the user name ONLY from it!
        
       // if (notification.name == "ToggleAuthUINotification") {
            self.toggleAuthUI()
            if notification.userInfo != nil {
                let userInfo:Dictionary<String,String?> =
                    notification.userInfo as! Dictionary<String,String?>
                
                //Clip userInfo to obtain user name
                let userInfoText = userInfo["statusText"]!!
                //First clip the initial 25 characters
                let userNameSub1 = (userInfoText as NSString).substring(from: 25)
                //Then the last two.  This should produce the straight user name
                userName = (userNameSub1 as NSString).substring(to: (userNameSub1.characters.count - 2) )

                //self.statusText.text = userInfo["statusText"]!
                self.statusText.text = "User name: "+userName
            }
        //}
    }
    
    func toggleAuthUI() {
        if (GIDSignIn.sharedInstance().hasAuthInKeychain()){
            // Signed in
            signInButton.isHidden = true
            signOutButton.isHidden = false
            selectWorkbook.isHidden = false
            labelWorkbook.isHidden = false
            
            //Set user credentials and make request
            self.service.authorizer = appDelegate.myAuth
            
        } else {
            //signInButton.hidden = false
            signOutButton.isHidden = true
            selectWorkbook.isHidden = true
            selectSheet.isHidden = true
            selectCrop.isHidden = true
            labelWorkbook.isHidden = true
            labelSheet.isHidden = true
            labelCrop.isHidden = true
            populateSheet.isHidden = true
        }
    }

    
    
    @IBAction func tappedSignOut(_ sender: AnyObject) {
        GIDSignIn.sharedInstance().signOut()
        statusText.text = "Signed out."
        toggleAuthUI()
    }
    
    
    @IBAction func tappedSelectWorkbook(_ sender: AnyObject) {
        if !requestProcessing {
            currentRequestName = "getFilesUnderRoot"
            callAppsScript(currentRequestName)
            isBusy.isHidden = false
            requestProcessing = true
            statusText.text = "Accessing Google Drive..."
        } else{
            let alert = UIAlertController(title: "Alert:", message: "Please wait for a response from Google Drive.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func tappedSelectSheet(_ sender: AnyObject) {
        
        if !requestProcessing {
            currentRequestName = "sheetNames"
            callAppsScript(currentRequestName)
            isBusy.isHidden = false
            requestProcessing = true
            statusText.text = "Accessing Google Drive..."
        } else{
            let alert = UIAlertController(title: "Alert:", message: "Please wait for a response from Google Drive.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func tappedPopulateSheet(_ sender: AnyObject) {
        if !requestProcessing {
            
            //If working with the crew data worksheet, call request
            if popCrew {
                currentRequestName = "getCrewData"
                callAppsScript(currentRequestName)
                isBusy.isHidden = false
                requestProcessing = true
                statusText.text = "Accessing Google Drive..."
            } else {
                
                popLists()
                if workList.count > 0 {
                    
                    populateCrop()
                    //popCrop will call apps script IF records for the crop exist!
                    
                    //end if records exist
                } else {
                    let alert = UIAlertController(title: "Alert:", message: "You must have saved records to send a report.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }//end if popCrew
            
            //display alert if a request is still processing
        } else{
            let alert = UIAlertController(title: "Alert:", message: "Please wait for a response from Google Drive.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            //end requestProcessing = false
        }
    }
    
    //
    //This blocks the select crop segue if the ASE request is pending
    override func shouldPerformSegue(withIdentifier identifier: String!, sender: Any!) -> Bool {
        if identifier == "selectCropSegue" {
            
            //Present popup warning if text was not entered
            if requestProcessing {
                let alert = UIAlertController(title: "Alert:", message: "Please wait for a response from Google Drive.", preferredStyle: UIAlertControllerStyle.alert)
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
        
        if segue.identifier == "selectListSegue"{
            let nav = segue.destination as! UINavigationController
            //let tvc = nav.topViewController as! SelectionViewController
            let selectListView = nav.topViewController as! SelectListViewController
            selectListView.selectList = selectItems
        }
        
        if segue.identifier == "selectCropSegue"{
            let nav = segue.destination as! UINavigationController
            let selectCropView = nav.topViewController as! SelectionViewController
            selectCropView.selectType = "cropWithRecord"
            selectCropView.canEdit = false
        }
        
        /*  Crew export now integrated into this controller
        if segue.identifier == "exportToCrew"{
            // Dismiss the mail compose view controller.  Originally controller.dismiss...
            let controller = MFMailComposeViewController()
            controller.dismiss(animated: true, completion: nil)
            //Does NOT get rid of NO MAIL ACCOUNTS warning!
        }
 */
        
    } // end prepare for segue
  
    
//RECEIVE USER SELECTIONS FROM A DISPLAYED LIST
    
    @IBAction func
        makeListSelection(_ segue:UIStoryboardSegue){
        
        let incoming = segue.source as! SelectListViewController
        let selectedEntry = incoming.chosenName
        //  print("INCOMING SEGUE")
        //  print(incoming)
        
        if currentRequestName == "getFilesUnderRoot" {
            selectedFileIndex = incoming.chosenIndex
            //   print("SELECTED FILE INDEX")
            //   print(selectedFileIndex)
            //selectWorkbook.setTitle("Workbook selected: "+selectedEntry, forState: UIControlState.Normal)
            labelWorkbook.text = selectedEntry
            
            
            //If populating the crew workbook go ahead and reveil the populate button.  If populating the NOFA workbook rather than the crew workbook, call get equipment at this point
            if popCrew {
                populateSheet.isHidden = false
            }else{
                getEquipment()
            }
        }
        if currentRequestName == "sheetNames" {
            selectedSheetIndex = incoming.chosenIndex
            //    print("SELECTED SHEET INDEX")
            //    print(selectedSheetIndex)
            //selectSheet.setTitle("Worksheet selected: "+selectedEntry, forState: UIControlState.Normal)
            labelSheet.text = selectedEntry
            selectCrop.isHidden = false
            labelCrop.isHidden = false
        }
        
        //  print("CHOSEN NAME")
        //  print(selectedEntry)
        if selectedEntry == "" {
            //      print("SELECTED ENTRY IS BLANK")
        }
        //     print("Index selected:")
        //     print(incoming.chosenIndex)
    }
    
    
    @IBAction func
        makeSelection(_ segue:UIStoryboardSegue){
        
        //First populate lists to have access to crops
        popLists()
        
        let incoming = segue.source as! SelectionViewController
        selectedCropIndex = incoming.listIndex
        let selectedCropName = cropList[selectedCropIndex].crop_name
        //selectCrop.setTitle("Crop selected: "+selectedCropName, forState: UIControlState.Normal)
        labelCrop.text = selectedCropName
        //Make the populate sheet button visible!
        populateSheet.isHidden = false
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
        labelDate.text = "\(dateFormat)"
        //   print("Date selected:")
        //   print(dateFormat)
        
    }
    
    
    
    
    @IBAction func
        cancelSelection(_ segue:UIStoryboardSegue){
        
    }
    
    
    @IBAction func tappedWorksheetSegment(_ sender: Any) {
        
        switch worksheetSegment.selectedSegmentIndex
        {
        case 0:
            popCrew = true
            
            signInButton.isHidden = false
            signOutButton.isHidden = true
            selectWorkbook.isHidden = true
            labelWorkbook.isHidden = true
            selectSheet.isHidden = true
            labelSheet.isHidden = true
            selectCrop.isHidden = true
            labelCrop.isHidden = true
            populateSheet.isHidden = true
        case 1:
            popCrew = false
            
            signInButton.isHidden = false
            signOutButton.isHidden = true
            selectWorkbook.isHidden = true
            labelWorkbook.isHidden = true
            selectSheet.isHidden = true
            labelSheet.isHidden = true
            selectCrop.isHidden = true
            labelCrop.isHidden = true
            populateSheet.isHidden = true
        default:
            break;
        }
        
        
    }
    

    
    
  //############################################################################### Start ASE functions
    
    
    func callAppsScript(_ scriptName: String) {
        
        //print("CALLING ASE!")
        //print(scriptName)
        
        
        let baseUrl = "https://script.googleapis.com/v1/scripts/\(kScriptId):run"
        let url = GTLUtilities.url(with: baseUrl, queryParameters: nil)
        
        //print("REQUEST URL")
        //print(url)
        
        // Create an execution request object.
        let request = GTLObject()
        request.setJSONValue(scriptName, forKey: "function")
        
//REQUEST CHAIN FOR POPULATING THE NOFA WORKBOOK
        
        if scriptName == "sheetNames" {
    
            //print("RETRIEVING SHEET NAMES")
            let fileId = fileIds[selectedFileIndex]
            
            let requestParams = [["header", fileId]]
           // print("SELECTED FILE ID")
           // print(requestParams[0][1])
            
            request.setJSONValue(requestParams, forKey: "parameters")
        } //end if sheetNames
        
        if scriptName == "popSheet" {
            
            let fileId = fileIds[selectedFileIndex]
            let worksheetName = worksheetNames[selectedSheetIndex]
            
            var requestParams = [["header", fileId, worksheetName]]
            //Append the array of values to be filled to sheet
            for i in 0...(popValues.count - 1) {
                requestParams[0].append(popValues[i])
            }
            request.setJSONValue(requestParams, forKey: "parameters")
        }
        
        if scriptName == "getEquip" {
            let fileId = fileIds[selectedFileIndex]
            
            let requestParams = [["header", fileId]]
          //  print("SELECTED FILE ID")
          //  print(requestParams[0][1])
            
            request.setJSONValue(requestParams, forKey: "parameters")
        } //end if getEquip
        
  //REQUEST CHAIN FOR POPULATING THE CREW WORKBOOK
        
        if scriptName == "getCrewData" {
            
           // print("GETTING DATA FROM CREW WORKBOOK")
            let fileId = fileIds[selectedFileIndex]
            
            let requestParams = [["header", fileId]]
           // print("SELECTED FILE ID")
           // print(requestParams[0][1])
            
            request.setJSONValue(requestParams, forKey: "parameters")
        } else if scriptName == "sendNewCJEU" {
         //   print("SENDING CROP, JOB, EQUIPMENT AND USER DATA TO WORKBOOK")
            
            let requestParams = newCJEUParameters
         //   print("DATA SEND PARAMETERS")
         //   print(newCJEUParameters)
            
            request.setJSONValue(requestParams, forKey: "parameters")
            
        } else if scriptName == "sendNewRecords" {
            //print("SENDING NEW RECORDS TO WORKBOOK")
            
            let requestParams = newRecordParameters
            //print("DATA SEND PARAMETERS")
            //print(newRecordParameters)
            
            request.setJSONValue(requestParams, forKey: "parameters")
        }
        
        
     //   print("REQUEST OBJECT")
     //   print(request)
        
        // Make the API request.
        service.fetchObject(byInserting: request,
                                             for: url!,
                                             delegate: self,
                                             didFinish: #selector(ExportViewController2.displayResultWithTicket(_:finishedWithObject:error:)))
    }
    
    // Handles the data returned by the Apps Script function.
    func displayResultWithTicket(_ ticket: GTLServiceTicket,
                                 finishedWithObject object : GTLObject,
                                                    error : NSError?) {
        //if let error = error {
        if String(describing: error?.localizedDescription) != "nil" {
            // The API encountered a problem before the script
            // started executing.
            
           // print("API ERROR BEFORE SCRIPT EXECUTION")
            let showAlert = "The server returned an error: "+String(describing: error?.localizedDescription)+" Please try again later."
            let alert = UIAlertController(title: "Alert:", message: showAlert, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
           // print(showAlert)
            isBusy.isHidden = true
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
            //statusText.text = errMessage
           // print("APPS SCRIPT EXECUTION RETURNED AN ERROR")
           //print(errMessage)
            
            let alert = UIAlertController(title: "Alert:", message: "The script returned an error.  Please make sure you have selected the correct workbook in your Google Drive.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            statusText.text = "Ready"
            isBusy.isHidden = true
            requestProcessing = false
        } else {

            //FIRST, HANDLE REQUEST RESPONSES THAT DO NOT RETURN VALUES
            
            if currentRequestName == "sendNewCJEU" {
                //Crew workbook
                //Once crops, jobs, equipment and users are sent, begin sending new records
                currentRequestName = "sendNewRecords"
                callAppsScript(currentRequestName)
                //Don't return message until records are populated.
                
            } else if currentRequestName == "sendNewRecords"{
                //Crew workbook
                statusText.text = "Workbook "+fileNames[selectedFileIndex]+" populated successfully!"
                isBusy.isHidden = true
                requestProcessing = false
    
            } else if currentRequestName == "popSheet" {
                //NOFA workbook
                statusText.text = "Worksheet "+worksheetNames[selectedSheetIndex]+" populated successfully!"
                isBusy.isHidden = true
                requestProcessing = false
           
                //NOW RECEIVE RESPONSES THAT RETURN VALUES
                
            } else {
                //NOFA workbook
                let response = object.json["response"] as! [String: AnyObject]
                let responseSet = response["result"] as! [String: AnyObject]
                //print("EQUIP RESPONSE:")
                //print(response)
                //print("EQUIP RESPONSE SET:")
                //print(responseSet)
                
                //START WITH RESPONSES THAT DO NOT TRIGGER A SELECTION MENU
                
                if currentRequestName == "getEquip" {
                
                if responseSet.count > 0 {
                
                selectItems = []
                selectIds = []
                
                for (id, sheet) in responseSet {
                    //sheetString += "\t\(sheet)\n"
                    selectItems.append(sheet as! String)
                    selectIds.append(id )
                }
                }//end if responseSet >0
                
                equipNames = selectIds // here, the name is the unique identifier in the JSON pair
                equipTypes = selectItems // and the item value is now type (tractor/ equip)
                //Now I can select the worksheet!
                selectSheet.isHidden = false
                labelSheet.isHidden = false
                isBusy.isHidden = true
                requestProcessing = false
                statusText.text = "Ready"

                
            } else if currentRequestName == "getCrewData" {
                    
                    if responseSet.count > 0 {
                        
                        selectItems = []
                        selectIds = []
                        
                        //print("CREW RESPONSE SET")
                        //print(responseSet)
                        
                        for (id, item) in responseSet {
                            //sheetString += "\t\(sheet)\n"

                            
                            //!!!!!!!!
                            //selectItems.append("\(item)")
                            selectItems.append(item as! String)
                            // apparently as! doesn't work in this case...
                            
                            
                            selectIds.append(id)
                            //print("NEW SELECTITEM")
                            //print(item)
                        }
                        
                    }//end if responseSet >0
                    
                        checkCJEUR()
                        requestProcessing = false
                        //isBusy.isHidden = true
                        //statusText.text = "Ready"
                        
                } else {
                    
                //FINALLY, HANDLE RESPONSES THAT RETURN VALUES TO BE DISPLAYED IN A SELECTION MENU
                
                
                if responseSet.count == 0 {
                    
                    //Show alert if no items returned
                    let alert = UIAlertController(title: "Alert:", message: "No items returned.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    isBusy.isHidden = true
                    requestProcessing = false
                    statusText.text = "Ready"
                } else {
                    //Start by clearing selected items and ids
                    selectItems = []
                    selectIds = []
                    
                    //!!!!!!!!
                    //print("WORKBOOK RESPONSE SET")
                    //print(responseSet)
                    
                    for (id, sheet) in responseSet {
                        //sheetString += "\t\(sheet)\n"
                        selectItems.append(sheet as! String)
                        selectIds.append(id )
                    }

 
                        //Save to appropriate array
                        if currentRequestName == "getFilesUnderRoot" {
                            fileNames = selectItems
                            fileIds = selectIds
                            //Call getEquipment at this point
                            //getEquipment()
                            isBusy.isHidden = true
                            requestProcessing = false
                            statusText.text = "Ready"
                        } else if currentRequestName == "sheetNames" {
                            worksheetNames = selectItems
                            //worksheetIds = selectIds
                            isBusy.isHidden = true
                            requestProcessing = false
                            statusText.text = "Ready"
                        }
                        //Send user to make selection
                        //presentViewController(selectListView, animated: true, completion: nil)
                        self.performSegue(withIdentifier: "selectListSegue", sender: self)
                    //}//end else current request name not getEquip
                    
                }
            } // end else not popSheet
            }//end else returns responses
        } // end else not error
    }// end displayResult
    
    
    //Function to call getEquip programmatically
    func getEquipment(){
        equipNames = []
        equipTypes = []
        currentRequestName = "getEquip"
        callAppsScript(currentRequestName)
        isBusy.isHidden = false
        requestProcessing = true
        statusText.text = "Accessing Google Drive..."
    }
 
    
    

    //########################################################################################### Done with ASE
    
    //FUNCTIONS THAT POPULATE LISTS AND WORKBOOKS
    
    //CREW WORKBOOK
    
    //When sending data to crew workbook, check all crops, jobs, equip, users and records in workbook against database
    
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
                //rounding to nearest whole number to accomodate legacy records.  Receive as a string from ASE output, parse to a Double, round the Double, then append as a string
            
                //!!!!!!!!
                
                //print("WORKBOOK RECORD"+String(i))
                //print(String(selectItems[i]))
                
                //what the shit!  Why am I getting this Thread1: EXC_BREAKPOINT error on the isNAN check??  Supposedly occurs in response to a null value, but I've already checked for empty!  I must need another check, I guess...
                if !selectItems[i].isEmpty && selectItems[i] != "" && selectItems[i] != "NA"{
                
                let isNumber = Double(selectItems[i])!.isNaN
                if !isNumber {

                    let rounded = String( round( Double(selectItems[i])! ) )
                    wsRecordIds.append(rounded)
                
                } //end if  is not NAN
            }//end if is not empty / null
            } //Record IDs are numeric, but for now I am treating them as strings
            
        }
        //print("CROP NAMES")
        //print(wsCropNames)
        //print("JOB NAMES")
        //print(wsJobNames)
        //print("EQUIP NAMES")
        //print(wsEquipNames)
        //print("USER NAMES")
        //print(wsUserNames)
        //print("RECORD IDS")
        //print(wsRecordIds)
        
        //Generate lists of NEW crops, jobs, equip and records!
        populateWorkbook()
    }
    
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
            
            //print("TOTAL # OF RECORDS IN DB")
            //print(workList.count)
            
            
            //Now go through all work records and append values to the lists above
            for i in 0...(workList.count - 1){
                workCrops.append( workList[i].cropRelate.value(forKey: "crop_name") as! String )
                workJobs.append( workList[i].jobRelate.value(forKey: "job_name") as! String )
                workImplems.append( workList[i].equipRelate.value(forKey: "equip_name") as! String )
                workTractors.append( workList[i].tractorRelate.value(forKey: "tractor_name") as! String )
                
                //Rounding to the nearest whole number to accomodate legacy records
                workIDS.append( String(round(workList[i].timestamp)) )
                
            }//end workList for
            
            //print("DATABASE WORK IDS")
            //print(workIDS)
            
            //Now I can use the checkWSandDuplicates function to populate the newCropNames and newJobNames arrays
            newCropNames = checkWSandDuplicates(dbNames: workCrops, wsNames: wsCropNames)
            
            newJobNames = checkWSandDuplicates(dbNames: workJobs, wsNames: wsJobNames)
            
            newRecordIds = checkWSandDuplicates(dbNames: workIDS, wsNames: wsRecordIds)
            //For equipment, which combines both implements and tractors, I will have to be tricky.
            //??What info / format is wsEquipNames??
            //wsEquipNames includes both tractors and implements, prefixed w/ tractor: and implement:
            //However it should be fine to use the full list, as tractors and implements should not share the same name
            //Worst case, two copies of a single name will show up on the WS.  not a big problem
            
            //print("NEW RECORD IDS")
            //print(newRecordIds)
            
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
            
            //print("WORKSHEET USER NAMES")
            //print(wsUserNames)
            
            if wsUserNames.count > 0 {
                for j in 0...(wsUserNames.count - 1){
                    if wsUserNames[j].contains(userName) {
                        isNewUser = false
                    } //end if worklist
                } // end for
            }// end if wsUserNames
            
            if isNewUser {
                newUserNames.append(userName)
                //print ("NEW USER NAME TO APPEND")
                //print (userName)
                //print ("NEW USER NAMES APPENDED")
                //print (newUserNames)
                
            }
            
            //COMBINE ALL NEW VALUES INTO THE DICTIONARY newCJEUParameters
            
            //first we must clear the dictionary
            newCJEUParameters = [String:String]()
            
            //then we can add new values to it
            //print("NEW CROP NAMES COUNT")
            //print(newCropNames.count)
            if newCropNames.count > 0 {
                //Add crop names to the dictionary of parameters
                for i in 0...(newCropNames.count - 1) {
                    let labelValue = "crop"+String(i)
                    newCJEUParameters[labelValue] = newCropNames[i]
                    //print("NEW CROP PARAMETERS")
                    //print(newCJEUParameters)
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
                        //!!!!!!!
                        //values in newRecordIds have been rounded (as workIds); therefore we need to round the recordId here to facilitate comparison
                        if newRecordIds[j].contains(String(round(recordId))) {
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
    

    //This function checks each name in the database (dbNames) to see if it is already present on the worksheet (wsNaames)  It returns a list of new names WITHOUT DUPLICATES
    func checkWSandDuplicates (dbNames: [String], wsNames: [String]) -> [String]{
        
        //if a record contains equipment not already in the worksheet, add to a list of new equipment
        var newNames = [String]()
        
        //Cycle through all names in the local database
        for i in 0...(dbNames.count - 1) {

            var isNew = true
            
            //First I will check if the equip name is already on the worksheet
            if wsNames.count > 0 {
            for j in 0...(wsNames.count - 1){
                if wsNames[j].contains(dbNames[i]) {
                    isNew = false
                } //end if
            } // end for
            } //end if wsNames > 0
            
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

    
    
    
    //NOFA WORKBOOK !!!!!
    
    
    
    //Return all crops and work records
    func popLists() {
        
        let managedContext = appDelegate.managedObjectContext
        
        
        //first clear workList
        workList = []
        
        //Request objects of name Work_record
        let workRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Work_record")
        
        //Narrowing request to records since selected date IF date selected
        if dateSelected {
            //for so
            let predSelect = NSNumber(value: selectedDate as Double)
            workRequest.predicate = NSPredicate(format: "%K > %@", "timestamp", predSelect)
            //Previously timestamp > %@
        }
        
        //Return all Work_records as workList
        do {
            let results =
                try managedContext.fetch(workRequest)
            self.workList = results as! [Work_record]
            //workList = results as! [NSManagedObject]
        } catch let error as NSError {
          //  print("Could not fetch \(error), \(error.userInfo)")
        }
        
        /*
        cropList = []
        
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
        
        let allWorkRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Work_record")
        
        do {
            //Retrieve crops
            let records = try managedContext.fetch(allWorkRequest)
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
    
    
    //This function gathers data for the selected crop and writes to the NOFA workbook
    func populateCrop(){
        
        let managedContext = appDelegate.managedObjectContext

        var cropWorkList = [Work_record]()
        var populateSummary = [String]()
        
        
        var jobSummary = [String]()
        
        var jobPersonHours = [Double]()
        var jobEquipHours = [Double]()
        var jobImplements = [String]()
        var jobTractors = [String]()
        
        //let cropName = cropList[cropIndex].crop_name
        let cropSelect = cropList[selectedCropIndex]
        
        
        //Getting all records associated with the selected crop after the start date
        let workRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Work_record")
        let cropPredicate = NSPredicate(format: "cropRelate == %@", cropSelect)
        if dateSelected {
            //If date selected, search by crop and date with a compound predicate
            let predSelect = NSNumber(value: selectedDate as Double)
            let datePredicate = NSPredicate(format: "%K > %@", "timestamp", predSelect)
            //Create a compound predicate as workPred AND datePred
            //let workDatePredicate = NSCompoundPredicate(type: NSCompoundPredicate.Log.LogicalicalType.and, //subpredicates: [cropPredicate, datePredicate]) //This code works in an older version of Swift
            let workDatePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [cropPredicate, datePredicate])
            workRequest.predicate = workDatePredicate
            //workRequest.predicate = NSPredicate(format: "%K > %@ && cropRelate == %@", "timestamp", predSelect, cropSelect)
            //Previously timestamp > %@
        } else { //Otherwise search by crop only
            workRequest.predicate = cropPredicate
        }
        
        do {
            //Retrieve crops
            let records = try managedContext.fetch(workRequest)
            cropWorkList = records as! [Work_record]
        } catch let error as NSError {
        //    print("Could not fetch work records\(error), \(error.userInfo)")
        }
        
        //If there are work records associated with the selected crop, proceed
        if cropWorkList.count > 0 {
            
            //Construct a list of all unique jobs in those records
            for i in 0...(cropWorkList.count - 1){
                
                //First see if job already exists
                var newJob = true
                let jobName = cropWorkList[i].jobRelate.value(forKey: "job_name") as! String
                
                if jobSummary.count > 0 {
                    for j in 0...(jobSummary.count - 1){
                        if jobName == jobSummary[j]{
                            newJob = false
                        }
                    }
                }
                
                //Add unlisted job
                if newJob {
                    jobSummary.append(jobName)
                    
                }// end if newJob
                
            }//end for cropWorkList
            
            
            
            //for each job, we will gather implements and tractors associated with it, PROVIDED they are in the worksheet!
            var worksheetTractors = [String]()
            var worksheetImplements = [String]()
            if equipNames.count > 0 {
                for i in 0...(equipNames.count - 1){
                    if equipTypes[i] == "tractor"{
                        worksheetTractors.append(equipNames[i])
                    }
                    if equipTypes[i] == "implement"{
                        worksheetImplements.append(equipNames[i])
                    }
                }
            } //end if equipnames > 0
            
            
            for i in 0...(jobSummary.count - 1){
                
                //Beginning with jobImplements and jobTractors as arrays of negative strings
                jobImplements.append("No Implement")
                jobTractors.append("No Tractor")
                
                var personHours = Double()
                var equipHours = Double()
                
                //########################***
                
                
                for j in 0...(cropWorkList.count - 1){
                    //First insert a tractor or implement into their respective arrays when used w/ a given job
                    if cropWorkList[j].jobRelate.value(forKey: "job_name") as! String == jobSummary[i]{
                        
                        if cropWorkList[j].equipRelate.value(forKey: "equip_name") as! String != "No Implement" {
                            //###############*** Crashes here:
                            if worksheetImplements.count > 0 {
                            for k in 0...(worksheetImplements.count - 1){
                                if cropWorkList[j].equipRelate.value(forKey: "equip_name") as! String == worksheetImplements[k]{
                                    jobImplements[i] = cropWorkList[j].equipRelate.value(forKey: "equip_name") as! String
                                }
                            } //end for worksheetImplements
                            } //end if worksheetImplements > 0
                        }
                        if cropWorkList[j].tractorRelate.value(forKey: "tractor_name") as! String != "No Tractor" {
                            if worksheetTractors.count > 0 {
                            for k in 0...(worksheetTractors.count - 1){
                                if cropWorkList[j].tractorRelate.value(forKey: "tractor_name") as! String == worksheetTractors[k] {
                                    jobTractors[i] = cropWorkList[j].tractorRelate.value(forKey: "tractor_name") as! String
                                }
                            } //end worksheetTractors
                            } //end worksheetTractors > 0
                        }
                        
                        //Then add person hours to the tally
                        personHours = personHours + (cropWorkList[j].ms_worked  * Double(cropWorkList[j].workers))
                        
                        
                        //Finally add equip hours IF either the above listed implement or tractor is used
                        var usedImplement = false
                        var usedTractor = false
                        if cropWorkList[j].equipRelate.value(forKey: "equip_name") as! String != "No Implement" && cropWorkList[j].equipRelate.value(forKey: "equip_name") as! String == jobImplements[i] {
                            usedImplement = true
                        }
                        if cropWorkList[j].tractorRelate.value(forKey: "tractor_name") as! String != "No Tractor" && cropWorkList[j].tractorRelate.value(forKey: "tractor_name") as! String == jobTractors[i] {
                            usedTractor = true
                        }
                        if usedImplement || usedTractor {
                            equipHours = equipHours + cropWorkList[j].ms_worked
                        }
                        
                    }
                }//end for cropWorkList
                
                //Write person hours and equip hours to arrays
                if personHours > 0 {
                    jobPersonHours.append(personHours)
                } else {jobPersonHours.append(0)
                }
                if equipHours > 0 {
                    jobEquipHours.append(equipHours)
                } else {jobEquipHours.append(0)
                }
                
            }//end for jobSummary
        
        
        //Now that we have summary data for each job, we can position them on master lists corresponding with each job on the workbook
        //Use a didMatch array, for ease of constructing other categories
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
        //These arrays will have length = master list
        var personHoursMaster = [Double]()
        var equipHoursMaster = [Double]()
        var implementsMaster = [String]()
        var tractorsMaster = [String]()
        
        //This array will have length = jobSummary
        var didMatchMaster = [Bool]()
        for i in 0...(jobSummary.count - 1){
            didMatchMaster.append(false)
        }
        
      //  print("MASTER JOB LIST LENGTH")
      //  print(jobListMaster.count)
        
        //Now I will iterate through the master list and append appropriate data
        for i in 0...(jobListMaster.count - 1) {
            //Start each entry as null
            personHoursMaster.append(0)
            equipHoursMaster.append(0)
            implementsMaster.append("")
            tractorsMaster.append("")
            
            //Cycle through jobSummary and insert values where relevant
            for j in 0...(jobSummary.count - 1){
                if jobListMaster[i] == jobSummary[j] {
                    didMatchMaster[j] = true
                    personHoursMaster[i] = jobPersonHours[j]
                    equipHoursMaster[i] = jobEquipHours[j]
                    implementsMaster[i] = jobImplements[j]
                    tractorsMaster[i] = jobTractors[j]
                }
            } //end for jobSummary
        } //end for jobListMaster
        
        //Sum hours worked in other jobs
        var soilPrepOther = Double()
        var cultivationOther = Double()
        var postHarvestOther = Double()
        
        
        for i in 0...(jobSummary.count - 1){
            if !didMatchMaster[i] {
                //Match to string Soil prep
                if jobSummary[i].contains("Soil prep:") {
                    soilPrepOther = soilPrepOther + jobPersonHours[i]
                }
                if jobSummary[i].contains("Cultivation:") {
                    cultivationOther = cultivationOther + jobPersonHours[i]
                }
                if jobSummary[i].contains("Post harvest:") {
                    postHarvestOther = postHarvestOther + jobPersonHours[i]
                }
            }//end did match master
        }//end jobSummary for
        if soilPrepOther > 0{
            personHoursMaster[6] = soilPrepOther
        }
        if cultivationOther > 0 {
            personHoursMaster[19] = cultivationOther
        }
        if postHarvestOther > 0 {
            personHoursMaster[26] = postHarvestOther
        }
        
        //Finally I will scrub 'no equipment' and 'no tractor entries from the arrays
        for i in 0...(jobListMaster.count - 1){
            if implementsMaster[i] == "No Implement"{
                implementsMaster[i] = ""
            }
            if tractorsMaster[i] == "No Tractor"{
                tractorsMaster[i] = ""
            }
        }

        var personHoursMasterString = [String]()
        var equipHoursMasterString = [String]()
        
        for i in 0...(jobListMaster.count - 1){
            personHoursMasterString.append(String(personHoursMaster[i]))
            equipHoursMasterString.append(String(equipHoursMaster[i]))
        }
        
        
        
        popValues = personHoursMasterString+tractorsMaster+implementsMaster+equipHoursMasterString
            if !requestProcessing {
            //Call the ASE request!
            currentRequestName = "popSheet"
            callAppsScript(currentRequestName)
            isBusy.isHidden = false
            requestProcessing = true
            statusText.text = "Accessing Google Drive..."
            } else {
                let alert = UIAlertController(title: "Alert:", message: "Please wait for a response from Google Drive", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        //end if cropworkList > 0
        } else {
        
        let alert = UIAlertController(title: "Alert:", message: "There are no records saved for this crop.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        }
    }//end populate crop
    
    
    
    
    
    func summarizeCrop(_ cropSelect: Crop){
        
        let managedContext = appDelegate.managedObjectContext
        
        //populate crop and job lists
        self.popLists()
        
        //reset totalHours
        totalHours = 0
        
        //String names of jobs, equipment, tractors in selectWork
        var jobSummary = [String]()
        var equipSummary = [String]()
        var tractorSummary = [String]()
        var workListCrop = [Work_record]()
        
        
        let workRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Work_record")
        let cropPredicate = NSPredicate(format: "cropRelate == %@", cropSelect)
        if dateSelected {
            //If date selected, search by crop and date with a compound predicate
            let predSelect = NSNumber(value: selectedDate as Double)
            let datePredicate = NSPredicate(format: "%K > %@", "timestamp", predSelect)
            //Create a compound predicate as workPred AND datePred
            //let workDatePredicate = NSCompoundPredicate(type: NSCompoundPredicate.Log.LogicalicalType.and, subpredicates: [cropPredicate, datePredicate])
            let workDatePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [cropPredicate, datePredicate])
            workRequest.predicate = workDatePredicate
            //workRequest.predicate = NSPredicate(format: "%K > %@ && cropRelate == %@", "timestamp", predSelect, cropSelect)
            //Previously timestamp > %@
        } else { //Otherwise search by crop only
            workRequest.predicate = cropPredicate
        }
        
        do {
            //Retrieve crops
            let records = try managedContext.fetch(workRequest)
            workListCrop = records as! [Work_record]
        } catch let error as NSError {
          //  print("Could not fetch work records\(error), \(error.userInfo)")
        }
        
        
        if workListCrop.count > 0 {
            //The first go-around will construct lists of all unique jobs, equipment and tractors
            for i in 0...(workListCrop.count - 1){
                
                //First see if job, equip and tractor for this entry already exist in lists.  If not, add them
                var newJob = true
                var newEquip = true
                var newTractor = true
                
                let jobName = workListCrop[i].jobRelate.value(forKey: "job_name") as! String
                let equipName = workListCrop[i].equipRelate.value(forKey: "equip_name") as! String
                let tractorName = workListCrop[i].tractorRelate.value(forKey: "tractor_name") as! String
                
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
                }
                if newEquip {
                    equipSummary.append(equipName)
                }
                if newTractor {
                    tractorSummary.append(tractorName)
                }
                
                //Finally, compile total hours worked on that crop
                totalHours = totalHours + (workListCrop[i].ms_worked * Double(workListCrop[i].workers))
                
            }//end for workListCrop
        }//end workListCrop > 0
        
        
        //Only add the crop to the list if it has some hours associated with it
        if totalHours > 0 {
            
            
            
            // Summarizes total crop hours worked
            outCrops.append(cropSelect.value(forKey: "crop_name") as! String)
            outHeaders.append("Total hours:")
            outSummary.append(String(format:"%.2f", totalHours))
            outCrops.append("")
            outHeaders.append("")
            outSummary.append("")
            
            //The second go-around will tally hours worked within each category and append them to the output array.  Row headers will be appended to the header array.
            //jobs
            if workListCrop.count > 0 && jobSummary.count > 0 {
                for i in 0...(jobSummary.count - 1){
                    var hours = Double(0)
                    for j in 0...(workListCrop.count - 1){
                        if workListCrop[j].jobRelate.value(forKey: "job_name") as! String == jobSummary[i] {
                            hours = hours + (workListCrop[j].ms_worked * Double(workListCrop[j].workers))
                        }
                    }
                    
                    jobHours.append(hours)
                    outCrops.append(cropSelect.value(forKey: "crop_name") as! String)
                    outHeaders.append("\(jobSummary[i]) hours: ")
                    outSummary.append(String(format:"%.2f", hours))
                    
                }//end jobSummary for
                //Add a blank row after each block of outputs
                outCrops.append("")
                outHeaders.append("")
                outSummary.append("")
            }//end >0 if
            
            //equipment
            if workListCrop.count > 0 && equipSummary.count > 0 {
                var hadEquip = false
                for i in 0...(equipSummary.count - 1){
                    var hours = Double(0)
                    for j in 0...(workListCrop.count - 1){
                        if workListCrop[j].equipRelate.value(forKey: "equip_name") as! String == equipSummary[i] {
                            hours = hours + workListCrop[j].ms_worked
                        }
                    }
                    if equipSummary[i] != "No Implement" {
                        hadEquip = true
                        equipHours.append(hours)
                        outCrops.append(cropSelect.value(forKey: "crop_name") as! String)
                        outHeaders.append("\(equipSummary[i]) hours: ")
                        outSummary.append(String(format:"%.2f", hours))
                    }// end if implement
                    
                }//end equipSummary for
                //Add a blank row after each block of outputs
                if hadEquip {
                    outCrops.append("")
                    outHeaders.append("")
                    outSummary.append("")
                }
            }//end >0 if
            
            //tractors
            if workListCrop.count > 0 && tractorSummary.count > 0 {
                var hadTractor = false
                for i in 0...(tractorSummary.count - 1){
                    var hours = Double(0)
                    for j in 0...(workListCrop.count - 1){
                        if workListCrop[j].tractorRelate.value(forKey: "tractor_name") as! String == tractorSummary[i] {
                            hours = hours + workListCrop[j].ms_worked
                        }
                    }
                    
                    if tractorSummary[i] != "No Tractor" {
                        hadTractor = true
                        tractorHours.append(hours)
                        outCrops.append(cropSelect.value(forKey: "crop_name") as! String)
                        outHeaders.append("\(tractorSummary[i]) hours: ")
                        outSummary.append(String(format:"%.2f", hours))
                    } //end if tractor
                    
                }//end tractorSummary for
                //Add a blank row after each block of outputs
                if hadTractor {
                    outCrops.append("")
                    outHeaders.append("")
                    outSummary.append("")
                }
                
            }//end workListCount >0 if
        }//end if totalHours > 0
    }//end summarize crop
    
    
    
    //Thanks Terminus!!
    //Right now this is only writing normal attributes and NOT relations such as crop, job, etc.  I will need to re-write it to cycle through each DB item and extract names from relations.  Should be easy!!
    
    func writeCoreDataObjectsToCsv(_ objects: [Work_record]) -> String {
        //func writeCoreDataObjectToCVS(objects: [NSManagedObject], named: String) -> String {
        
        guard objects.count > 0 else {
            return ""
        }
        
        let objectSort = objects.sorted(by: { $0.timestamp > $1.timestamp})
        
        
        //Formatting timestamp as string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yy"
        
        let headArray = ["Crop","Job","Implement","Tractor","Workers","Hours worked","Date"]
        let headString = headArray.reduce("", {$0 + "," + $1})
        //This sticks in a leading comma too, which I must remove
        //headString.removeAtIndex(headString.startIndex)
        var csvArray = [headString]
        
        for i in 0...(objectSort.count - 1){
            var newLine = [String]()
            //access all values as strings
            newLine.append(objectSort[i].cropRelate.value(forKey: "crop_name") as! String)
            newLine.append(objectSort[i].jobRelate.value(forKey: "job_name") as! String)
            newLine.append(objectSort[i].equipRelate.value(forKey: "equip_name") as! String)
            newLine.append(objectSort[i].tractorRelate.value(forKey: "tractor_name") as! String)
            newLine.append(objectSort[i].workers.stringValue)
            newLine.append(String(format:"%.2f", objectSort[i].ms_worked))
            let dateFormat = dateFormatter.string(from: Date(timeIntervalSince1970:(objectSort[i].timestamp/1000)))
            newLine.append(dateFormat)
            //concatinte entries into a string
            var newString = newLine.reduce("", {$0 + "," + $1})
            //This sticks in a leading comma too, which I must remove
            newString.remove(at: newString.startIndex)
            //add to the csv builder
            csvArray.append(newString)
        }//end for objects
        
        //concatinate csvArray into string
        var csvString = csvArray.reduce("", {$0 + "\n" + $1} )
        //as before, I need to remove the lead formatting characters
        csvString.remove(at: csvString.startIndex)
        csvString.remove(at: csvString.startIndex)
        
        return csvString

    } // end WriteCoreDataObjectstoCSV
    
    
    
    func writeSummaryToCsv() -> String {
        
        
        
        guard cropList.count > 0 else {
            return ""
        }
        
        //Clear all arrays used in summary
        outCrops = []
        outHeaders = []
        outSummary = []
        
        
        //Populate lists with summaries of ALL crops!
        for i in 0...(cropList.count - 1) {
            
            summarizeCrop(cropList[i])
        }
        
        let headArray = ["Crop","Category","Hours worked"]
        let headString = headArray.reduce("", {$0 + "," + $1})
        //This sticks in a leading comma too, which I must remove
        //headString.removeAtIndex(headString.startIndex)
        var csvArray = [headString]
        
        for i in 0...(outCrops.count - 1){
            var newLine = [String]()
            //access all values as strings
            newLine.append(outCrops[i])
            newLine.append(outHeaders[i])
            newLine.append(outSummary[i])
            //newLine.append(String(format:"%.2f", outSummary[i]))
            
            //concatinte entries into a string
            var newString = newLine.reduce("", {$0 + "," + $1})
            //This sticks in a leading comma too, which I must remove
            newString.remove(at: newString.startIndex)
            //add to the csv builder
            csvArray.append(newString)
        }//end for objects
        
        //concatinate csvArray into string
        var csvString = csvArray.reduce("", {$0 + "\n" + $1} )
        //as before, I need to remove the lead formatting characters
        csvString.remove(at: csvString.startIndex)
        csvString.remove(at: csvString.startIndex)
        
        return csvString
    } // end writesummaryto CSV

    
    
    // thanks Alex!!
    @IBAction func clickSendEmail(_ sender: AnyObject) {
        
        
        popLists()
        
        if workList.count > 0 {
        //Thanks nschum
        let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        //let managedContext = appDelegate.managedObjectContext
        
        let fileNameAll = "All_records.csv"
        let fileNameSummary = "Summary_of_records.csv"
        
        let contentsOfAll = writeCoreDataObjectsToCsv(workList)
        let contentsOfSummary = writeSummaryToCsv()
            
        //Now I will try to go ahead and send an email w/ attachment!'
        //Thanks Terminus and Lucas
        
        let dataAll = contentsOfAll.data(using: String.Encoding.utf8)
        let dataSummary = contentsOfSummary.data(using: String.Encoding.utf8)
        
        let composer = MFMailComposeViewController()
        
        composer.mailComposeDelegate = self
        
        composer.setSubject("BeetClock Report from iOS")
        composer.setMessageBody("CSV files attached", isHTML: false)
        composer.addAttachmentData(dataAll!, mimeType: "text/csv", fileName: "All_records.csv")
        composer.addAttachmentData(dataSummary!, mimeType: "text/csv", fileName: "Summary_of_records.csv")
        
        if MFMailComposeViewController.canSendMail() {
            self.present(composer, animated: true, completion: nil)
        }
        
        //end if records exist
        } else {
            let alert = UIAlertController(title: "Alert:", message: "You must have saved records to send a report.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    } // click send email
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        var resultText = ""
        switch result
        {
        case MFMailComposeResult.sent:
            resultText = "Mail sent successfully"
        case MFMailComposeResult.saved:
            resultText = "Email draft saved successfully"
        case MFMailComposeResult.cancelled:
            resultText = "Mail cancelled"
        case MFMailComposeResult.failed:
            resultText = "An error occurred when sending this email"
        default:
            resultText = "An error occurred when sending this email"
            break;
        }
        
        statusText.text = resultText
        
        // Dismiss the mail compose view controller.  Originally controller.dismiss...
        controller.dismiss(animated: true, completion: nil)
    }

    
    
}//end ExportViewController2


    


