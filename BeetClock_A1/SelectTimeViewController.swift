//
//  SelectTimeViewController.swift
//  BeetClock_A1
//
//  Created by Alex Smith on 4/27/17.
//  Copyright © 2017 BeetWorks. All rights reserved.
//

import UIKit

class SelectTimeViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var timePicker: UIPickerView!
    
   // var timePicker = UIPickerView!.self
    
    var hourSelections = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]
    var minuteSelections = [0,5,10,15,20,25,30,35,40,45,50,55]
    
    var pickedHr = Double()
    
    var pickedMin = Double()
    
    var pickedTime = Double()
    
    var colorBank = ColorBank()
    
    //func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int{
    func numberOfComponents(in: UIPickerView) -> Int{
        return 2
    }
    
    //func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component:Int) -> Int {
        var select = 0
        if component == 0 {
        select = hourSelections.count
        }
        if component == 1 {
        select = minuteSelections.count
        }
        return select
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var select = ""
        
        if component == 0 {
            select = String(hourSelections[row] )      }
        if component == 1 {
            select = String(minuteSelections[row] )       }
        
        return select
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        if component == 0 {
            //converting hour and min to double so I can build decimal hours from them
             pickedHr = Double(hourSelections[row])
        }
        if component == 1 {
            pickedMin = Double(minuteSelections[row])
               }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set the background color
        self.tableView.backgroundColor = colorBank.GetUIColor("background")
        timePicker.backgroundColor = colorBank.GetUIColor("background")
        
        
        // Change the navigation bar background color
        navigationController!.navigationBar.barTintColor = colorBank.GetUIColor("navbar")
        
        // Change the color of the navigation bar button items to white.
        navigationController!.navigationBar.tintColor = UIColor.white
        
        //!!!!!!!

        //timePicker = UIPickerView()
        
        timePicker.dataSource = self
        timePicker.delegate = self
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //This blocks the unwind segue if the selections are incomplete.  Thanks Shaun and App Dev Guy!!
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any!) -> Bool {
        if identifier == "unwindWithNewRecord" {
            // perform your computation to determine whether segue should occur
            
            var segueShouldOccur = false
            
            if pickedHr > 0 || pickedMin > 0 {
                pickedTime = Double(pickedHr + (pickedMin/60))
                segueShouldOccur = true
            }
            
            //Present popup warning if not all conditions for segue are met
            if !segueShouldOccur {
                let alert = UIAlertController(title: "Alert:", message: "Please enter the time worked", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                // prevent segue from occurring
                return false
            }
        }//end if unwindWithNew
        return true
    }//end shouldPerformSegue
    
    
   }//end class SelectTimeViewController
