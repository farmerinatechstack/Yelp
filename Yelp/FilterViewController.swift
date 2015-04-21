//
//  FilterViewController.swift
//  Yelp
//
//  Created by Hassan Karaouni on 4/20/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

protocol FiltersViewControllerDelegate {
    func filtersViewController(filtersViewController: FilterViewController, didUpdateFilters filters: [String:[Bool]])
}

class FilterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var delegate: FiltersViewControllerDelegate?
    var rowsPerSection = [1,1,1,1]
    var dropdownToggles = [false, false, false]
    
    var filterInfo = [String:[Bool]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        filterInfo["Popular"] = [false]
        filterInfo["Sort"] = [false, false]
        filterInfo["Distance"] = [false,false,false,false]
        filterInfo["Categories"] = [false,false,false,false]
    }
    
    @IBAction func searchButtonPressed(sender: UIBarButtonItem) {
        delegate?.filtersViewController(self, didUpdateFilters: filterInfo)
        dismissViewControllerAnimated(true, completion: nil)
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! CustomHeaderCell
    
        switch (section) {
            case 0:
                headerCell.headerLabel.text = "Popular";
            case 1:
                headerCell.headerLabel.text = "Sort By";
            case 2:
                headerCell.headerLabel.text = "Distance";
            default:
                headerCell.headerLabel.text = "Categories";
            }
        
        return headerCell
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        switch (indexPath.section) {
            case 0:
                cell = setDealCell(indexPath)
            case 1:
                cell = setSortCells(indexPath)
            case 2:
                cell = setDistanceCells(indexPath)
            case 3:
                cell = setCategoryCells(indexPath)
            default:
                cell.textLabel?.text = "Thank you for using Yelp!"
        }
        
        return cell
    }
    
    func setDealCell(indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        
        cell.textLabel?.text = "Offering A Deal"
        
        let switchView = UISwitch(frame: CGRectZero)
        switchView.on = false
        switchView.onTintColor = UIColor(red: 73.0/255.0, green: 134.0/255.0, blue:     231.0/255.0, alpha: 1.0)
        cell.accessoryView = switchView
        
        return cell
    }
    
    func setSortCells(indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        
        var toggled = dropdownToggles[indexPath.section-1]
        if toggled && indexPath.row != 0 {
            cell.accessoryView = nil
            if (indexPath.row == 1) {
                cell.textLabel?.text = "Best Match"
            } else {
                cell.textLabel?.text = "Highest Rated"
            }
        } else {
            cell.textLabel?.text = "Sorting Options"
            cell.accessoryView = UIImageView(image: UIImage(named: "Dropdown"))
        }
        
        return cell
    }
    
    func setDistanceCells(indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        
        var toggled = dropdownToggles[indexPath.section-1]
        if toggled && indexPath.row != 0 {
            cell.accessoryView = nil
            if (indexPath.row == 1) {
                cell.textLabel?.text = "0.3 Miles"
            } else if (indexPath.row == 2) {
                cell.textLabel?.text = "1 Mile"
            } else if (indexPath.row == 3) {
                cell.textLabel?.text = "5 Miles"
            } else {
                cell.textLabel?.text = "20 Miles"
            }
        } else {
            cell.textLabel?.text = "Select Distances"
            cell.accessoryView = UIImageView(image: UIImage(named: "Dropdown"))
        }
        
        return cell
    }
    
    func setCategoryCells(indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        
        var toggled = dropdownToggles[indexPath.section-1]
        if toggled && indexPath.row != 0 {
            cell.accessoryView = nil
            if (indexPath.row == 1) {
                cell.textLabel?.text = "Bars"
            } else if (indexPath.row == 2) {
                cell.textLabel?.text = "Experiences"
            } else if (indexPath.row == 3) {
                cell.textLabel?.text = "Restaurants"
            } else {
                cell.textLabel?.text = "Hotels & Travel"
            }
        } else {
            cell.textLabel?.text = "Select Categories"
            cell.accessoryView = UIImageView(image: UIImage(named: "Dropdown"))
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if  (indexPath.section != 0) {
            var toggled = dropdownToggles[indexPath.section-1]

            if (indexPath.row != 0) { // Filter Selected
                updateFilter(indexPath)
            } else { // Toggler Selected
                dropdownToggles[indexPath.section - 1] = !toggled
                if (toggled) { // Collapse Dropdown
                    rowsPerSection[indexPath.section] = 1
                } else { // Expand Dropdown
                    if (indexPath.section == 1) { // Toggle Sorts
                        rowsPerSection[indexPath.section] = 3
                    } else { // Toggle Distance/Categories
                        rowsPerSection[indexPath.section] = 5
                    }
                }
                tableView.reloadData()
            }
        }
        if (indexPath.row == 0) {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    func updateFilter(indexPath: NSIndexPath) {
        var key = ""
        if indexPath.section == 1 {
            key = "Sort"
        } else if indexPath.section == 2 {
            key = "Distance"
        } else if indexPath.section == 3 {
            key = "Categories"
        } else {
            println("Invalid indexPath selected - taking no action")
        }
        
        var arr = filterInfo[key]!
        for i in 0...arr.count-1 {
            arr[i] = false
        }
        arr[indexPath.row-1] = true
    
        filterInfo.updateValue(arr, forKey: key)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowsPerSection[section]
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
