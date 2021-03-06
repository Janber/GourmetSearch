//
//  LicenseListViewController.swift
//  GourmetSearch
//
//  Created by JW on 12/29/27 H.
//  Copyright © 27 Heisei woo. All rights reserved.
//

import UIKit

class LicenseListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableview: UITableView!
    
    private struct Software {
        var name: String
        var license: String
    }
    
    private var softwares = [Software]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // plistからソフトウェア名とライセンス文章を取得する
        let mainBundle = NSBundle.mainBundle()
        if let path = mainBundle.pathForResource("Licenses", ofType: "plist") {
            if let items = NSArray(contentsOfFile: path) {
                for item in items {
                    // ソフトウェア名、ライセンス文章ともにnilチェックする
                    let name = item["Name"] as? String
                    let license = item["License"] as? String
                    if name == nil || license == nil { continue }
                    // softwares配列に追加する
                    softwares.append(Software(name: name!, license: license!))
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // セルの選択状態を解除する
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        // Segueを実行する
        performSegueWithIdentifier("PushLicenseDetail", sender: indexPath)
    }
    
    
    // MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Software")! as UITableViewCell
        cell.textLabel?.text = softwares[indexPath.row].name
        return cell
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return softwares.count
    }
    
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "PushLicenseDetail" {
            let vc = segue.destinationViewController as! LicenseDetailViewController
            if let indexPath = sender as? NSIndexPath {
                vc.name = softwares[indexPath.row].name
                vc.license = softwares[indexPath.row].license
            }
        }
    }


}
