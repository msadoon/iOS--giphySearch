//
//  GSLoadingCollectionReusableView.swift
//  giphySearch
//
//  Created by Mubarak Sadoon on 2018-06-08.
//  Copyright © 2018 msadoon. All rights reserved.
//

import UIKit

class GSLoadingCollectionReusableView: UICollectionReusableView {
        
    @IBOutlet weak var loadingImageView: UIImageView!
    @IBOutlet weak var loadingButton: UIButton!
    
    weak var delegate:LoadMoreGifsProtocol?
    
    @IBAction func loadMoreGIFS(_ sender: UIButton) {
        
        loadingImageView.isHidden = false
        loadingButton.isHidden = true
        self.delegate?.loadMoreGifs()
    }
}
