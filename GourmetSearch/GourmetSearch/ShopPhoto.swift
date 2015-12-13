//
//  ShopPhoto.swift
//  GourmetSearch
//
//  Created by JW on 12/12/27 H.
//  Copyright © 27 Heisei woo. All rights reserved.
//

import Foundation


public class ShopPhoto{

    var photos = [String:[String]]()
    var names = [String:String]()
    var gids = [String]()
    let path: String
    
    // singlton
    public class var sharedInstance: ShopPhoto? {
        struct Static {
            static let instance = ShopPhoto()
        }
        return Static.instance
    }
    
    private init?(){
        // get save path
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask, true)
        
        // check
        if paths.count > 0 {
            path = paths[0] as String
        } else {
            path = ""
            return nil
        }
        
        // loading the data from UserDefaults
        load()
        
    }
    
    // load
    private func load(){
        
        photos.removeAll()
        names.removeAll()
        gids.removeAll()
        
        let ud = NSUserDefaults.standardUserDefaults()
        ud.registerDefaults([
            "photos" : [String:[String]](),
            "names" : [String:String](),
            "gids" : [String]()
            ])
        
        ud.synchronize()
        
        if let photos = ud.objectForKey("photos") as? [String:[String]]{
            self.photos = photos
        }
        
        if let names = ud.objectForKey("names") as? [String:String]{
            self.names = names
        }
        
        if let gids = ud.objectForKey("gids") as? [String]{
            self.gids = gids
        }
    }
    
    
    // save data
    private func save(){
        
        let ud = NSUserDefaults.standardUserDefaults()
        ud.setObject(photos, forKey: "photos")
        ud.setObject(names, forKey: "names")
        ud.setObject(gids, forKey: "gids")
        ud.synchronize()
        
    }
    
    // add pic
    public func append(shop shop:Shop, image:UIImage){
        
        if shop.gid == nil { return }
        if shop.name == nil { return }
        
        let filename = NSUUID().UUIDString + ".jpg"
      //  let fullpath = path.stringByAppendingPathComponent(filename)
        let fullpath = path.stringByAppendingString("/\(filename)") as String
        
        // UIImage to make JPEG
        let data = UIImageJPEGRepresentation(image, 0.8)
        
        // if save data sucess 
        if data!.writeToFile(fullpath, atomically: true){
            
         //   print("save: \(fullpath)")
            
            if photos[shop.gid!] == nil {
                photos[shop.gid!] = [String]()
            } else {
                gids = gids.filter{ $0 != shop.gid! }
            }
            
            gids.append(shop.gid!)
            photos[shop.gid!]?.append(filename)
            names[shop.gid!] = shop.name
            save()
            
        }
    
    }
    
    // return spcify shop's pic
    public func image(gid:String,index:Int) -> UIImage {
        
        if photos[gid] == nil { return UIImage()}
        
        if index >= photos[gid]?.count { return UIImage() }
        
        if let filename = photos[gid]?[index]{
            let fullpath = path.stringByAppendingString("/\(filename)") as String
            
            if let image = UIImage(contentsOfFile: fullpath){
                return image
            }
        }
        return UIImage()
    }
    
    
    // return the number of spcify shop's photo by shop ID
    public func count(gid: String) -> Int {
        
        if photos[gid] == nil { return 0 }
        return photos[gid]!.count
    }
    
    
    // return the number of spcify shop's photo by index
    public func numberOfPhotosInIndex(index: Int) -> Int {
        if index >= gids.count { return 0 }
        
        if let photos = photos[gids[index]]{
            return photos.count
        }
        return 0
    }
    
}