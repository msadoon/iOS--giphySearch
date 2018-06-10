//
//  GSDetailViewController.swift
//  giphySearch
//
//  Created by Mubarak Sadoon on 2018-06-06.
//  Copyright © 2018 msadoon. All rights reserved.
//

import UIKit
import FLAnimatedImage

protocol UpdateCollectionViewDelegate:class {
    func closeDetailViewAfterCollectionViewUpdate()
}

class GSDetailViewController: UIViewController {

    @IBOutlet weak var imageView: FLAnimatedImageView!
    @IBOutlet weak var webButton: UIButton!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var rankUpButton: UIButton!
    @IBOutlet weak var rankDownButton: UIButton!
    @IBOutlet weak var rankButtonContainer: UIView!
    
    var detailGif:GSGif?
    private var websiteURL:URL?
    private var rankBeforeSave:Int = 0
    var colorForDetailPage:UIColor?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.navigationItem.setHidesBackButton(true, animated: true)
        let customCloseButtonForNavbar = customCloseButton()
        let closeNavigationButton = UIBarButtonItem(customView: customCloseButtonForNavbar)
        self.navigationItem.rightBarButtonItem = closeNavigationButton
        
        self.setupBackground()
        //self.setupGifDetails()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //MARK: - Helper
    
    private func setupBackground() {
        if let foundColorForDetailPage:UIColor = colorForDetailPage {
            self.view.backgroundColor = foundColorForDetailPage
            self.imageView.backgroundColor = foundColorForDetailPage
            self.rankButtonContainer.backgroundColor = foundColorForDetailPage
        }
    }
    
//    private func setupGifDetails() {
//        if let foundMainImageData:Data = detailGif?.image as Data?,
//            let foundMainImage:FLAnimatedImage = FLAnimatedImage(gifData: foundMainImageData),
//           let foundTitle = detailGif?.name,
//           let foundRank = detailGif?.rank,
//           let foundWebsite = detailGif?.url {
//            imageView.animatedImage = foundMainImage
//            rankLabel.text = "\(foundRank)"
//            rankBeforeSave = Int(foundRank)
//            self.navigationItem.title = foundTitle
//            self.websiteURL = foundWebsite
//            rankUpButton.isEnabled = true
//            rankDownButton.isEnabled = true
//            webButton.isEnabled = true
//        } else {
//            imageView.image = UIImage(named: "placeholder.png")
//            rankLabel.text = "0"
//            rankBeforeSave = 0
//            self.navigationItem.title = "unknown"
//            self.websiteURL = nil
//            rankUpButton.isEnabled = false
//            rankDownButton.isEnabled = false
//            webButton.isEnabled = false
//        }
//    }
    
    @objc func close() {
        if let foundDetailGif:GSGif = detailGif {
            GSDataManager.sharedInstance.updateGifRank(gif: foundDetailGif, newRank:rankBeforeSave)
        }
        
        //delegate?.reloadAfterNewRank()
        
//        if let foundGSCollectionViewController =  as? GSCollectionViewController {
//            foundGSCollectionViewController.collectionView?.updateCollectionView()
//        }
    }
    
    func customCloseButton() -> UIView {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "close.png"), for: .normal)
        button.addTarget(self, action: #selector(close), for: .touchUpInside)

        return button
    }
    
    private func getPopAnimation() -> CASpringAnimation {
        let popAnimation:CASpringAnimation = CASpringAnimation(keyPath: "transform.scale")
        popAnimation.fromValue = 1
        popAnimation.toValue = 1.2
        return popAnimation
    }
    
    private func updateLocalRank() {
        rankLabel.text = "\(rankBeforeSave)"
    }
    
    //MARK: - IBActions
    
    @IBAction func visitOnTheWeb(_ sender: Any) {
        webButton.layer.add(getPopAnimation(), forKey:"website")
        if let foundURL:URL = websiteURL {
            UIApplication.shared.open(foundURL, options: [:])
        }
    }
    
    @IBAction func rankUp(_ sender: Any) {
        rankUpButton.layer.add(getPopAnimation(), forKey:"upVote")
        rankBeforeSave += 1
        updateLocalRank()
    }
    
    @IBAction func rankDown(_ sender: Any) {
        rankDownButton.layer.add(getPopAnimation(), forKey:"upVote")
        rankBeforeSave -= 1
        updateLocalRank()
    }
}

extension GSDetailViewController:UpdateCollectionViewDelegate {
    func closeDetailViewAfterCollectionViewUpdate() {
        self.navigationController?.popViewController(animated: true)
    }
}

