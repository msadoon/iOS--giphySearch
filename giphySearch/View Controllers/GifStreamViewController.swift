//
//  GifStreamViewController.swift
//  giphySearch
//
//  Created by Mubarak Sadoon on 2018-06-05.
//  Copyright © 2018 msadoon. All rights reserved.
//

import UIKit
import AVFoundation

class GifStreamViewController: UICollectionViewController {

    var gifs = Gif.allGifs()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.backgroundColor = .clear
        collectionView?.contentInset = UIEdgeInsets(top: 23, left: 16, bottom: 10, right: 16)
    }
    
}

extension GifStreamViewController: UICollectionViewDelegateFlowLayout {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gifs.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GifCollectionViewCell", for: indexPath) as! GifCollectionViewCell
        cell.imageView.image = gifs[indexPath.row].image
        cell.commentLabel.text = gifs[indexPath.row].comment
        cell.captionLabel.text = gifs[indexPath.row].caption
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSize = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right + 10)) / 2
        return CGSize(width: itemSize, height: itemSize)
    }
    
}

