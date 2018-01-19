//
//  DraggableFloatingViewController.swift
//  FloatingVideoWindowLikeYouTube
//
//  Created by Abhishek Khedekar on 16/01/18.
//  Copyright © 2018 Abhishek Khedekar. All rights reserved.
//


//https://github.com/entotsu/DraggableFloatingViewController

import UIKit

protocol DraggableFloatingViewControllerDelegate {
    func removeDraggableFloatingViewController()
}

enum UIPanGestureRecognizerDirection:Int {
    case UIPanGestureRecognizerDirectionUndefined
    case UIPanGestureRecognizerDirectionUp
    case UIPanGestureRecognizerDirectionDown
    case UIPanGestureRecognizerDirectionLeft
    case UIPanGestureRecognizerDirectionRight
}

class DraggableFloatingViewController: UIViewController {

    var bodyView: UIView?
    //please add controller on this
    var controllerView: UIView?
    //please add loading spiner on this
    var messageView: UIView?
    
    //local Frame storee
    var videoWrapperFrame = CGRect.zero
    var minimizedVideoFrame = CGRect.zero
    var pageWrapperFrame = CGRect.zero
    // animation Frame
    var wFrame = CGRect.zero
    var vFrame = CGRect.zero
    //local touch location
    var _touchPositionInHeaderY: CGFloat = 0.0
    var _touchPositionInHeaderX: CGFloat = 0.0
    //detecting Pan gesture Direction
    var direction = UIPanGestureRecognizerDirection(rawValue: 0)
    var tapRecognizer: UITapGestureRecognizer?
    //Creating a transparent Black layer view
    var transparentBlackSheet: UIView?
    //Just to Check wether view  is expanded or not
    var isExpandedMode = false
    var pageWrapper: UIView?
    var videoWrapper: UIView?
    //    UIButton *foldButton;
    var videoView: UIView?
    // border of mini vieo view
    var borderView: UIView?
    var maxH: CGFloat = 0.0
    var maxW: CGFloat = 0.0
    var videoHeightRatio: CGFloat = 0.0
    var finalViewOffsetY: CGFloat = 0.0
    var minimamVideoHeight: CGFloat = 0.0
    var parentView: UIView?
    var isDisplayController = false
    var hideControllerTimer: Timer?
    var isMinimizingByGesture = false
    var isAppear = false
    var isSetuped = false
    var windowFrame = CGRect.zero
    
    let finalMargin: CGFloat = 3.0
    let minimamVideoWidth: CGFloat = 140
    let flickVelocity: CGFloat = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.bodyView = UIView();
        self.controllerView = UIView()
        self.messageView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didStartMinimizeGesture() {
        UIApplication.shared.isStatusBarHidden = false
    }
    
    func show() {
        if !isSetuped {
            setup()
        }
        else {
            if !isAppear {
                reAppearWithAnimation()
            }
        }
    }
    
    func setup() {
        isSetuped = true
        print("showVideoViewControllerOnParentVC")
        // set portrait
        if UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation) {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        }
        UIApplication.shared.isStatusBarHidden = true
        getWindow().addSubview(view)
        // wait to run "viewDidLoad" before "showThisView"
        perform(#selector(self.showThisView), with: nil, afterDelay: 0.0)
        isAppear = true
    }
    
    func setupViews(withVideoView vView: UIView, videoViewHeight videoHeight: CGFloat) {
        //                 minimizeButton: (UIButton *)foldBtn
        print("setupViewsWithVideoView")
        videoView = vView
        //    foldButton = foldBtn;//control show and hide
        windowFrame = UIScreen.main.bounds
        maxH = windowFrame.size.height
        maxW = windowFrame.size.width
        let videoWidth: CGFloat = maxW
        videoHeightRatio = videoHeight / videoWidth
        minimamVideoHeight = minimamVideoWidth * videoHeightRatio
        finalViewOffsetY = maxH - minimamVideoHeight - finalMargin
        videoWrapper = UIView()
        videoWrapper.frame = CGRect(x: 0, y: 0, width: videoWidth, height: videoHeight)
        videoView.frame = videoWrapper.frame
        controllerView.frame = videoWrapper.frame
        messageView.frame = videoWrapper.frame
        pageWrapper = UIView()
        pageWrapper.frame = CGRect(x: 0, y: 0, width: maxW, height: maxH)
        videoWrapperFrame = videoWrapper.frame
        pageWrapperFrame = pageWrapper.frame
        borderView = UIView()
        borderView.clipsToBounds = true
        borderView.layer.masksToBounds = false
        borderView.layer.borderColor = UIColor.white.cgColor
        borderView.layer.borderWidth = 0.5
        //    borderView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        //    borderView.layer.shadowColor = [UIColor blackColor].CGColor;
        //    borderView.layer.shadowRadius = 1.0;
        //    borderView.layer.shadowOpacity = 1.0;
        borderView.alpha = 0
        borderView.frame = CGRect(x: videoView.frame.origin.y - 1, y: videoView.frame.origin.x - 1, width: videoView.frame.size.width + 1, height: videoView.frame.size.height + 1)
        bodyView.frame = CGRect(x: 0, y: videoHeight, width: maxW, height: maxH - videoHeight)
    }

    func getWindow() -> UIWindow {
        return UIApplication.shared.delegate?.window ?? UIWindow()
    }
    
    func showThisView() {
        // only first time, SubViews add to "self.view".
        // After animation, they move to "parentView"
        videoView.backgroundColor = UIColor.black
        videoWrapper.backgroundColor = UIColor.black
        pageWrapper.addSubview(bodyView)
        videoWrapper.addSubview(videoView)
        // move subviews from "self.view" to "parentView" after animation
        view.addSubview(pageWrapper)
        view.addSubview(videoWrapper)
        transparentBlackSheet = UIView(frame: windowFrame)
        transparentBlackSheet.backgroundColor = UIColor.black
        transparentBlackSheet.alpha = 1
        appearAnimation()
    }
}

extension DraggableFloatingViewController: UIGestureRecognizerDelegate {
    
}
