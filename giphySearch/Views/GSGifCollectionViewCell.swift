//
//  GSGifCollectionViewCell.swift
//  giphySearch
//
//  Created by Mubarak Sadoon on 2018-06-05.
//  Copyright © 2018 msadoon. All rights reserved.
//

import UIKit
import FLAnimatedImage

class GSGifCollectionViewCell: UICollectionViewCell {
 
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var imageView: FLAnimatedImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //containerView.layer.cornerRadius = 6
        //containerView.layer.masksToBounds = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        rankLabel.text = "0"
        imageView.image = nil
    }

}
