//
//  ViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 9/19/14.
//  Copyright (c) 2014 Timothy Lee. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, FiltersViewControllerDelegate {
    var client: YelpClient!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var filterInfo = [String:[Bool]]()
    
    // You can register for Yelp API keys here: http://www.yelp.com/developers/manage_api_keys
    let yelpConsumerKey = "vxKwwcR_NMQ7WaEiQBK_CA"
    let yelpConsumerSecret = "33QCvh5bIF5jIHR5klQr7RtBDhQ"
    let yelpToken = "uRcRswHFYa1VkDrGV6LAW2F8clGh5JHV"
    let yelpTokenSecret = "mqtKIxMIR4iBtBPZCmCLEb-Dz3Y"
    
    var vendors: NSArray = []
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160.0
        
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
        searchBar.delegate = self
        
        filterInfo["Popular"] = [false]
        filterInfo["Sort"] = [false, false]
        filterInfo["Distance"] = [false,false,false,false]
        filterInfo["Categories"] = [false,false,false,false]
        
        client = YelpClient(consumerKey: yelpConsumerKey, consumerSecret: yelpConsumerSecret, accessToken: yelpToken, accessSecret: yelpTokenSecret)
        
        // Do any additional setup after loading the view, typically from a nib.
        
        self.fetchVendors()
    }
    
    func fetchVendors() {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        var params = getSearchParams()
        
        client.searchWithTerm(params, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            self.vendors = response["businesses"] as! NSArray
            //println(self.vendors)
            self.tableView.reloadData()
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                println(error)
        }
    }
    
    func getSearchParams() -> NSMutableDictionary{
        var params = NSMutableDictionary()
        
        var popArr = filterInfo["Popular"]!
        if popArr[0] {
            params.setValue(true, forKey: "deal_filter")
        }

        var sortArr = filterInfo["Sort"]!
        for i in 0...sortArr.count-1 {
            if sortArr[i] {
                if i == 0 {
                    params.setValue(0, forKey: "sort")
                } else if i == 1 {
                    params.setValue(2, forKey: "sort")
                }
                break
            }
        }
        
        var distArr = filterInfo["Distance"]!
        for i in 0...distArr.count-1 {
            if distArr[i] {
                if i == 0 {
                    params.setValue(480, forKey:"radius_filter")
                } else if i == 1 {
                    params.setValue(1600, forKey:"radius_filter")
                } else if i == 2 {
                    params.setValue(8000, forKey:"radius_filter")
                } else if i == 3 {
                    params.setValue(32000, forKey:"radius_filter")
                }
            }
            break
        }

        
        var categoryArr = filterInfo["Categories"]!
        for i in 0...categoryArr.count-1 {
            if categoryArr[i] {
                if i == 0 {
                    params.setValue("bars", forKey:"category_filter")
                } else if i == 1 {
                    params.setValue("experiences", forKey:"category_filter")
                } else if i == 2 {
                    params.setValue("restaurants", forKey:"category_filter")
                } else if i == 3 {
                    params.setValue("hotelstravel", forKey:"category_filter")
                }
                break
            }
        }
        
        if searchBar.text == "" {
            params.setValue("", forKey:"term")
        } else {
            params.setValue(searchBar.text, forKey:"term")
        }
        
        return params
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        var query = searchBar.text
        fetchVendors()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.vendors.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("VendorCell", forIndexPath: indexPath) as! VendorCell
        
        var vendorDict = self.vendors[indexPath.row] as! NSDictionary
        println(vendorDict)
        
        var vendorName = vendorDict["name"] as! String
        var vendorNum = indexPath.row as Int
        var vendorRevs = vendorDict["review_count"] as! Int
        var starURL = vendorDict["rating_img_url_small"] as! String
        var vendorURL = vendorDict["image_url"] as! String
        
        var location = vendorDict["location"] as! NSDictionary
        var addresses = location["address"] as! NSArray
        var address = addresses.firstObject as! String
        var city = location["city"] as! String
        
        var types = vendorDict["categories"] as! NSArray
        var allTypes = ""
        for t in types {
            var typeList = t as! NSArray
            var type = typeList.firstObject as! String
            allTypes.extend(type)
            allTypes.extend(",")
        }
        allTypes = dropLast(allTypes)
        
        var dist = vendorDict["distance"] as! Double
        dist = dist/1600 as Double
        var distStr = String(format: "%.2f", dist)
        
        println(distStr)
        cell.distLabel!.text = "\(distStr) mi"
        
        let url = NSURL(string: starURL)
        let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
        cell.revView.image = UIImage(data: data!)
        
        let snipURL = NSURL(string: vendorURL)
        let snipData = NSData(contentsOfURL: snipURL!) //make sure your image in this url does exist, otherwise unwrap in a if let check
        cell.thumbView.image = UIImage(data: snipData!)
            
        cell.nameLabel!.text = vendorName
        //dist
        cell.numReviewsLabel!.text = "\(vendorRevs) Reviews"
        //dollars
        cell.addressLabel!.text = "\(address), \(city)"
        cell.typesLabel!.text = "\(allTypes)"
        
        
        return cell
    }
    
    func filtersViewController(filtersViewController: FilterViewController, didUpdateFilters filters: [String:[Bool]]) {
        println("Received filters: \(filters)")
        self.filterInfo = filters
        fetchVendors()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PresentFilters" {
            println("Segue to Filters")
            let filtersNC = segue.destinationViewController as! UINavigationController
            let filtersVC = filtersNC.viewControllers[0] as! FilterViewController
            filtersVC.delegate = self
        }
    }
}

