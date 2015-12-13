//
//  PhotoListViewController.swift
//  GourmetSearch
//
//  Created by JW on 12/12/27 H.
//  Copyright © 27 Heisei woo. All rights reserved.
//

import UIKit

class PhotoListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        collectionView.reloadData()
    }
    
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    // adjust size
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let size = self.view.frame.size.width/3
        return CGSize(width: size, height: size)
    }
    
    // MARK: - UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        // number of session is shop number
        if let count = ShopPhoto.sharedInstance?.gids.count{
            return count
        }
        return 0
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let count = ShopPhoto.sharedInstance?.numberOfPhotosInIndex(section) {
            return count
        }
        return 0
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        // getting cell from Storyboard
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoListItem", forIndexPath: indexPath) as! PhotoListItemCollectionViewCell
        
        if let gid = ShopPhoto.sharedInstance?.gids[indexPath.section] {
            
            cell.photo.image = ShopPhoto.sharedInstance?.image(gid, index: indexPath.row)
        }
        return cell
    }
    
    
    // header processing
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        // only header
        if kind == UICollectionElementKindSectionHeader {
            // get header from Storyboard
            let header = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader,
                withReuseIdentifier: "PhotoListHeader",
                forIndexPath: indexPath) as! PhotoListItemCollectionViewHeader
            
            // get shop ID
            if let gid = ShopPhoto.sharedInstance?.gids[indexPath.section]{
                // shop name
                if let name = ShopPhoto.sharedInstance?.names[gid] {
                    // header title
                    header.title.text = name
                }
            }
            return header
        }
        return UICollectionReusableView()
    }
    
    
}
