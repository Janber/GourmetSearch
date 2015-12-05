//
//  ShopListItemTableViewCell.swift
//  GourmetSearch
//
//  Created by JW on 11/29/27 H.
//  Copyright © 27 Heisei woo. All rights reserved.
//

import UIKit

class ShopListItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var iconContainer: UIView!
    @IBOutlet weak var coupon: UILabel!
    @IBOutlet weak var station: UILabel!
    
    @IBOutlet weak var nameHeight: NSLayoutConstraint!
    @IBOutlet weak var stationWidth: NSLayoutConstraint!
    @IBOutlet weak var stationX: NSLayoutConstraint!
    
    var shop: Shop = Shop() {
        didSet {
            // if have imageURI, then to dispalay the image
            if let url = shop.photoUrl {
               // photo.sd_cancelCurrentImageLoad()
                photo.sd_cancelCurrentAnimationImagesLoad()
                photo.sd_setImageWithURL(
                    NSURL(string: url),
                    placeholderImage: UIImage(named: "loading"),
                    options: .RetryFailed )
            }
            
            
            //shop name 
            name.text = shop.name
            //coupon
            var x: CGFloat = 0
            let margin: CGFloat = 10
            if shop.hasCoupon {
                coupon.hidden = false
                x += coupon.frame.size.width + margin
                // label to round
                coupon.layer.cornerRadius = 4
                coupon.clipsToBounds = true
            } else {
                coupon.hidden = true
            }
            //station
            if shop.station != nil {
                station.hidden = false
                station.text = shop.station
                //lable position
                stationX.constant = x
                //lable size
                let size = station.sizeThatFits(CGSizeMake(CGFloat.max,CGFloat.max))
                if x + size.width + margin > iconContainer.frame.width {
                    //
                    stationWidth.constant = iconContainer.frame.width - x
                } else {
                    //
                    stationWidth.constant = size.width + margin
                }
                //
                station.clipsToBounds = true
                station.layer.cornerRadius = 4
            } else {
                station.hidden = true
            }
        }
    }
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //
        let maxFrame = CGRectMake(0, 0, name.frame.size.width, CGFloat.max)
        let actualFrame = name.textRectForBounds(maxFrame, limitedToNumberOfLines: 2)
        
        //
        nameHeight.constant = actualFrame.size.height
    }
    

}
