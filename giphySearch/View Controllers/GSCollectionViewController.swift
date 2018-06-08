//FLAnimatedImageView
//  GSGifStreamViewController.swift
//  giphySearch
//
//  Created by Mubarak Sadoon on 2018-06-05.
//  Copyright © 2018 msadoon. All rights reserved.
//

//Custom bar button credit: https://stackoverflow.com/questions/5761183/change-position-of-uibarbuttonitem-in-uinavigationbar

import UIKit
import CoreData
import FLAnimatedImage

class GSCollectionViewController: UICollectionViewController {
    
    var selectedIndexPath:IndexPath? = nil
    
    let searchTerm = "Cats"
    
    lazy var fetchedResultsController: NSFetchedResultsController<GSGif> = {
        let fetchRequest: NSFetchRequest<GSGif> = GSGif.fetchRequest()
        let rankSort = NSSortDescriptor(key: #keyPath(GSGif.rank), ascending: true)
        let predicate = NSPredicate(format: "%K == %@", #keyPath(GSGif.searchTerm), searchTerm)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [rankSort]
        fetchRequest.fetchBatchSize = 20
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: GSDataManager.sharedInstance.managedContext,
            sectionNameKeyPath: nil,
            cacheName: "gifs"
        )
        
        //fetchedResultsController.delegate = self;
        
        return fetchedResultsController
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        GSDataManager.sharedInstance.getAllGiphJSONData(searchTerm: searchTerm)
        self.navigationController?.delegate = self
        self.setupCollectionViewAndLayout()
    
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(updateCollectionView), name: .newGifsDownloaded, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .newGifsDownloaded, object: nil)
    }
    
    //MARK: Helper Methods
    
    private func setupCollectionViewAndLayout() {
        if let layout = collectionView?.collectionViewLayout as? GSCollectionViewLayout {
            layout.delegate = self
        }
        collectionView?.backgroundColor = .clear
        collectionView?.contentInset = UIEdgeInsets(top: 23, left: 16, bottom: 10, right: 16)
    }
    
    //MARK: Notification Methods
    @objc func updateCollectionView() {
        
        do {
            try fetchedResultsController.performFetch()
            DispatchQueue.main.async {
                self.collectionView?.collectionViewLayout.invalidateLayout()
                self.collectionView?.reloadData()
            }
        } catch let error as NSError {
            print("Oops! Error while fetching: " + error.description)
        }
        
    }
    
}

//MARK: UINavigationController Delegate Methods

extension GSCollectionViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let foundSelectedIndexPath = selectedIndexPath {
            return GSTransitionCustomAnimator(operation: operation, indexPath: foundSelectedIndexPath)
        } else {
            return nil
        }
    }
}

//MARK: CollectionView Delegate Methods

extension GSCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else {
            return 0
        }
        
        return sectionInfo.numberOfObjects
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GSGifCollectionViewCell", for: indexPath) as! GSGifCollectionViewCell
        
        cell.imageView.animatedImage = fetchedResultsController.object(at: indexPath).image
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSize = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right + 10)) / 2
        return CGSize(width: itemSize, height: itemSize)
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 willDisplay cell: UICollectionViewCell,
                                 forItemAt indexPath: IndexPath) {
        if cell is GSGifCollectionViewCell {
            cell.layoutSubviews()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 didSelectItemAt indexPath: IndexPath) {
        
        guard let _:GSGifCollectionViewCell = self.collectionView?.cellForItem(at: indexPath) as? GSGifCollectionViewCell,
              let gifDetailVC = storyboard?.instantiateViewController(withIdentifier: "GSDetailViewControllerID") as? GSDetailViewController else {
            return
        }
        
        selectedIndexPath = indexPath
        gifDetailVC.mainGif = fetchedResultsController.object(at: indexPath).image
        self.navigationController?.pushViewController(gifDetailVC, animated: true)
    }
    
}

//MARK: Custom Flow Layout Delegate

extension GSCollectionViewController: GSCollectionViewLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForImageAtIndexPath indexPath: IndexPath) -> CGFloat {
        if let foundImage:FLAnimatedImage = fetchedResultsController.object(at: indexPath).image {
            return foundImage.size.height
        } else {
            return 0
        }
    }
}

