//
//  GSDetailViewController.swift
//  giphySearch
//
//  Created by Mubarak Sadoon on 2018-06-06.
//  Copyright © 2018 msadoon. All rights reserved.
//

import UIKit

class GSDetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var webButton: UIButton!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var rankUpButton: UIButton!
    @IBOutlet weak var rankDownButton: UIButton!
    
    var mainGif:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.setHidesBackButton(true, animated: true)
        let customCloseButtonForNavbar = customCloseButton()
        let closeNavigationButton = UIBarButtonItem(customView: customCloseButtonForNavbar)
        self.navigationItem.rightBarButtonItem = closeNavigationButton
        
        if let foundMainImage = mainGif {
            imageView.image = foundMainImage
            rankUpButton.isEnabled = true
            rankDownButton.isEnabled = true
            webButton.isEnabled = true
        } else {
            imageView.image = UIImage(named: "placeholder.png")
            rankUpButton.isEnabled = false
            rankDownButton.isEnabled = false
            webButton.isEnabled = false
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: - Helper
    @objc func close() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func customCloseButton() -> UIView {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "close.png"), for: .normal)
        button.addTarget(self, action: #selector(close), for: .touchUpInside)

        return button
    }
    
    func getBackPopAnimation() -> CASpringAnimation {
        let popAnimation:CASpringAnimation = CASpringAnimation(keyPath: "transform.scale")
        popAnimation.fromValue = 1
        popAnimation.toValue = 1.2
        return popAnimation
    }
    
    //MARK: - IBActions
    
    @IBAction func visitOnTheWeb(_ sender: Any) {
        webButton.layer.add(getBackPopAnimation(), forKey:"website")
        
    }
    
    @IBAction func rankUp(_ sender: Any) {
        rankUpButton.layer.add(getBackPopAnimation(), forKey:"upVote")
        
    }
    
    @IBAction func rankDown(_ sender: Any) {
        rankDownButton.layer.add(getBackPopAnimation(), forKey:"upVote")

    }
}
