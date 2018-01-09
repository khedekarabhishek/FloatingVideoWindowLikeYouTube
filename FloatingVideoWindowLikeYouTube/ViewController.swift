//
//  ViewController.swift
//  FloatingVideoWindowLikeYouTube
//
//  Created by Abhishek Khedekar on 09/01/18.
//  Copyright © 2018 Abhishek Khedekar. All rights reserved.
//

import UIKit

// https://stackoverflow.com/questions/24092414/ios-floating-video-window-like-youtube-app

class ViewController: UIViewController {

    @IBOutlet weak var tallMpContainer: UIView!
    @IBOutlet weak var mpContainer: UIView!
    
    var swipeDown: UISwipeGestureRecognizer?
    var swipeUp: UISwipeGestureRecognizer?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipeDownAction))
        
        swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipeUpAction))
        
        swipeDown?.direction = .down
        swipeUp?.direction = .up
        
        self.mpContainer.addGestureRecognizer(swipeDown!)
        self.mpContainer.addGestureRecognizer(swipeUp!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @objc func swipeDownAction() {
        minimizeWindow(minimized: true, animated: true)
    }
    
    @objc func swipeUpAction() {
        minimizeWindow(minimized: false, animated: true)
    }
    
    func isMinimized() -> Bool {
        return CGFloat((self.tallMpContainer?.frame.origin.y)!) > CGFloat(20)
    }
    
    func minimizeWindow(minimized: Bool, animated: Bool) {
        if isMinimized() == minimized {
            return
        }
        
        var tallContainerFrame: CGRect
        var containerFrame: CGRect
        
        var tallContainerAlpha: CGFloat
        
        if minimized == true {
            
            let mpWidth: CGFloat = 160
            let mpHeight: CGFloat = 90
            
            let x: CGFloat = 320-mpWidth
            let y: CGFloat = self.view.bounds.size.height - mpHeight;
            
            tallContainerFrame = CGRect(x: x, y: y, width: 320, height: self.view.bounds.size.height)
            containerFrame = CGRect(x: x, y: y, width: mpWidth, height: mpHeight)
            tallContainerAlpha = 0.0
            
        } else {
            
            tallContainerFrame = self.view.bounds
            containerFrame = CGRect(x: 0, y: 0, width: 320, height: 180)
            tallContainerAlpha = 1.0
            
        }
        
        let duration: TimeInterval = (animated) ? 0.5 : 0.0
        UIView.animate(withDuration: duration, animations: {
            self.tallMpContainer.frame = tallContainerFrame
            self.mpContainer.frame = containerFrame
            self.tallMpContainer.alpha = tallContainerAlpha
        })
    }

    

}

