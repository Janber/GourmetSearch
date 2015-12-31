//
//  ViewController.swift
//  GourmetSearch
//
//  Created by JW on 11/29/27 H.
//  Copyright © 27 Heisei woo. All rights reserved.
//

import UIKit

class ShopListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var yls: YahooLocalSearch = YahooLocalSearch()
    var loadDataObserver: NSObjectProtocol?
    var refreshObserver: NSObjectProtocol?
    
    
    override func viewDidLoad() {
        
        // if not favorite then edit button remove
        if !(self.navigationController is FavoriteNavigationController) {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        
        
        super.viewDidLoad()
        
        // pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self,
            action: "onRefresh:", forControlEvents: .ValueChanged)
        
        self.tableView.addSubview(refreshControl)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        /*
        var qc = QueryCondition()
        qc.query = "ハンバーガー"
        
        yls = YahooLocalSearch(condition: qc)
        
    //    print("APIリクエスト完了")
        */
        
        // the processing of notification which had finish readed
        loadDataObserver = NSNotificationCenter.defaultCenter().addObserverForName(
            yls.YLSLoadStartNotification,
            object: nil,
            queue: nil,
            usingBlock: {
                (notification) in
                
                // gid is specify then sort
                if self.yls.condition.gid != nil {
                    self.yls.sortByGid()
                }
                
               self.tableView.reloadData()
                //    print("APIリクエスト完了")
                //if error, dialog will be open
                if notification.userInfo != nil {
                    if let userInfo = notification.userInfo as? [String: String!]{
                        if userInfo["error"] != nil {
                            let alertView = UIAlertController(title: "通信エラ−",
                                message: "通信エラーが発生しました。",
                                preferredStyle: .Alert)
                            alertView.addAction(
                                UIAlertAction(title: "OK", style: .Default){
                                    action in return
                                }
                            )
                            self.presentViewController(alertView,
                                animated: true, completion: nil)
                        }
                    }
                    
                }
            })
        
        if yls.shops.count == 0 {
    
            if self.navigationController is FavoriteNavigationController {
                loadFavorites()
                self.navigationItem.title = "お気に入り"
            } else {
                yls.loadData(true)
                self.navigationItem.title = "店舗一覧"
            }
            
        }
    }
    
    
    // MARK: - loadFavorites
    func loadFavorites(){
        // load the User Defaults
        Favorite.load()
        // if have favorite then make the summary of gid, do search
        if Favorite.favorites.count > 0 {
            // favorite summary to display that search condition
            var condition = QueryCondition()
            condition.gid = Favorite.favorites.joinWithSeparator(",")
            // setting the search condition
            yls.condition = condition
            yls.loadData(true)
        } else {
            // if no have favorite, don't do search, and notice API
            NSNotificationCenter.defaultCenter().postNotificationName(
                yls.YLSLoadCompleteNotification, object: nil)
        }
    }
    
    
    
    override func viewWillDisappear(animated: Bool) {
        // finish the notification
        NSNotificationCenter.defaultCenter().removeObserver(self.loadDataObserver!)
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Pull to Refresh
    func onRefresh(refreshControl: UIRefreshControl){
        // begin refreshing
        refreshControl.beginRefreshing()
        // end refreshing
        refreshObserver = NSNotificationCenter.defaultCenter().addObserverForName(
            yls.YLSLoadCompleteNotification,
            object: nil,
            queue: nil,
            usingBlock: {
                notification in
                NSNotificationCenter.defaultCenter().removeObserver(self.refreshObserver!)
                refreshControl.endRefreshing()
            })
        
        if self.navigationController is FavoriteNavigationController {
            // get the User Defaults
            loadFavorites()
        } else {
            // tab Search
            yls.loadData(true)
            
        }
        
    }
    
    
    
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    // MARK: - UITableViewDateSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return yls.shops.count
        }
        
        return 0
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row < yls.shops.count {
                let cell = tableView.dequeueReusableCellWithIdentifier("ShopListItem") as! ShopListItemTableViewCell
                
                cell.lat = yls.condition.lat
                cell.lon = yls.condition.lon
                
                cell.shop = yls.shops[indexPath.row]
                
                if yls.shops.count < yls.total {
                    if yls.shops.count - indexPath.row <= 4 {
                        yls.loadData()
                    }
                }
                return cell
            }
        }
        return UITableViewCell()
        
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // deselect row
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        // do segue
        performSegueWithIdentifier("PushShopDetail", sender: indexPath)
    }
    
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PushShopDetail" {
            let vc = segue.destinationViewController as? ShopDetailViewController
            if let indexPath = sender as? NSIndexPath {
                vc!.shop = yls.shops[indexPath.row]
            }
        }
    }
    
    // delete
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // favorite delete impossble
        return self.navigationController is FavoriteNavigationController
    }
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // delete
        if editingStyle == .Delete {
            // reflect to User Defaults
            Favorite.remove(yls.shops[indexPath.row].gid)
            // reflect to yls.shops
            yls.shops.removeAtIndex(indexPath.row)
            // reflect to UITableView
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    
    
    // move row
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // can move row
        return self.navigationController is FavoriteNavigationController
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        // if move destination is same before move
        if sourceIndexPath == destinationIndexPath { return }
        // reflect to yls.shops
        let source = yls.shops[sourceIndexPath.row]
        yls.shops.removeAtIndex(sourceIndexPath.row)
        yls.shops.insert(source, atIndex: destinationIndexPath.row)
        // reflect to user defaults
        Favorite.move(sourceIndexPath.row, destinationIndexPath.row)
    }
    
    // MARK: - IBAction
    @IBAction func editButtonTapped(sender: UIBarButtonItem) {
        if tableView.editing {
            tableView.setEditing(false, animated: true)
            sender.title = "編集"
        } else {
            tableView.setEditing(true, animated: true)
            sender.title = "完了"
        }
    }
}
