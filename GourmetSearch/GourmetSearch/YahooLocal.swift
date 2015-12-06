//
//  YahooLocal.swift
//  GourmetSearch
//
//  Created by JW on 11/29/27 H.
//  Copyright © 27 Heisei woo. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import AlamofireSwiftyJSON


public struct Shop: CustomStringConvertible {
    
    public var gid: String? = nil
    public var name: String? = nil
    public var photoUrl: String? = nil
    public var yomi: String? = nil
    public var tel: String? = nil
    public var address: String? = nil
    public var lat: Double? = nil
    public var lon: Double? = nil
    public var catchCopy: String? = nil
    public var hasCoupon = false
    public var station: String? = nil
    
    public var description: String{
        get {
            var string = "\nGid: \(gid)\n"
            string += "Name: \(name)\n"
            string += "PhotoUrl: \(photoUrl)\n"
            string += "Yomi: \(yomi)\n"
            string += "Tel: \(tel)\n"
            string += "Address: \(address)\n"
            string += "Lat & Lon: (\(lat), \(lon))\n"
            string += "CatchCopy: \(catchCopy)\n"
            string += "hasCoupon: \(hasCoupon)\n"
            string += "Station: \(station)\n"
            return string
        }
    }
}


public struct QueryCondition {
    // keyword
    public var query: String? = nil
    // shopId
    public var gid: String? = nil
    // sort
    public enum Sort: String{
        case Score = "score"
        case Geo = "geo"
    }
    public var sort: Sort = .Score
    // lat
    public var lat: Double? = nil
    // lon
    public var lon: Double? = nil
    // dist
    public var dist: Double? = nil
    
    // search para dic
    public var queryParams: [String: String] {
        get {
            var params = [String: String]()
            //keyword
            if let unwrapped = query {
                params["query"] = unwrapped
            }
            //shopId
            if let unwrapped = gid {
                params["gid"] = unwrapped
            }
            // sort
            switch sort {
            case .Score:
                params["sort"] = "score"
            case .Geo:
                params["sort"] = "geo"
            }
            // lat
            if let unwrapped = lat {
                params["lat"] = "\(unwrapped)"
            }
            //lon
            if let unwrapped = lon {
                params["lon"] = "\(unwrapped)"
            }
            //dist
            if let unwrapped = dist {
                params["dist"] = "\(unwrapped)"
            }
            //device
            params["device"] = "mobile"
            // grouping
            params["group"] = "gid"
            // only search date which has image
            params["image"] = "true"
            // indutry code
            params["gc"] = "01"
            
            return params
            
        }
    }
    
}




public class YahooLocalSearch {
    // begin in reading notification
    public let YLSLoadStartNotification = "YLSLoadStartNotification"
    // end of reading notification
    public let YLSLoadCompleteNotification = "YLSLoadCompleteNotification"
    // notification
    public let notification = "notification"
    
    
    // yahoo! local search API appID
    let apiId = "dj0zaiZpPWdTQ2dYVld5QkI1aSZzPWNvbnN1bWVyc2VjcmV0Jng9NjM-"
    
    // API base URL
    let apiURL = "http://search.olp.yahooapis.jp/OpenLocalPlatform/V1/localSearch"
    
    // first page recode number
    let perPage = 10
    
    // finish readed shop
    public var shops = [Shop]()
    
    // if data reading then true
    var loading = false
    
    // total numbers
    public var total = 0
    
    // search condition
    var condition: QueryCondition = QueryCondition() {
        //when new value be set then delete the old value
        didSet {
            shops = []
            total = 0
        }
    }
    
    // para is none
    public init() {}
    
    // when para is search condition
    public init(condition: QueryCondition){
        self.condition = condition
    }
    
    // read the data from API
    // if reset = true then from beginning
    public func loadData(reset:Bool = false) {
        
        // if state is data reading then return
        if loading { return }
        
        //notification of API's first beginning
        NSNotificationCenter.defaultCenter().postNotificationName(
            YLSLoadStartNotification, object: nil)
        
        //reset = true then drop the before result
        if reset {
            shops = []
            total = 0
        }
        
        // if data reading then flag is on
        loading = true
        
        
        // get the condition dictionary
        var params = condition.queryParams
        // setting the params of API which exclude the search condition
        params["appid"] = apiId
        params["output"] = "json"
        params["start"] = String(shops.count + 1 )
        params["results"] = String(perPage)
        // API request
        Alamofire.request(.GET, apiURL, parameters: params).responseSwiftyJSON({
            // finish the response then do closure
            (request, response, json, error) -> Void in
            //error
            if error != nil {
                // if error flag is off
                self.loading = false
                
                // notice that API do finish
                var message = "Unknown error."
                if let _ = error as NSError? {
                    message = error.debugDescription
                }
                NSNotificationCenter.defaultCenter().postNotificationName(
                    self.YLSLoadStartNotification,
                    object: nil,
                    userInfo: ["error":message])
                return
            }
            // add shop data to self.shops
            for (_, item) in json["Feature"] {
                var shop = Shop()
                // shopId
                shop.gid = item["Gid"].string
                // shop name
                let name = item["Name"].string
                // the format of "&#39;" to decode
                shop.name = name?.stringByReplacingOccurrencesOfString("&#39;",
                    withString: "'",
                    options: .LiteralSearch,
                    range:nil)
                // yomi
                shop.yomi = item["Property"]["Yomi"].string
                // tel
                shop.tel = item["Property"]["Tell"].string
                // add
                shop.address = item["Property"]["Address"].string
                // lat & Lon
                if let geometry = item["Geometry"]["Coordinates"].string{
                    let components = geometry.componentsSeparatedByString(",")
                    // lat
                    shop.lat = (components[1] as NSString).doubleValue
                    shop.lon = (components[0] as NSString).doubleValue
                }
                // catchCopy
                shop.catchCopy = item["Property"]["CatchCopy"].string
                // shop photo
                shop.photoUrl = item["Property"]["LeadImage"].string
                // coupon
                if item["Property"]["CouponFlag"].string == "true" {
                    shop.hasCoupon = true
                }
                // station
                if let stations = item["Property"]["Station"].array {
                    // use the first name
                    var line = ""
                    if let lineString = stations[0]["Railway"].string {
                        let lines = lineString.componentsSeparatedByString("/")
                        line = lines[0]
                    }
                    if let station = stations[0]["Name"].string {
                        //if both have station name and line name then both input
                        shop.station = "\(line)\(station)"
                    }else {
                        // just input line name
                        shop.station = "\(line)"
                    }
                }
                // print(shop)
                self.shops.append(shop)
            }
            //put the totols
            if let total = json["ResultInfo"]["Total"].int {
                self.total = total
            }else {
                self.total = 0
            }
            
            // when API finish then flag is OFF
            self.loading = false
            
            // notice the end of API'S do
            NSNotificationCenter.defaultCenter().postNotificationName(
                self.YLSLoadStartNotification, object: nil)
        })
    }
    
    
    func sortByGid(){
        var newShops = [Shop]()
        
        //components separated by string ","
        if let gids = self.condition.gid?.componentsSeparatedByString(","){
            // loop by gid
            for gid in gids {
                let filtered = shops.filter{ $0.gid == gid }
                if filtered.count > 0 {
                    newShops.append(filtered[0])
                }
            }
        }
        // return new array
        shops = newShops
    }

    
}










































