//
//  PhotoListItemCollectionViewCell.swift
//  GourmetSearch
//
//  Created by JW on 12/12/27 H.
//  Copyright © 27 Heisei woo. All rights reserved.
//

import UIKit

class PhotoListItemCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var photo: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
    
    

}
