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
    
    var image:FLAnimatedImage?
    var rank:Int = 0
    var color:UIColor = UIColor.black
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //containerView.layer.cornerRadius = 6
        //containerView.layer.masksToBounds = true
        imageView.animatedImage = nil
        rankLabel.text = ""
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.animatedImage = nil
        rankLabel.text = ""
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupCell()
    }

    private func setupCell() {
        rankLabel.text = "\(rank)"
        if let foundImage = image {
            imageView.animatedImage = foundImage
        }
        self.backgroundColor = color
    }
    
}
