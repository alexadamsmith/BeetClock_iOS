//
//  SelectListViewController.swift
//  BeetClock_A1
//
//  Created by Alex Smith on 12/1/16.
//  Copyright © 2016 BeetWorks. All rights reserved.
//

import UIKit

class SelectListViewController: UITableViewController {
    
    var chosenName = "Not this one!"
    var chosenIndex = Int()
    var selectList = [String]()
    
    var colorBank = ColorBank()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set the background color
        self.tableView.backgroundColor = colorBank.GetUIColor("background")
        
        
        // Change the navigation bar background color
        navigationController!.navigationBar.barTintColor = colorBank.GetUIColor("navbar")
        
        // Change the color of the navigation bar button items to white.
        navigationController!.navigationBar.tintColor = UIColor.white
        
        print("SELECT LIST VIEW")
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    

    
    //Receive segue from ExportViewController
    
    @IBAction func
        selectListSegue(_ segue:UIStoryboardSegue){
        
        let incoming = segue.source as! ExportViewController2
        selectList = incoming.selectItems
        
        print("RECEIVED SELECTLISTSEGUE")
    }
    
    
    //Receive segue from NewSelectViewController
    @IBAction func
        selectListEquipSegue(_ segue:UIStoryboardSegue){
        
        let incoming = segue.source as! NewSelectViewController
        selectList = incoming.selectItems
        
        print("RECEIVED SELECTLISTEQUIPSEGUE")
    }
    

    //Receive segue from SynchViewController
    ////Not receiving this segue!!
    @IBAction func
        selectListCrewSegue(_ segue:UIStoryboardSegue){
        
        let incoming = segue.source as! SynchViewController
        selectList = incoming.selectItems
        
        print("RECEIVED SELECTLISTCREWSEGUE")
        print(selectList)
        
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
        let nRows = selectList.count
        return nRows
    }
    
    //Populate table contents from selectList
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DisplayItem", for: indexPath)
        
        cell.textLabel?.text = selectList[indexPath.row]
        
        return cell
    }


    
    
    
    /*
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //let indexPath = tableView.indexPathForSelectedRow() //optional, to get from any UIButton for example
        //let currentCell = tableView.cellForRowAtIndexPath(indexPath)! as UITableViewCell
        //print(currentCell.textLabel!.text)
        
        chosenName = selectList[indexPath.row]
        chosenIndex = indexPath.row
    }
 */
    
    //Unwind and pass new item to ExportViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "makeSelectionSegue" {
            
            let tvc = segue.source as! SelectListViewController
            let selectedRow = tvc.tableView.indexPathForSelectedRow?.row
            chosenIndex = selectedRow!
            chosenName = selectList[selectedRow!]

        }//end if unwind w/ new item

    } //end prepareForSegue
    

        
        
        

    

    


}
