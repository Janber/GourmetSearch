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
            yls.loadData(true)
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
        yls.loadData(true)
        
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
    
    
}
