//
//  ShopMapDetailViewController.swift
//  GourmetSearch
//
//  Created by JW on 12/6/27 H.
//  Copyright © 27 Heisei woo. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ShopMapDetailViewController: UIViewController,CLLocationManagerDelegate {
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var showHereButton: UIBarButtonItem!
    
    let ls = LocationService()
    let nc = NSNotificationCenter.defaultCenter()
    var observers = [NSObjectProtocol]()
    var shop: Shop = Shop()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // the position of shop to reflect to map
        if let lat = shop.lat {
            if let lon = shop.lon {
                // to specity the socope of map's display
                let cllc = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                let mkcr = MKCoordinateRegionMakeWithDistance(cllc, 500, 500)
                map.setRegion(mkcr, animated: false)
                
                // set pin
                let pin = MKPointAnnotation()
                pin.coordinate = cllc
                pin.title = shop.name
                map.addAnnotation(pin)
            }
        }
        
        self.navigationItem.title = shop.name
    }
    
    
    override func viewWillAppear(animated: Bool) {
       // super.viewWillAppear(animated)
        // Auth Denied
        observers.append(nc.addObserverForName(ls.LSAuthDeniedNotification,
            object: nil,
            queue: nil,
            usingBlock: {
                notification in
                // service disable
                self.presentViewController(self.ls.locationServiceDisabledAlert,
                    animated: true,
                    completion: nil)
                // now positon button is inactive
                self.showHereButton.enabled = false
        
        })
        )
        
        // Auth Restricted
        observers.append(
        nc.addObserverForName(ls.LSAuthRestrictedNotification,
            object: nil,
            queue: nil,
            usingBlock: {
                notification in
                
                // restricted diague
                self.presentViewController(self.ls.locationServiceRestrictedAlert,
                    animated: true,
                    completion: nil)
                // now position button inactive
                self.showHereButton.enabled = false
        })
        )
        
    
        // Did fail location
        observers.append(
            nc.addObserverForName(ls.LSDidFailLocationNotification,
                object: nil,
                queue: nil,
                usingBlock:{
                    notification in
                    
                    // position fail diague
                    self.presentViewController(self.ls.locationServiceDidFailAlert,
                        animated: true,
                        completion: nil)
                    // now position is inactive
                    self.showHereButton.enabled = false
            })
        )
        
        // sucess in getting position
        observers.append(
        nc.addObserverForName(ls.LSDidUpdateLocationNotification,
            object: nil,
            queue: nil,
            usingBlock: {
                notification in

                if let userInfo = notification.userInfo as? [String: CLLocation] {
                    if let clloc = userInfo["location"]{
                        if let lat = self.shop.lat{
                            if let lon = self.shop.lon{
                                
                                // shop position
                                let center = CLLocationCoordinate2D(
                                latitude: (lat + clloc.coordinate.latitude) / 2,
                                longitude: (lon + clloc.coordinate.longitude) / 2
                                )
                                let diff = (
                                    lat: abs(clloc.coordinate.latitude - lat),
                                    lon: abs(clloc.coordinate.longitude - lon))
                                
                                // display scode
                                let mkcs = MKCoordinateSpanMake(diff.lat * 1.4, diff.lon * 1.35)
                                let mkcr = MKCoordinateRegion(center: center, span: mkcs)
                                
                           
                                self.map.setRegion(mkcr, animated: true)
                                
                                // display now position
                                self.map.showsUserLocation = true
                                print("now position")
                            }
                        }
                    }
                }
                // now position button is active
                self.showHereButton.enabled = true
        })
        )
        
        // authorized 
        observers.append(
        nc.addObserverForName(ls.LSAuthorizedNotification,
            object: nil,
            queue: nil,
            usingBlock: {
                notification in
            
                // now position button active
                self.showHereButton.enabled = true
        })
        
        )
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        
        for _ in observers {
            nc.removeObserver(observers)
        }
        observers = []
    }
    
    
    // MARK: - IBAction
    @IBAction func showHereButtonTapped(sender: UIBarButtonItem) {
        
        ls.startUpdatingLocation()
        
        }
    
    
}
