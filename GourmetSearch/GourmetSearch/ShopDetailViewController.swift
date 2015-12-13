//
//  ShopDetailViewController.swift
//  GourmetSearch
//
//  Created by JW on 12/5/27 H.
//  Copyright © 27 Heisei woo. All rights reserved.
//

import UIKit
import MapKit

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
    
    
    let ipc = UIImagePickerController()
    var shop = Shop()

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
    
    
    
    
    @IBAction func telTapped(sender: UIButton) {
        print("telTapped")
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
