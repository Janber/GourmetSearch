//
//  SearchTopTableViewController.swift
//  GourmetSearch
//
//  Created by JW on 12/5/27 H.
//  Copyright © 27 Heisei woo. All rights reserved.
//

import UIKit
import CoreLocation

class SearchTopTableViewController: UITableViewController, UITextFieldDelegate, UIGestureRecognizerDelegate,
CLLocationManagerDelegate{
    
    var freeword:UITextField? = nil
    
    
    let ls = LocationService()
    let nc = NSNotificationCenter.defaultCenter()
    var observers = [NSObjectProtocol]()
    var here:(lat:Double, lon:Double)? = nil
    
    
    @IBAction func onTap(sender: UITapGestureRecognizer) {
        freeword?.resignFirstResponder()
    }
    
    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if let ifr = freeword?.isFirstResponder() {
            return ifr
        }
        return false
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // MARK: ↓これが足りなかった
    
        // MARK: ↑これが足りなかった
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        // AuthDenied
        observers.append(
        nc.addObserverForName(ls.LSAuthDeniedNotification,
            object: nil,
            queue: nil,
            usingBlock: {
                notification in
                
                self.presentViewController(self.ls.locationServiceDisabledAlert,
                    animated:true,
                    completion:nil)
            })
        
        )
        
        // AuthRestricted
        observers.append(
        nc.addObserverForName(ls.LSAuthRestrictedNotification,
            object: nil,
            queue: nil,
            usingBlock: {
                notification in
                
                self.presentViewController(self.ls.locationServiceRestrictedAlert,
                    animated: true,
                    completion: nil)
        })
        
        )
        
        // DidFailLocation
        observers.append(
        nc.addObserverForName(ls.LSDidFailLocationNotification,
            object: nil,
            queue: nil,
            usingBlock: {
                notification in
                
                self.presentViewController(self.ls.locationServiceDidFailAlert,
                    animated: true,
                    completion: nil)
        })
            
        )
        
        // sucess
        observers.append(
        nc.addObserverForName(ls.LSDidUpdateLocationNotification,
            object: nil,
            queue: nil,
            usingBlock: {
                notification in
                
                if let userInfo = notification.userInfo as? [String: CLLocation] {
                    if let clloc = userInfo["location"] {
                        self.here = (lat: clloc.coordinate.latitude,
                            lon: clloc.coordinate.longitude)
                        self.performSegueWithIdentifier("PushShopListFromHere", sender: self)
                    }
                }
        })
        
        )
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        for observer in observers {
            nc.removeObserver(observer)
        }
        observers = []
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
    // MARK: - UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 && indexPath.row == 1 {
            ls.startUpdatingLocation()
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    
    
    
    
    
    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            return 2
        default:
            return 0}
        }
        

    // MARK: - UITableViewDelegate
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    // MARK: - UITableViewDataSource
   override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("Freeword", forIndexPath: indexPath) as! FreewordTableViewCell
                freeword = cell.freeword
                cell.freeword.delegate = self
                cell.selectionStyle = .None
                return cell
            case 1:
                let cell = UITableViewCell()
                cell.textLabel?.text = "現在地から検索"
                cell.accessoryType = .DisclosureIndicator
                return cell
            default:
                return UITableViewCell()
            }
        }        
//        
//        if indexPath.section == 0 && indexPath.row == 0 {
//            let cell = tableView.dequeueReusableCellWithIdentifier("Freeword",
//            forIndexPath: indexPath) as! FreewordTableViewCell
//            // UITextField to reference
//            freeword = cell.freeword
//            // UITextFieldDelegate to set
//            cell.freeword.delegate = self
//            // tab to ignore
//            cell.selectionStyle = .None
//            return cell
//        }
        return UITableViewCell()
        
    }
    
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        performSegueWithIdentifier("PushShopList", sender: self)
        
        return true
    }

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


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "PushShopList" {
            let vc = segue.destinationViewController as? ShopListViewController
            vc!.yls.condition.query = freeword?.text
        }
        
        if segue.identifier == "PushShopListFromHere" {
            let vc = segue.destinationViewController as? ShopListViewController
            vc!.yls.condition.lat = self.here?.lat
            vc!.yls.condition.lon = self.here?.lon
        }
        
    }
    
    

}
