//
//  GSTransitionCustomAnimator.swift
//  giphySearch
//
//  Created by Mubarak Sadoon on 2018-06-06.
//  Copyright © 2018 msadoon. All rights reserved.
//

//CREDIT: Tutorial here http://www.stefanovettor.com/2015/12/25/uicollectionview-custom-transition-pop-in-and-out/ used to implement custom transition.

import UIKit

class GSTransitionCustomAnimator:NSObject, UIViewControllerAnimatedTransitioning {
    
    private let transitionType:UINavigationControllerOperation
    private let transitionDuration:TimeInterval
    private let selectedIndexPath:IndexPath
    
    init(operation: UINavigationControllerOperation, indexPath: IndexPath) {
        self.transitionType = operation
        self.transitionDuration = 0.4
        self.selectedIndexPath = indexPath
    }
    
    init(operation: UINavigationControllerOperation, andDuration duration: TimeInterval, indexPath: IndexPath) {
        self.transitionType = operation
        self.transitionDuration = duration
        self.selectedIndexPath = indexPath
    }
    
    
    //MARK: UIViewAnimatedTransitioning delegate methods
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionDuration
    }
    
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        if transitionType == UINavigationControllerOperation.push {
            performZoomInTransition(transitionContext: transitionContext, forCellAtIndexPath: selectedIndexPath)
        } else if transitionType == UINavigationControllerOperation.pop {
            performZoomOutTransition(transitionContext: transitionContext, forCellAtIndexPath: selectedIndexPath)
        }
    }
    
    func performZoomInTransition(transitionContext:UIViewControllerContextTransitioning, forCellAtIndexPath:IndexPath) {
        
        guard let toView = transitionContext.view(forKey: UITransitionContextViewKey.to) else {
            //not possible to perform transition because the view to transition to is not available
            return
        }
        
        guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? UICollectionViewController,
            let fromCollectionView = fromViewController.collectionView,
            let currentCell = fromCollectionView.cellForItem(at: forCellAtIndexPath) else {
                //Cannot perform animated transition to destination view but can still perform transition without animation
                transitionContext.containerView.addSubview(toView)
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                return
        }
        
        transitionContext.containerView.addSubview(toView)
        
        let screenshotToView = UIImageView(image: toView.screenshot)
        screenshotToView.frame = currentCell.frame
        //Really Important as the snapshot is taken from the cell, we need to convert it to the coordinate space of the containerview (becuase it does all the animating.)
        let containerCoordsOfToView = fromCollectionView.convert(screenshotToView.frame.origin, to: transitionContext.containerView)
        screenshotToView.frame.origin = containerCoordsOfToView
        
        
        //From/To view screenshots overlap...so its okay they have the same frame.
        let screenshotFromView = UIImageView(image: currentCell.screenshot)
        screenshotFromView.frame = screenshotToView.frame
        
        //Add screenshots to transition container to set-up the animation
        transitionContext.containerView.addSubview(screenshotToView)
        transitionContext.containerView.addSubview(screenshotFromView)
        
        //Set views initial states
        toView.isHidden = true
        screenshotToView.isHidden = true
        
        //Delay to guarantee smooth effects - because toView is behind fromView in the heirarchy, this shouldnt matter, but author advised to put the timer here so there is no flicker.
        
        let when = DispatchTime.now() + 0.08
        DispatchQueue.main.asyncAfter(deadline: when) {
            screenshotToView.isHidden = false;
        }
        screenshotFromView.alpha = 0.0
        UIView.animate(withDuration: transitionDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: [], animations: {
            
            screenshotFromView.alpha = 0.0
            screenshotToView.frame = UIScreen.main.bounds
            screenshotToView.frame.origin = CGPoint(x: 0, y: 0)
            screenshotFromView.frame = screenshotToView.frame
            
        }) { _ in
            
            screenshotToView.removeFromSuperview()
            screenshotFromView.removeFromSuperview()
            toView.isHidden = false
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            
        }
    }
    
    func performZoomOutTransition(transitionContext:UIViewControllerContextTransitioning, forCellAtIndexPath:IndexPath) {
        
        guard let toView:UIView = transitionContext.view(forKey: UITransitionContextViewKey.to) else {
            //cannot do transition as retrieving the view to transition to failed.
            return
        }
        
        guard let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? UICollectionViewController,
            let toCollectionView = toViewController.collectionView,
            let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let fromView = fromViewController.view,
            let currentCell = toCollectionView.cellForItem(at: forCellAtIndexPath) else {
                
                //failed to get all the elements of the transition back to the collection view. So its possible to complete however, there will no animation.
                transitionContext.containerView.addSubview(toView)
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                return
        }
        
        //Add destination view to the container view
        transitionContext.containerView.addSubview(toView)
        
        //Prepare the screenshot of the source view for animation
        let screenshotFromView = UIImageView(image: fromView.screenshot)
        screenshotFromView.frame = fromView.frame
        
        //Prepare the screenshot of the destination view for animation
        let screenshotToView = UIImageView(image: currentCell.screenshot)
        screenshotToView.frame = screenshotFromView.frame
        
        //Add screenshots to transition container to set-up the animation
        transitionContext.containerView.addSubview(screenshotToView)
        transitionContext.containerView.insertSubview(screenshotFromView, belowSubview: screenshotToView)
        
        //set views initial states
        screenshotToView.alpha = 0.0
        fromView.isHidden = true
        currentCell.isHidden = true
        
        //convert the cell's frame to the coordinate space of the containerView using the collectionview as the frame's superview frame.
        let containerCoord = toCollectionView.convert(currentCell.frame.origin, to: transitionContext.containerView)
        
        UIView.animate(withDuration: transitionDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: [], animations: {
            
            screenshotToView.alpha = 1.0
            screenshotFromView.frame = currentCell.frame
            screenshotFromView.frame.origin = containerCoord
            screenshotToView.frame = screenshotFromView.frame
            
        }) { _ in
            
            currentCell.isHidden = false
            screenshotFromView.removeFromSuperview()
            screenshotToView.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            
        }
    }
}
