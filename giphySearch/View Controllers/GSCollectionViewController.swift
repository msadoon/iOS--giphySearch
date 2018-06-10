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


enum HighlighterColors {
    static let yellow = UIColor(red: 241.0/255.0, green: 244.0/255.0, blue: 20.0/255.0, alpha: 1.0)
    static let green = UIColor(red: 117.0/255.0, green: 249.0/255.0, blue: 75.0/255.0, alpha: 1.0)
    static let orange = UIColor(red: 251.0/255.0, green: 78.0/255.0, blue: 9.0/255.0, alpha: 1.0)
    static let pink = UIColor(red: 251.0/255.0, green: 0.0/255.0, blue: 136.0/255.0, alpha: 1.0)
    static let purple = UIColor(red: 89.0/255.0, green: 0.0/255.0, blue: 198.0/255.0, alpha: 1.0)
}

protocol LoadMoreGifsProtocol:class {
    func loadMoreGifs()
}

class GSCollectionViewController: UICollectionViewController {
    
    var selectedIndexPath:IndexPath? = nil
    weak var delegate:UpdateCollectionViewDelegate?
    let searchTerm = "Cats"
    private var stillLoading:Bool = false
    private var localDictOfAnimatedImages:[Int:GSLocalCacheObject] = [:]
    private var updateFLAnimatedImagesReturnedFromDataManager: Bool = true
    private var dictionaryOfIndexPathsWithoutFLAnimatedImages:[Int: URL] = [:]
    private var dateUsedForSorting:Date = Date()
    private var lastTimeIntervalsForCache:[TimeInterval] = []
    private var delayToWaitForScrolling:Double = 2.0
    private var readyToLoadViewableCells:Bool = false
    private var allIndexPathsToBeFetched:[IndexPath] = []
    
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
            cacheName: nil
        )
        
        fetchedResultsController.delegate = self;
        
        return fetchedResultsController
    }()
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("Memory Warning!!")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.delegate = self
        self.setupCollectionViewAndLayout()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onDidReceiveData(_:)), name: .newGifsDownloaded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onDidReceiveDataForVisibleCells(_:)), name: .convertedAllImages, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .newGifsDownloaded, object: nil)
    }
    
    //MARK: Helper Methods
    
    private func ifCellStillVisibleUpdateWithAnimatedImage(indexPath:IndexPath, convertedImage: FLAnimatedImage) {
        
        if let value = self.collectionView?.indexPathsForVisibleItems.contains(indexPath), let cellForIndexPath:GSGifCollectionViewCell = self.collectionView?.cellForItem(at: indexPath) as? GSGifCollectionViewCell {
            if value {
                cellForIndexPath.imageView.animatedImage = convertedImage
                cellForIndexPath.setNeedsLayout()
            }
        }
    }
    
    private func randomColor() -> UIColor {
        let randomColorNum = arc4random_uniform(5) + 1
        
        var colorToReturn:UIColor = UIColor.black
        
        switch randomColorNum {
        case 1: colorToReturn = HighlighterColors.yellow
        case 2: colorToReturn = HighlighterColors.green
        case 3: colorToReturn = HighlighterColors.orange
        case 4: colorToReturn = HighlighterColors.pink
        default: colorToReturn = HighlighterColors.purple
        }
        
        return colorToReturn
    }
    
    private func setupCollectionViewAndLayout() {
        //        if let layout = collectionView?.collectionViewLayout as? GSCollectionViewLayout {
        //            layout.delegate = self
        //        }
        collectionView?.prefetchDataSource = self
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
    
    private func removeOldestImagesFromLocalDictOfImages() {
        
        lastTimeIntervalsForCache = lastTimeIntervalsForCache.sorted(by: {$0 > $1})
        
        var prunedTimeIntervalForCache:[TimeInterval] = []
        
        for index in 0..<GSDataManager.sharedInstance.getCurrentLimit*2 {
            if index < lastTimeIntervalsForCache.count {
                prunedTimeIntervalForCache.append(lastTimeIntervalsForCache[index])
            }
        }
        
        lastTimeIntervalsForCache = prunedTimeIntervalForCache
        
        for key in localDictOfAnimatedImages.keys {
            if let foundValue:GSLocalCacheObject = localDictOfAnimatedImages[key] {
                if !lastTimeIntervalsForCache.contains(foundValue.timeStamp) {
                    localDictOfAnimatedImages[key]?.image = nil
                }
            }
        }
        
        //print("number of keys: ", localDictOfAnimatedImages.keys.count)
        
        var counter = 0
        for value in localDictOfAnimatedImages.values {
            if value.image == nil { counter += 1 }
        }
        
        //print("number of nil values: ", counter)
        
    }
    
    
    private func addNewItemsToLocalDictOfImages(newImagesDict:[Int: FLAnimatedImage]) {
        //For every new item downloaded I want to add it to the local dict by replacing the lowest index in that dict.
        
        removeOldestImagesFromLocalDictOfImages()
        
        for key in newImagesDict.keys {
            if let foundImage:FLAnimatedImage = newImagesDict[key] {
                let newTime = abs(dateUsedForSorting.timeIntervalSinceNow)
                lastTimeIntervalsForCache.append(newTime)
                localDictOfAnimatedImages[key] = GSLocalCacheObject(newTime,image: foundImage)
            }
        }
        
    }
    
    private func addNewIndexPathsToBeUpdated(indexPaths:[IndexPath]) {
        
        var tempIndexPathsToBeFetched:[IndexPath] = []
        
        if allIndexPathsToBeFetched.count > GSDataManager.sharedInstance.getCurrentLimit {
            let startLimit = (allIndexPathsToBeFetched.count-GSDataManager.sharedInstance.getCurrentLimit)
            tempIndexPathsToBeFetched.append(contentsOf:allIndexPathsToBeFetched[startLimit..<allIndexPathsToBeFetched.count])
            allIndexPathsToBeFetched = tempIndexPathsToBeFetched
        }
        
        for indexPath in indexPaths {
            if (!allIndexPathsToBeFetched.contains(indexPath) &&
                ((localDictOfAnimatedImages.keys.contains(indexPath.row) && ((localDictOfAnimatedImages[indexPath.row])?.image == nil)) ||
                    (!localDictOfAnimatedImages.keys.contains(indexPath.row)))) {
                allIndexPathsToBeFetched.append(indexPath)
            }
        }
        
        print("allIndexPathsToBeFetched ", allIndexPathsToBeFetched.count)
        
    }
    
    private func updateDateIndexPathsToBeFetched() {
        if let foundAllVisibleIndexPaths:[IndexPath] = self.collectionView?.indexPathsForVisibleItems {
            addNewIndexPathsToBeUpdated(indexPaths: foundAllVisibleIndexPaths)
        }
    }
    
    private func getNewFLAnimatedImagesForVisibleCells(indexPaths:[IndexPath]) {
        
        var numberOfIndexPathsAdded = 0
        
        for indexPath in indexPaths {
            if let foundSection = self.fetchedResultsController.sections?[0] {
                
                if foundSection.numberOfObjects > indexPath.row {
                    
                    let gifObject:GSGif = self.fetchedResultsController.object(at: indexPath)
                    
                    gifObject.managedObjectContext?.perform {
                        //async will return at any time and in any order
                        if let url:URL = gifObject.url {
                            self.dictionaryOfIndexPathsWithoutFLAnimatedImages[indexPath.row] = url
                            //print("\(indexPath.row)" + " \(url)")
                            numberOfIndexPathsAdded += 1
                            if ((self.updateFLAnimatedImagesReturnedFromDataManager) &&
                                (self.dictionaryOfIndexPathsWithoutFLAnimatedImages.keys.count >= 1) && (numberOfIndexPathsAdded == indexPaths.count)) {
                                self.updateFLAnimatedImagesReturnedFromDataManager = false
                                
                                print("call made to get visible indexpath flanimatedimages. keys to get: ", self.dictionaryOfIndexPathsWithoutFLAnimatedImages.keys)
                                
                                GSDataManager.sharedInstance.convertImagesForThisData(allImageData:self.dictionaryOfIndexPathsWithoutFLAnimatedImages)
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
            
        }
        
        
    }
    
    //MARK: Notification Methods
    
    @objc func onDidReceiveDataForVisibleCells(_ notification: NSNotification) {
        
        DispatchQueue.main.async {
            self.updateFLAnimatedImagesReturnedFromDataManager = true
            self.dictionaryOfIndexPathsWithoutFLAnimatedImages.removeAll()
            self.allIndexPathsToBeFetched.removeAll()
            
            if let foundDict:[Int:FLAnimatedImage] = notification.object as? [Int:FLAnimatedImage] {
                self.addNewItemsToLocalDictOfImages(newImagesDict:foundDict)
                for key in foundDict.keys {
                    if let foundImageFromLocalArray:FLAnimatedImage = self.localDictOfAnimatedImages[key]?.image {
                        self.ifCellStillVisibleUpdateWithAnimatedImage(indexPath:IndexPath(row: key, section: 0), convertedImage: foundImageFromLocalArray)
                    }
                }
            }
            
            
        }
        
    }
    
    @objc func onDidReceiveData(_ notification: NSNotification) {
        
        GSDataManager.sharedInstance.coreDataStack.storeContainer.performBackgroundTask {
            context in
            do {
                
                try self.fetchedResultsController.performFetch()
                
                DispatchQueue.main.async {
                    if let foundDict:[Int:FLAnimatedImage] = notification.object as? [Int:FLAnimatedImage] {
                        self.addNewItemsToLocalDictOfImages(newImagesDict:foundDict)
                    }
                    
                    self.stillLoading = false
                    self.collectionView?.collectionViewLayout.invalidateLayout()
                    self.collectionView?.reloadData()
                }
                
            } catch let error as NSError {
                print("Oops! Error while fetching: " + error.description)
            }
        }
        
    }
    
}

//MARK: UIScrollView Delegate Methods

extension GSCollectionViewController {
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                           willDecelerate decelerate: Bool) {
        readyToLoadViewableCells = true
        DispatchQueue.main.asyncAfter(deadline: .now() + delayToWaitForScrolling, execute: {
            if self.readyToLoadViewableCells {
                self.getNewFLAnimatedImagesForVisibleCells(indexPaths:self.allIndexPathsToBeFetched)
            }
            
        })
        updateDateIndexPathsToBeFetched()
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        readyToLoadViewableCells = true
        
        updateDateIndexPathsToBeFetched()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delayToWaitForScrolling, execute: {
            
            if (self.readyToLoadViewableCells) {
                self.getNewFLAnimatedImagesForVisibleCells(indexPaths:self.allIndexPathsToBeFetched)
            }
            
        })
        
    }
    
    override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        readyToLoadViewableCells = true
        DispatchQueue.main.asyncAfter(deadline: .now() + delayToWaitForScrolling, execute: {
            if self.readyToLoadViewableCells {
                self.getNewFLAnimatedImagesForVisibleCells(indexPaths:self.allIndexPathsToBeFetched)
            }
        })
        updateDateIndexPathsToBeFetched()
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        readyToLoadViewableCells = false
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
        
        //only adds images for cells with GIFS in local array
        
        cell.imageView.backgroundColor = randomColor()
        
        let gifObject:GSGif = self.fetchedResultsController.object(at: indexPath)
        if let foundImageForIndexPath:FLAnimatedImage = localDictOfAnimatedImages[indexPath.row]?.image {
            cell.image = foundImageForIndexPath
            cell.rank = Int(gifObject.rank)
            cell.rank = indexPath.row
        } else {
            cell.image = nil
            cell.rank = Int(gifObject.rank)
            cell.rank = indexPath.row
            
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        let itemSizeWidth = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right + 10))
        let itemSizeHeight = 200 + 20 // + 20 for rank label FIXED because making a call to fetchObject on fetchResultsController too expensive here. This is call before cellForItemAt:
        return CGSize(width: itemSizeWidth, height: CGFloat(itemSizeHeight))
        
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 didSelectItemAt indexPath: IndexPath) {
        
        guard let cellFound:GSGifCollectionViewCell = self.collectionView?.cellForItem(at: indexPath) as? GSGifCollectionViewCell,
            let gifDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "GSDetailViewControllerID") as? GSDetailViewController else {
                return
        }
        
        
        let gifObject:GSGif = self.fetchedResultsController.object(at: indexPath)
        
        self.selectedIndexPath = indexPath
        
        gifDetailVC.detailGif = gifObject
        gifDetailVC.colorForDetailPage = cellFound.imageView.backgroundColor
        self.delegate = gifDetailVC
        self.navigationController?.pushViewController(gifDetailVC, animated: true)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if (kind == UICollectionElementKindSectionHeader) {
            let headerView:GSSearchCollectionReusableView =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "SearchBarInHeader", for: indexPath) as! GSSearchCollectionReusableView
            
            return headerView
        } else if (kind == UICollectionElementKindSectionFooter) {
            let footerView:GSLoadingCollectionReusableView =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "LoadingViewInFooter", for: indexPath) as! GSLoadingCollectionReusableView
            footerView.delegate = self
            if !stillLoading {
                footerView.loadingImageView.isHidden = true
                footerView.loadingButton.isHidden = false
            }
            return footerView
        }
        
        return UICollectionReusableView()
        
    }
    
}

//MARK: UICollectionViewDataSourcePretching

extension GSCollectionViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        // Begin asynchronously fetching data for the requested index paths.
        
        self.addNewIndexPathsToBeUpdated(indexPaths: indexPaths)
        
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

//MARK: LoadMoreGifsDelegate

extension GSCollectionViewController: LoadMoreGifsProtocol {
    
    func loadMoreGifs() {
        stillLoading = GSDataManager.sharedInstance.getAllGiphJSONData(searchTerm: searchTerm)
    }
    
}

//MARK: SearchBar Delegate

extension GSCollectionViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //        if(!()){
        //reload your data source if necessary
        self.collectionView?.reloadData()
        //        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
}


