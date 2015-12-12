//
//  LocationService.swift
//  GourmetSearch
//
//  Created by JW on 12/6/27 H.
//  Copyright © 27 Heisei woo. All rights reserved.
//

import Foundation
import CoreLocation

public class LocationService: NSObject, CLLocationManagerDelegate {
    // position info use permission notification
    public let LSAuthDeniedNotification = "LSAuthDeniedNotification"
    
    // position info limited notification
    public let LSAuthRestrictedNotification = "LSAuthRestrictedNotification"
    
    // position info use possble notification
    public let LSAuthorizedNotification = "LSAuthorizedNotification"
    
    // position info did upatate
    public let LSDidUpdateLocationNotification = "LSDidUpdateLocationNotification"
    
    // position info did fail
    public let LSDidFailLocationNotification = "LSDidFailLocationNotification"
    
    
    private let cllm = CLLocationManager()
    private let nsnc = NSNotificationCenter.defaultCenter()
    
    
    // position info if not ON diague
    public var locationServiceDisabledAlert: UIAlertController {
        get {
            let alert = UIAlertController(title: "位置情報が取得できません",
                message: "設定からプライバシー　→　位置情報画面を開いてGourmetSearchの位置情報の許可を「このAppの使用中のみ許可」と設定してください。", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "閉じる", style: .Cancel, handler: nil)
            )
            return alert
        }
    }
    
    
    // restricted diague
    public var locationServiceRestrictedAlert: UIAlertController {
        get {
            let alert = UIAlertController(title: "位置情報が取得できません",
                message: "設定から一般　→　機能規制画面を開いてGourmetSearchが位置情報を使用できる設定にしてください。",
                preferredStyle: .Alert)
            
            alert.addAction(UIAlertAction(title: "閉じる", style: .Cancel, handler: nil))
            return alert
        }
    }
    
    // fail diague
    public var locationServiceDidFailAlert: UIAlertController {
        get {
            let alertView = UIAlertController(title: nil, message: "位置情報の取得に失敗しました。", preferredStyle: .Alert)
            alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            return alertView
        }
    }
    
    // init
    public override init() {
        super.init()
        cllm.delegate = self
    }
    
    
    // MARK: - CLLocationManagerDelegate
    // did change authorization status
    public func loacationManger(manager: CLLocationManager!,
        didChangeAuthorizationSatus status: CLAuthorizationStatus) {
            switch status {
            case .NotDetermined:
                //
                cllm.requestWhenInUseAuthorization()
                
            case .Restricted:
                //
                nsnc.postNotificationName(LSAuthRestrictedNotification, object: nil)
                
            case .Denied:
                //
                nsnc.postNotificationName(LSAuthDeniedNotification, object: nil)
                
            case .AuthorizedWhenInUse:
                //
                break;
                
            default:
                //
                break;
            }
    }
    
    public func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // stop getting position info
        cllm.stopUpdatingLocation()
        // latest position to get
        if let location = locations.last {
            // position info to notification
            nsnc.postNotificationName(LSDidUpdateLocationNotification,
                object: self,
                userInfo: ["location": location])
        }
      
    
    }
    
    
    // did fail 
    public func locationManager(manager: CLLocationManager,
        didFailWithError error: NSError) {
            // send the fail error
            nsnc.postNotificationName(LSDidFailLocationNotification, object: nil)
    }
    
    
    // MARK: - startUpdatingLocation
    public func startUpdatingLocation(){
       let status = CLLocationManager.authorizationStatus()
        if status == .NotDetermined{
            cllm.requestWhenInUseAuthorization()
        }
        cllm.startUpdatingLocation()        
    }
}


