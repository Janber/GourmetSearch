//
//  ShopDetailViewController.swift
//  GourmetSearch
//
//  Created by JW on 12/5/27 H.
//  Copyright © 27 Heisei woo. All rights reserved.
//

import UIKit
import MapKit
import Social

class ShopDetailViewController: UIViewController, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var nameHeight: NSLayoutConstraint!
    @IBOutlet weak var tel: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var addressContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var favoriteIcon: UIImageView!
    @IBOutlet weak var favoriteLabel: UILabel!
    
    @IBOutlet weak var line: UIButton!
    @IBOutlet weak var twitter: UIButton!
    @IBOutlet weak var facebook: UIButton!
    
    
    let ipc = UIImagePickerController()
    var shop = Shop()
    
    
    @IBAction func lineTapped(sender: AnyObject) {
        var message = ""
        if let name = shop.name {
            message += name + "\n"
        }
        if let url = shop.url {
            message += url + "\n"
        }
        if let encoded = message.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet()){
            if let uri = NSURL(string: "line://msg/text" + encoded) {
                UIApplication.sharedApplication().openURL(uri)
            }
            
        }
        
    }
    
    // MARK: - twitter share
    func share(type:String) {
        let vc = SLComposeViewController(forServiceType: type)
        if let name = shop.name {
            vc.setInitialText(name + "\n")
        }
        if let gid = shop.gid {
            if ShopPhoto.sharedInstance?.count(gid) > 0 {
                vc.addImage(ShopPhoto.sharedInstance?.image(gid, index: 0))
            }
            
        }
        if let url = shop.url {
            vc.addURL(NSURL(string: url))
        }
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    
    
    @IBAction func twitterTapped(sender: AnyObject) {
        share(SLServiceTypeTwitter)
    }

    @IBAction func facebookTapped(sender: AnyObject) {
        share(SLServiceTypeFacebook)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // map
        if let lat = shop.lat {
            if let lon = shop.lon {
                // map display scole specity
                let cllc = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                let mkcr = MKCoordinateRegionMakeWithDistance(cllc, 200, 200)
                map.setRegion(mkcr, animated: false)
                
                // set pin
                let pin = MKPointAnnotation()
                pin.coordinate = cllc
                map.addAnnotation(pin)
            }
            // reflect to favorite button
            updateFavoriteButton()
        }
        

        // Do any additional setup after loading the view.
        // photo
        if let url = shop.photoUrl{
            photo.sd_setImageWithURL(NSURL(string: url),
            placeholderImage: UIImage(named: "loading"),
                completed: nil)
        } else {
            photo.image = UIImage(named: "loading")
        }
        
        // shopName
        name.text = shop.name
        
        // tel
        tel.text = shop.tel
        
        // address
        address.text = shop.address
        
//        // favorite
//        updateFavoriteButton()
        
        // UIImagePickerControllerDelegate
        ipc.delegate = self
        
        ipc.allowsEditing = true
        
        // Facebook,Twitter,LINEの利用可能状態をチェック
        if UIApplication.sharedApplication().canOpenURL(NSURL(string:"line://")!){
            line.enabled = true
        }
        
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            twitter.enabled = true
        }

        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
            facebook.enabled = true
        }
    }
    
    // MARK: - updateFavoriteButton
    func updateFavoriteButton(){
        if Favorite.inFavorites(shop.gid){
            // favorite
            favoriteIcon.image = UIImage(named: "star-on")
            favoriteLabel.text = "お気に入りからはずす"
        } else {
            favoriteIcon.image = UIImage(named: "star-off")
            favoriteLabel.text = "お気に入りに入れる"
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        self.scrollView.delegate = self
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.scrollView.delegate = nil
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK : - UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let scrollOffset = scrollView.contentOffset.y + scrollView.contentInset.top
        if scrollOffset <= 0 {
            photo.frame.origin.y = scrollOffset
            photo.frame.size.height = 200 - scrollOffset
        }
    }
    
    
    
    override func viewDidLayoutSubviews() {
        let nameFrame = name.sizeThatFits(
        CGSizeMake(name.frame.size.width, CGFloat.max))
        nameHeight.constant = nameFrame.height
        
        let addressFrame = address.sizeThatFits(
        CGSizeMake(address.frame.size.width, CGFloat.max))
        addressContainerHeight.constant = addressFrame.height
        
        view.layoutIfNeeded()
    }
    
    
    
    // MARK: - IBAction
    @IBAction func telTapped(sender: UIButton) {
    
        if let tel = shop.tel {
            let url = NSURL(string: "tel:\(tel)")
            if (url == nil){ return }
            
            if !UIApplication.sharedApplication().canOpenURL(url!){
                let alert = UIAlertController(title: "電話をかけることができません",
                    message: "この端末には電話機能が搭載されていません。",
                    preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                presentViewController(alert, animated: true, completion: nil)
                return
            }
            
            
            if let name = shop.name {
                let alert = UIAlertController(title: name,
                    message: "\(name)に電話をかけます。",
                    preferredStyle: .Alert)
                alert.addAction(
                    UIAlertAction(title: "電話をかける", style: .Default, handler: {
                        action in
                        UIApplication.sharedApplication().openURL(url!)
                        return
                    }))
                alert.addAction(
                    UIAlertAction(title: "キャンセル", style: .Cancel, handler: nil ))
                presentViewController(alert, animated: true, completion: nil )
                
            }

        }
    
    }
    
    
    // MARK: - Navigition
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PushMapDetail" {
            let vc = segue.destinationViewController as! ShopMapDetailViewController
            vc.shop = shop
        }
    }
    
    
    
    @IBAction func addressTapped(sender: UIButton) {
       // print("addressTapped")
        performSegueWithIdentifier("PushMapDetail", sender: nil)
    }
    

    @IBAction func favoriteTapped(sender: UIButton) {
        Favorite.toggle(shop.gid)
        updateFavoriteButton()
    }
    
    
    //MARK: - UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        ipc.dismissViewControllerAnimated(true, completion: nil)
    }

    
    @IBAction func addPhotoTapped(sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: nil,
            message: nil,
            preferredStyle: .ActionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera){
            alert.addAction(
            UIAlertAction(title: "写真を撮る", style: .Default, handler: {
                action in
                
                self.ipc.sourceType = .Camera
                self.presentViewController(self.ipc,
                    animated: true, completion: nil)
                
            }))
            
        }
        
        alert.addAction(UIAlertAction(title: "写真を選択", style: .Default, handler: { action in
            
            self.ipc.sourceType = .PhotoLibrary
            self.presentViewController(self.ipc, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "キャンセル", style: .Cancel, handler: { action in
    
        }))
        
       presentViewController(alert, animated: true, completion: nil)

    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage{
            ShopPhoto.sharedInstance?.append(shop: shop, image: image)
        }
        
        picker.dismissViewControllerAnimated(true, completion: nil)
        // ipc.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
