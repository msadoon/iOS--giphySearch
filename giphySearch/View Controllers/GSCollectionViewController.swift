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
    weak var delegate:UpdateCollectionViewDelegate?
    let searchTerm = "Cats"
    
    lazy var fetchedResultsController: NSFetchedResultsController<GSGif> = {
        let fetchRequest: NSFetchRequest<GSGif> = GSGif.fetchRequest()
        let rankSort = NSSortDescriptor(key: #keyPath(GSGif.rank), ascending: false)
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
        
        fetchedResultsController.delegate = self;
        
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
//        if let layout = collectionView?.collectionViewLayout as? GSCollectionViewLayout {
//            layout.delegate = self
//        }
        collectionView?.backgroundColor = .clear
        collectionView?.contentInset = UIEdgeInsets(top: 23, left: 16, bottom: 10, right: 16)
    }
    
    private func returnArrayOfIndexPathsBetweenTwoDistantRowsInSameSection(beginIndexPath: IndexPath, endIndexPath: IndexPath, section: Int) -> [IndexPath] {
        
        let minRow:Int = (beginIndexPath.row >= endIndexPath.row) ? endIndexPath.row : beginIndexPath.row
        let maxRow:Int = (beginIndexPath.row <= endIndexPath.row) ? endIndexPath.row : beginIndexPath.row
        
        let differenceInNumberOfRows = maxRow - minRow
        
        var arrayOfIndexPaths:[IndexPath] = []
        
        for value in minRow...minRow + differenceInNumberOfRows {
            arrayOfIndexPaths.append(IndexPath(row: value, section: section))
        }
        
        return arrayOfIndexPaths
        
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
        
        let foundGif:GSGif = fetchedResultsController.object(at: indexPath)
        cell.imageView.animatedImage = foundGif.image
        cell.rankLabel.text = "\(foundGif.rank)"
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSizeWidth = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right + 10))
        let itemSizeHeight = FLAnimatedImage.size(forImage: fetchedResultsController.object(at: indexPath).image).height + 20 // + 20 for rank label
        return CGSize(width: itemSizeWidth, height: itemSizeHeight)
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 didSelectItemAt indexPath: IndexPath) {
        
        guard let _:GSGifCollectionViewCell = self.collectionView?.cellForItem(at: indexPath) as? GSGifCollectionViewCell,
              let gifDetailVC = storyboard?.instantiateViewController(withIdentifier: "GSDetailViewControllerID") as? GSDetailViewController else {
            return
        }
        
        selectedIndexPath = indexPath
        gifDetailVC.detailGif = fetchedResultsController.object(at: indexPath)
        self.delegate = gifDetailVC
        self.navigationController?.pushViewController(gifDetailVC, animated: true)
    }
    
}

//MARK: UpdateCollectionViewDelegate

extension GSCollectionViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        func updateCollectionView() {
            if let foundOldIndexPath:IndexPath = indexPath, let foundNewIndexPath:IndexPath = newIndexPath {
                if foundOldIndexPath.section == foundNewIndexPath.section {
                    let arrayToUpdate = returnArrayOfIndexPathsBetweenTwoDistantRowsInSameSection(beginIndexPath: foundOldIndexPath, endIndexPath: foundNewIndexPath, section: foundNewIndexPath.section)
                    selectedIndexPath = newIndexPath
                    DispatchQueue.main.async {
                        if foundNewIndexPath.row > foundOldIndexPath.row {
                            self.collectionView?.scrollToItem(at: foundNewIndexPath, at: UICollectionViewScrollPosition.top, animated: true)
                        } else if foundNewIndexPath.row < foundOldIndexPath.row {
                            self.collectionView?.scrollToItem(at: foundNewIndexPath, at: UICollectionViewScrollPosition.bottom, animated: true)
                        }
                        
                        self.collectionView?.reloadItems(at: arrayToUpdate)
                        self.delegate?.closeDetailViewAfterCollectionViewUpdate()
                    }
                }
            }
        }
        
        switch type {
        case .move:
            updateCollectionView()
        case .update:
            updateCollectionView()
        default:
            self.delegate?.closeDetailViewAfterCollectionViewUpdate()
            break
        }
        

    }
    
}


