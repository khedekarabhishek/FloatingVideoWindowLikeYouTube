//
//  VideoDetailViewController.swift
//  FloatingVideoWindowLikeYouTube
//
//  Created by Abhishek Khedekar on 21/01/18.
//  Copyright © 2018 Abhishek Khedekar. All rights reserved.
//

import UIKit
import Foundation
import MediaPlayer
import AVKit

class VideoDetailViewController: DraggableFloatingViewController {
    
    var moviePlayer:  AVPlayerViewController!
    private let loadingSpinner = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        moviePlayer = AVPlayerViewController()
        self.setupViews(withVideoView: moviePlayer.view, videoViewHeight: 160)
        setupMoviePlayer()
        addObserver(selector: #selector(onOrientationChanged), name: NSNotification.Name.UIDeviceOrientationDidChange.rawValue)
        
        // design controller view
        let minimizeButton = UIButton()
        minimizeButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        minimizeButton.setImage(UIImage(named: "DownArrow"), for: .normal)
        minimizeButton.addTarget(self, action: #selector(onTapMinimizeButton), for: .touchUpInside)
        self.controllerView?.addSubview(minimizeButton)
        let testControl = UILabel()
        testControl.frame = CGRect(x: 100, y: 5, width: 150, height: 40)
        testControl.text = "controller view"
        testControl.textColor = .white
        self.controllerView?.addSubview(testControl)
        
        // design body view
        self.bodyView?.backgroundColor = .white
        self.bodyView?.layer.borderColor = UIColor.red.cgColor
        self.bodyView?.layer.borderWidth = 10.0
        let testView = UILabel()
        testView.frame = CGRect(x: 20, y: 10, width: 100, height: 40)
        testView.text = "body view"
        testView.textColor = .red
        self.bodyView?.addSubview(testView)
        
        // design message view
        self.messageView?.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        loadingSpinner.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        
        if let messageViewCenter = self.messageView?.center {
            loadingSpinner.center = messageViewCenter
        }
        loadingSpinner.hidesWhenStopped = false
        loadingSpinner.activityIndicatorViewStyle = .white
        self.messageView?.addSubview(loadingSpinner)
    }
    
    override func didDisappear() {
        moviePlayer.player?.play()
    }
    
    override func didReAppear() {
        setupMoviePlayer()
    }
        
    func onTapButton() {
        print("onTapButton")
    }
    
    override func showMessageView() {
        loadingSpinner.startAnimating()
        super.showMessageView()
    }
    override func hideMessageView() {
        super.hideMessageView()
        loadingSpinner.stopAnimating()
    }
    
    override func didFullExpandByGesture() {
        self.isStatusBarHiddenByCustom = true
        self.preferredStatusBarAnimation = .none
        showVideoControl()
    }
    override func didExpand() {
        print("didExpand")
        self.isStatusBarHiddenByCustom = true
        self.preferredStatusBarAnimation = .none

        showVideoControl()
    }
    override func didMinimize() {
        print("didMinimized")
        hideVideoControl()
    }
    
    override func didStartMinimizeGesture() {
        print("didStartMinimizeGesture")
        self.isStatusBarHiddenByCustom = false
        self.preferredStatusBarAnimation = .none

    }
    
    
    @objc func onTapMinimizeButton() {
        self.isStatusBarHiddenByCustom = false
        self.preferredStatusBarAnimation = .none
        self.minimizeView()
    }
    
    // --------------------------------------------------------------------------------------------------
    
    func setupMoviePlayer() {
        
        let videoURL = NSURL.fileURL(withPath: Bundle.main.path(forResource: "test", ofType: "mp4")!)
        let player = AVPlayer(url: videoURL)
        moviePlayer.player = player
        
        // play
        let seconds = 1.0
        let delay = seconds * Double(NSEC_PER_SEC)// nanoseconds per seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.moviePlayer.player?.play()
        }
        
        // for movie loop
        NotificationCenter.default.addObserver(self, selector: #selector(moviePlayBackDidFinish),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: moviePlayer)
    }
    
    // movie loop
    @objc func moviePlayBackDidFinish(notification: NSNotification) {
        print("moviePlayBackDidFinish:")
        moviePlayer.player?.play()
        removeObserver(aName: NSNotification.Name.AVPlayerItemDidPlayToEndTime.rawValue)
    }
    
    
    // ----------------------------- events -----------------------------------------------
    
    // MARK: Orientation
    @objc func onOrientationChanged() {
        let orientation: UIInterfaceOrientation = getOrientation()
        
        switch orientation {
            
        case .portrait, .portraitUpsideDown:
            print("portrait")
            exitFullScreen()
            
        case .landscapeLeft, .landscapeRight:
            print("landscape")
            goFullScreen()
            
        default:
            print("no action for this orientation:" + orientation.rawValue.description)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    // --------------------------------- util ------------------------------------------
    
    // MARK: FullScreen Method
    func isFullScreen() -> Bool {
        return moviePlayer.contentOverlayView?.bounds == UIScreen.main.bounds
    }
    func goFullScreen() {
        if !isFullScreen() {
            moviePlayer.contentOverlayView?.bounds = UIScreen.main.bounds
            addObserver(selector: #selector(willExitFullScreen), name: "AVMoviePlayerWillExitFullscreen")
        }
    }
    func exitFullScreen() {
        if isFullScreen() {
            moviePlayer.contentOverlayView?.bounds = CGRect.zero
        }
    }
    @objc func willExitFullScreen() {
        if isLandscape() {
            setOrientation(orientation: .portrait)
        }
        removeObserver(aName: "AVMoviePlayerWillExitFullscreen")
    }
    
    
    // FIXIT: Don't work
    func showVideoControl() {
        moviePlayer.showsPlaybackControls = true
    }
    
    // FIXIT: Don't work
    func hideVideoControl() {
        moviePlayer.showsPlaybackControls = false
    }
    
    //-----------------------------------------------------------------------------------
    
    func getOrientation() -> UIInterfaceOrientation {
        return UIApplication.shared.statusBarOrientation
    }
    
    func setOrientation(orientation: UIInterfaceOrientation) {
        let orientationNum: NSNumber = NSNumber(value: orientation.rawValue)
        UIDevice.current.setValue(orientationNum, forKey: "orientation")
    }
    
    func addObserver(selector aSelector: Selector, name aName: String) {
        NotificationCenter.default.addObserver(self, selector: aSelector, name:NSNotification.Name(aName), object: nil)
    }
    
    func removeObserver(aName: String) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(aName), object: nil)
    }
    
    func isLandscape() -> Bool {
        if (UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation)) {
            return true
        }
        else {
            return false
        }
    }
}
