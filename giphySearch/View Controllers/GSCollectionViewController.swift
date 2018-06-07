//FLAnimatedImageView
//  GifStreamViewController.swift
//  giphySearch
//
//  Created by Mubarak Sadoon on 2018-06-05.
//  Copyright © 2018 msadoon. All rights reserved.
//

//Custom bar button credit: https://stackoverflow.com/questions/5761183/change-position-of-uibarbuttonitem-in-uinavigationbar

import UIKit
import AVFoundation

class GSCollectionViewController: UICollectionViewController {
    
    var gifs:[Gif] = []
    var selectedIndexPath:IndexPath? = nil
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        NetworkManager.getGiphs(searchTerm:"cats", completion: { (status, records) in
        //
        //            if status {
        //                self.gifs = records
        //                self.collectionView?.reloadData()
        //            }
        //
        //        })
        
        self.navigationController?.delegate = self
        
        if let layout = collectionView?.collectionViewLayout as? GSCollectionViewLayout {
            layout.delegate = self
        }
        
        for index in 1...12 {
            if let imageFound = UIImage(named: "\(index).jpg") {
                gifs.append(Gif(image: imageFound))
            }
        }
        
        self.collectionView?.reloadData()
        
        collectionView?.backgroundColor = .clear
        collectionView?.contentInset = UIEdgeInsets(top: 23, left: 16, bottom: 10, right: 16)
        
    }
    
}

//MARK: UINavigationController Delegate Methods

extension GSCollectionViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let foundSelectedIndexPath = selectedIndexPath {
            return GCTransitionCustomAnimator(operation: operation, indexPath: foundSelectedIndexPath)
        } else {
            return nil
        }
    }
}

//MARK: CollectionView Delegate Methods

extension GSCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gifs.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GifCollectionViewCell", for: indexPath) as! GifCollectionViewCell
        
        cell.imageView.image = gifs[indexPath.row].image
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSize = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right + 10)) / 2
        return CGSize(width: itemSize, height: itemSize)
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 willDisplay cell: UICollectionViewCell,
                                 forItemAt indexPath: IndexPath) {
        if cell is GifCollectionViewCell {
            cell.layoutSubviews()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 didSelectItemAt indexPath: IndexPath) {
        
        guard let _:GifCollectionViewCell = self.collectionView?.cellForItem(at: indexPath) as? GifCollectionViewCell,
              let gifDetailVC = storyboard?.instantiateViewController(withIdentifier: "GSDetailViewControllerID") as? GSDetailViewController else {
            return
        }
        
        selectedIndexPath = indexPath
        gifDetailVC.mainGif = gifs[indexPath.row].image
        self.navigationController?.pushViewController(gifDetailVC, animated: true)
    }
    
}

//MARK: Custom Flow Layout Delegate

extension GSCollectionViewController: GSCollectionViewLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForImageAtIndexPath indexPath: IndexPath) -> CGFloat {
        return gifs[indexPath.item].image.size.height
    }
}
