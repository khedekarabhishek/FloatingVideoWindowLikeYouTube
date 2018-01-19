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
        videoWrapper?.frame = CGRect(x: 0, y: 0, width: videoWidth, height: videoHeight)
        
        guard let vFrame = videoWrapper?.frame else {
            return
        }
        videoView?.frame = vFrame
        controllerView?.frame = vFrame
        messageView?.frame = vFrame
        pageWrapper = UIView()
        pageWrapper?.frame = CGRect(x: 0, y: 0, width: maxW, height: maxH)
        videoWrapperFrame = vFrame
        
        guard let pFrame = pageWrapper?.frame else {
            return
        }
        
        pageWrapperFrame = pFrame
        borderView = UIView()
        borderView?.clipsToBounds = true
        borderView?.layer.masksToBounds = false
        borderView?.layer.borderColor = UIColor.white.cgColor
        borderView?.layer.borderWidth = 0.5
        //    borderView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        //    borderView.layer.shadowColor = [UIColor blackColor].CGColor;
        //    borderView.layer.shadowRadius = 1.0;
        //    borderView.layer.shadowOpacity = 1.0;
        borderView?.alpha = 0
        
        guard let videoViewFrame = videoView?.frame else {
            return
        }
        borderView?.frame = CGRect(x: videoViewFrame.origin.y - 1, y: videoViewFrame.origin.x - 1, width: videoViewFrame.size.width + 1, height: videoViewFrame.size.height + 1)
        bodyView?.frame = CGRect(x: 0, y: videoHeight, width: maxW, height: maxH - videoHeight)
    }

    func getWindow() -> UIWindow {
        guard let wind = UIApplication.shared.delegate?.window else {
            return UIWindow()
        }
        if let appWindow = wind {
            return appWindow
        }
    }
    
    @objc func showThisView() {
        // only first time, SubViews add to "self.view".
        // After animation, they move to "parentView"
        videoView?.backgroundColor = UIColor.black
        videoWrapper?.backgroundColor = UIColor.black
        
        if let bView = bodyView {
            pageWrapper?.addSubview(bView)
        }
        if let vView = videoView {
            videoWrapper?.addSubview(vView)
        }
        // move subviews from "self.view" to "parentView" after animation
        if let pWrapp = pageWrapper {
            view.addSubview(pWrapp)
        }
        if let vWrapp = videoWrapper {
            view.addSubview(vWrapp)
        }
        transparentBlackSheet = UIView(frame: windowFrame)
        transparentBlackSheet?.backgroundColor = UIColor.black
        transparentBlackSheet?.alpha = 1
        appearAnimation()
    }
    
    func reAppearWithAnimation() {
        borderView?.alpha = 0
        transparentBlackSheet?.alpha = 0
        videoWrapper?.alpha = 0
        pageWrapper?.alpha = 0
        pageWrapper?.frame = pageWrapperFrame
        videoWrapper?.frame = videoWrapperFrame
        videoView?.frame = videoWrapperFrame
        
        guard let vViewFrame = videoView?.frame else {
            return
        }
        guard let bViewFrame = bodyView?.frame else {
            return
        }
        guard let pWrappFrame = pageWrapper?.frame else {
            return
        }
        
        guard let vWrappFrame = videoWrapper?.frame else {
            return
        }
      
        
        controllerView?.frame = vViewFrame
        bodyView?.frame = CGRect(x: 0, y: vViewFrame.size.height, width:     // keep stay on bottom of videoView
            bViewFrame.size.width, height: bViewFrame.size.height)
        
        borderView?.frame = CGRect(x: vViewFrame.origin.y - 1, y: vViewFrame.origin.x - 1, width: vViewFrame.size.width + 1, height: vViewFrame.size.height + 1)
        pageWrapper?.frame = CGRect(x: windowFrame.size.width - 50, y: windowFrame.size.height - 150, width: pWrappFrame.size.width, height: pWrappFrame.size.height)
        
        guard let newpWrappFrame = pageWrapper?.frame else {
            return
        }
        //    pageWrapper.transform = CGAffineTransformMakeScale(0.2, 0.2);
        videoWrapper?.frame = CGRect(x: windowFrame.size.width - 50, y: windowFrame.size.height - 150, width: vWrappFrame.size.width, height: vWrappFrame.size.height)
        //    videoWrapper.transform = CGAffineTransformMakeScale(0.2, 0.2);

        guard let newvWrappFrame = videoWrapper?.frame else {
            return
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {() -> Void in
            //                         pageWrapper.transform = CGAffineTransformMakeScale(1.0, 1.0);
            self.pageWrapper?.alpha = 1
            self.pageWrapper?.frame = CGRect(x: self.windowFrame.origin.x, y: self.windowFrame.origin.y, width: newpWrappFrame.size.width, height: newpWrappFrame.size.height)
            //                         videoWrapper.transform = CGAffineTransformMakeScale(1.0, 1.0);
            self.videoWrapper?.alpha = 1
            self.videoWrapper?.frame = CGRect(x: self.windowFrame.origin.x, y: self.windowFrame.origin.y, width: newvWrappFrame.size.width, height: newvWrappFrame.size.height)
        }, completion: {(_ finished: Bool) -> Void in
            self.transparentBlackSheet?.alpha = 1.0
            if let gRecog = self.videoWrapper?.gestureRecognizers {
                for recognizer: UIGestureRecognizer in gRecog {
                    if (recognizer is UITapGestureRecognizer) {
                        self.videoWrapper?.removeGestureRecognizer(recognizer)
                    }
                }
            }
            
            var expandedTap = UITapGestureRecognizer(target: self, action: #selector(self.onTapExpandedVideoView))
            expandedTap.numberOfTapsRequired = 1
            expandedTap.delegate = self
            self.videoWrapper?.addGestureRecognizer(expandedTap)
            self.isExpandedMode = true
            self.didExpand()
            self.didReAppear()
    })
    }
    
    func didExpand() {
    }
    
    func didReAppear() {
        
    }
    
    func appearAnimation() {
        view.frame = CGRect(x: windowFrame.size.width - 50, y: windowFrame.size.height - 50, width: windowFrame.size.width, height: windowFrame.size.height)
        view.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        view.alpha = 0
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {() -> Void in
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.view.alpha = 1
            self.view.frame = CGRect(x: windowFrame.origin.x, y: windowFrame.origin.y, width: windowFrame.size.width, height: windowFrame.size.height)
        }, completion: {(_ finished: Bool) -> Void in
            self.afterAppearAnimation()
        })
    }
    
    func afterAppearAnimation() {
        videoWrapper.backgroundColor = UIColor.clear
        videoView.backgroundColor = videoWrapper.backgroundColor
        getWindow().addSubview(transparentBlackSheet)
        getWindow().addSubview(pageWrapper)
        getWindow().addSubview(videoWrapper)
        view.hidden = true
        videoView.addSubview(borderView)
        videoWrapper.addSubview(controllerView)
        messageView.hidden = true
        videoWrapper.addSubview(messageView)
        showControllerView()
        let expandedTap = UITapGestureRecognizer(target: self, action: #selector(self.onTapExpandedVideoView))
        expandedTap.numberOfTapsRequired = 1
        expandedTap.delegate = self
        videoWrapper.addGestureRecognizer(expandedTap)
        vFrame = videoWrapperFrame
        wFrame = pageWrapperFrame
        // adding Pan Gesture
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.panAction))
        var pan = UIPanGestureRecognizer(target: self, action: #selector(self.panAction))
        pan.delegate = self
        videoWrapper.addGestureRecognizer(pan)
        isExpandedMode = true
    }
    
    func disappear() {
        isAppear = false
        //    [self.delegate removeDraggableFloatingViewController];
    }
    
    func bringToFront() {
        //    [parentView addSubview:self.view];// then, "viewDidLoad" called
        //    [parentView addSubview:transparentBlackSheet];
        //    [parentView addSubview:pageWrapper];
        //    [parentView addSubview:videoWrapper];
        if isSetuped {
            getWindow().bringSubview(toFront: view)
            getWindow().bringSubview(toFront: transparentBlackSheet)
            getWindow().bringSubview(toFront: pageWrapper)
            getWindow().bringSubview(toFront: videoWrapper)
        }
    }
    
    func getWindow() -> UIWindow {
        return UIApplication.shared.delegate?.window ?? UIWindow()
    }
    
    func removeAllViews() {
        UIApplication.shared.setStatusBarHidden(false, with: .slide)
        videoWrapper.removeFromSuperview()
        pageWrapper.removeFromSuperview()
        transparentBlackSheet.removeFromSuperview()
        view.removeFromSuperview()
    }
    
    func showMessageView() {
        messageView.hidden = false
    }
    
    func hideMessageView() {
        messageView.hidden = true
    }
    
    func setHideControllerTimer() {
        if hideControllerTimer.isValid() {
            hideControllerTimer.invalidate()
        }
        hideControllerTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.hideControllerView), userInfo: nil, repeats: false)
    }
    
    func showControllerView() {
        print("showControllerView")
        isDisplayController = true
        setHideControllerTimer()
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {() -> Void in
            self.controllerView.alpha = 1.0
        }, completion: {(_ finished: Bool) -> Void in
        })
    }
    
    func hideControllerView() {
        print("hideControllerView")
        isDisplayController = false
        if hideControllerTimer.isValid() {
            hideControllerTimer.invalidate()
        }
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {() -> Void in
            self.controllerView.alpha = 0.0
        }, completion: {(_ finished: Bool) -> Void in
        })
    }
    
    func showControllerAfterExpanded() {
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.showControllerView), userInfo: nil, repeats: false)
    }

    @objc func onTapExpandedVideoView() {
        print("onTapExpandedVideoView")
        if controllerView.alpha == 0.0 {
            showControllerView()
        }
        else if controllerView.alpha == 1.0 {
            hideControllerView()
        }
        
    }
    
    func expandView(onTap sender: UITapGestureRecognizer) {
        expandView()
        showControllerAfterExpanded()
    }
}

extension DraggableFloatingViewController: UIGestureRecognizerDelegate {
    
    func panAction(_ recognizer: UIPanGestureRecognizer) {
        
        var touchPosInViewY: CGFloat = recognizer.location(in: view).y
        
        if recognizer.state == .began {
            direction = UIPanGestureRecognizerDirectionUndefined
            //storing direction
            var velocity: CGPoint = recognizer.velocity(in: recognizer.view)
            detectPanDirection(velocity)
            isMinimizingByGesture = false
            //Snag the Y position of the touch when panning begins
            touchPositionInHeaderY = recognizer.location(in: videoWrapper).y
            touchPositionInHeaderX = recognizer.location(in: videoWrapper).x
            if direction == UIPanGestureRecognizerDirectionDown {
                if videoView.frame.size.height > minimamVideoHeight {
                    // player.controlStyle = MPMovieControlStyleNone;
                    print("minimize gesture start")
                    isMinimizingByGesture = true
                    didStartMinimizeGesture()
                }
            }
        } else if recognizer.state == .changed {
            if direction == UIPanGestureRecognizerDirectionDown || direction == UIPanGestureRecognizerDirectionUp {
                //            CGFloat appendY = 20;
                //            if (direction == UIPanGestureRecognizerDirectionUp) appendY = -appendY;
                var newOffsetY: CGFloat = touchPosInViewY - touchPositionInHeaderY
                // + appendY;
                // CGFloat newOffsetX = newOffsetY * 0.35;
                adjustView(onVerticalPan: newOffsetY, recognizer: recognizer)
            }
            else if direction == UIPanGestureRecognizerDirectionRight || direction == UIPanGestureRecognizerDirectionLeft {
                adjustView(onHorizontalPan: recognizer)
            }
        } else if recognizer.state == .ended {
            
            var velocity: CGPoint = recognizer.velocity(in: recognizer.view)
            
            if direction == UIPanGestureRecognizerDirectionDown || direction == UIPanGestureRecognizerDirectionUp {
                if velocity.y < -flickVelocity {
                    //                NSLog(@"flick up");
                    expandView()
                    if isMinimizingByGesture == false {
                        showControllerAfterExpanded()
                    }
                    recognizer.setTranslation(CGPoint.zero, in: recognizer.view)
                    return
                }
                else if velocity.y > flickVelocity {
                    //                NSLog(@"flick down");
                    minimizeView()
                    recognizer.setTranslation(CGPoint.zero, in: recognizer.view)
                    return
                }
                else if recognizer.view.frame.origin.y > (windowFrame.size.width / 2) {
                    minimizeView()
                    recognizer.setTranslation(CGPoint.zero, in: recognizer.view)
                    return
                }
                else if recognizer.view.frame.origin.y < (windowFrame.size.width / 2) || recognizer.view.frame.origin.y < 0 {
                    expandView()
                    if isMinimizingByGesture == false {
                        showControllerAfterExpanded()
                    }
                    recognizer.setTranslation(CGPoint.zero, in: recognizer.view)
                    return
                }
            }
            else if direction == UIPanGestureRecognizerDirectionLeft {
                if pageWrapper.alpha <= 0 {
                    if velocity.x < -flickVelocity || pageWrapper.alpha < 0.3 {
                        fadeOutView(toLeft: recognizer, completion: {() -> Void in
                            self.disappear()
                        })
                        return
                    }
                    else if recognizer.view.frame.origin.x < 0 {
                        disappear()
                    }
                    else {
                        animateMiniView(toNormalPosition: recognizer) {() -> Void in }
                    }
                }
            } else if direction == UIPanGestureRecognizerDirectionRight {
                if pageWrapper.alpha <= 0 {
                    if velocity.x > flickVelocity {
                        fadeOutView(toRight: recognizer, completion: {() -> Void in
                            self.disappear()
                        })
                        return
                    }
                    if recognizer.view.frame.origin.x > windowFrame.size.width - 50 {
                        disappear()
                    }
                    else {
                        animateMiniView(toNormalPosition: recognizer) {() -> Void in }
                    }
                }
            }
            
            isMinimizingByGesture = false
            
        }
    }
    
    func detectPanDirection(_ velocity: CGPoint) {
        //    foldButton.hidden=TRUE;
        let isVerticalGesture: Bool = fabs(velocity.y) > fabs(velocity.x)
        if isVerticalGesture {
            if velocity.y > 0 {
                direction = UIPanGestureRecognizerDirectionDown
            }
            else {
                direction = UIPanGestureRecognizerDirectionUp
            }
        }
        else {
            if velocity.x > 0 {
                direction = UIPanGestureRecognizerDirectionRight
            }
            else {
                direction = UIPanGestureRecognizerDirectionLeft
            }
        }
    }
    
    
    func adjustView(onVerticalPan newOffsetY: CGFloat, recognizer: UIPanGestureRecognizer) {
        var touchPosInViewY: CGFloat = recognizer.location(in: view).y
        var progressRate: CGFloat = newOffsetY / finalViewOffsetY
        if progressRate >= 0.99 {
            progressRate = 1
            newOffsetY = finalViewOffsetY
        }
        calcNewFrame(withParsentage: progressRate, newOffsetY: newOffsetY)
        
        if progressRate <= 1 && pageWrapper.frame.origin.y >= 0 {
            pageWrapper.frame = wFrame
            videoWrapper.frame = vFrame
            videoView.frame = CGRect(x: videoView.frame.origin.x, y: videoView.frame.origin.x, width: vFrame.size.width, height: vFrame.size.height)
            bodyView.frame = CGRect(x: 0, y: videoView.frame.size.height, width: // keep stay on bottom of videoView
                bodyView.frame.size.width, height: bodyView.frame.size.height)
            borderView.frame = CGRect(x: videoView.frame.origin.y - 1, y: videoView.frame.origin.x - 1, width: videoView.frame.size.width + 1, height: videoView.frame.size.height + 1)
            controllerView.frame = videoView.frame
            
            var percentage: CGFloat = touchPosInViewY / windowFrame.size.height
            transparentBlackSheet.alpha = 1.0 - (percentage * 1.5)
            pageWrapper.alpha = transparentBlackSheet.alpha
            if percentage > 0.2 {
                borderView.alpha = percentage
            }
            else {
                borderView.alpha = 0
            }
            if isDisplayController {
                controllerView.alpha = 1.0 - (percentage * 2)
                //            if (percentage > 0.2) borderView.alpha = percentage;
                //            else borderView.alpha = 0;
            }
            if direction == UIPanGestureRecognizerDirectionDown {
                //            [parentView bringSubviewToFront:self.view];
                bringToFront()
            }
            if direction == UIPanGestureRecognizerDirectionUp && videoView.frame.origin.y <= 10 {
                didFullExpandByGesture()
            }
        }
        else if wFrame.origin.y < finalViewOffsetY && wFrame.origin.y > 0 {
            pageWrapper.frame = wFrame
            videoWrapper.frame = vFrame
            videoView.frame = CGRect(x: videoView.frame.origin.x, y: videoView.frame.origin.x, width: vFrame.size.width, height: vFrame.size.height)
            bodyView.frame = CGRect(x: 0, y: videoView.frame.size.height, width: // keep stay on bottom of videoView
                bodyView.frame.size.width, height: bodyView.frame.size.height)
            borderView.frame = CGRect(x: videoView.frame.origin.y - 1, y: videoView.frame.origin.x - 1, width: videoView.frame.size.width + 1, height: videoView.frame.size.height + 1)
            borderView.alpha = progressRate
        }
        
        recognizer.setTranslation(CGPoint.zero, in: recognizer.view)
    }
    
    
    func adjustView(onHorizontalPan recognizer: UIPanGestureRecognizer) {
        if pageWrapper.alpha <= 0 {
            var x: CGFloat = recognizer.location(in: view).x
            
            if direction == UIPanGestureRecognizerDirectionLeft {
                //            NSLog(@"recognizer x=%f",recognizer.view.frame.origin.x);
                var velocity: CGPoint = recognizer.velocity(in: recognizer.view)
                var isVerticalGesture: Bool = fabs(velocity.y) > fabs(velocity.x)
                var translation: CGPoint = recognizer.translation(in: recognizer.view)
                recognizer.view.center = CGPoint(x: recognizer.view.center.x + translation.x, y: recognizer.view.center.y)
                if !isVerticalGesture {
                    var percentage: CGFloat = (x / windowFrame.size.width)
                    recognizer.view.alpha = percentage
                }
                recognizer.setTranslation(CGPoint.zero, in: recognizer.view)
            }
            else if direction == UIPanGestureRecognizerDirectionRight {
                //            NSLog(@"recognizer x=%f",recognizer.view.frame.origin.x);
                var velocity: CGPoint = recognizer.velocity(in: recognizer.view)
                var isVerticalGesture: Bool = fabs(velocity.y) > fabs(velocity.x)
                var translation: CGPoint = recognizer.translation(in: recognizer.view)
                recognizer.view.center = CGPoint(x: recognizer.view.center.x + translation.x, y: recognizer.view.center.y)
                if !isVerticalGesture {
                    if velocity.x > 0 {
                        var percentage: CGFloat = (x / windowFrame.size.width)
                        recognizer.view.alpha = 1.0 - percentage
                    }
                    else {
                        var percentage: CGFloat = (x / windowFrame.size.width)
                        recognizer.view.alpha = percentage
                    }
                }
                recognizer.setTranslation(CGPoint.zero, in: recognizer.view)
            }
        }
    }
    
    func calcNewFrame(withParsentage persentage: CGFloat, newOffsetY: CGFloat) {
        let newWidth: CGFloat = minimamVideoWidth + ((maxW - minimamVideoWidth) * (1 - persentage))
        let newHeight: CGFloat = newWidth * videoHeightRatio
        let newOffsetX: CGFloat = maxW - newWidth - (finalMargin * persentage)
        vFrame.size.width = newWidth
        //self.view.bounds.size.width - xOffset;
        vFrame.size.height = newHeight
        //(200 - xOffset * 0.5);
        vFrame.origin.y = newOffsetY
        //trueOffset - finalMargin * 2;
        wFrame.origin.y = newOffsetY
        vFrame.origin.x = newOffsetX
        //maxW - vFrame.size.width - finalMargin;
        wFrame.origin.x = newOffsetX
        //    vFrame.origin.y = realNewOffsetY;//trueOffset - finalMargin * 2;
        //    wFrame.origin.y = realNewOffsetY;
    }
    
    func setFinalFrame() {
        vFrame.size.width = minimamVideoWidth
        //self.view.bounds.size.width - xOffset;
        // ↓
        vFrame.size.height = vFrame.size.width * videoHeightRatio
        //(200 - xOffset * 0.5);
        vFrame.origin.y = maxH - vFrame.size.height - finalMargin
        //trueOffset - finalMargin * 2;
        vFrame.origin.x = maxW - vFrame.size.width - finalMargin
        wFrame.origin.y = vFrame.origin.y
        wFrame.origin.x = vFrame.origin.x
    }
    
    func expandView() {
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {() -> Void in
            pageWrapper.frame = pageWrapperFrame
            videoWrapper.frame = videoWrapperFrame
            videoWrapper.alpha = 1
            videoView.frame = videoWrapperFrame
            pageWrapper.alpha = 1.0
            transparentBlackSheet.alpha = 1.0
            borderView.alpha = 0.0
            self.bodyView.frame = CGRect(x: 0, y: videoView.frame.size.height, width:     // keep stay on bottom of videoView
                self.bodyView.frame.size.width, height: self.bodyView.frame.size.height)
            borderView.frame = CGRect(x: videoView.frame.origin.y - 1, y: videoView.frame.origin.x - 1, width: videoView.frame.size.width + 1, height: videoView.frame.size.height + 1)

            
        }, completion: {(_ finished: Bool) -> Void in
            for recognizer: UIGestureRecognizer in videoWrapper.gestureRecognizers {
                if (recognizer is UITapGestureRecognizer) {
                    videoWrapper.removeGestureRecognizer(recognizer)
                }
            }
            var expandedTap = UITapGestureRecognizer(target: self, action: #selector(self.onTapExpandedVideoView))
            expandedTap.numberOfTapsRequired = 1
            expandedTap.delegate = self
            videoWrapper.addGestureRecognizer(expandedTap)
            // player.controlStyle = MPMovieControlStyleDefault;
            // [self showVideoControl];
            isExpandedMode = true
            //                         self.controllerView.hidden = FALSE;
            didExpand()
        })
    }
    
    func minimizeView() {
    
        setFinalFrame()
        hideControllerView()
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {() -> Void in
            pageWrapper.frame = wFrame
            videoWrapper.frame = vFrame
            videoView.frame = CGRect(x: videoView.frame.origin.x, y: videoView.frame.origin.x, width: vFrame.size.width, height: vFrame.size.height)
            pageWrapper.alpha = 0
            transparentBlackSheet.alpha = 0.0
            borderView.alpha = 1.0
            borderView.frame = CGRect(x: videoView.frame.origin.y - 1, y: videoView.frame.origin.x - 1, width: videoView.frame.size.width + 1, height: videoView.frame.size.height + 1)
            controllerView.frame = videoView.frame
            
        }, completion: {(_ finished: Bool) -> Void in
            didMinimize()
            //add tap gesture
            tapRecognizer = nil
            if tapRecognizer == nil {
                for recognizer: UIGestureRecognizer in videoWrapper.gestureRecognizers {
                    if (recognizer is UITapGestureRecognizer) {
                        videoWrapper.removeGestureRecognizer(recognizer)
                    }
                }
                tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.expandViewOnTap))
                tapRecognizer.numberOfTapsRequired = 1
                tapRecognizer.delegate = self
                videoWrapper.addGestureRecognizer(tapRecognizer)
            }
            isExpandedMode = false
            minimizedVideoFrame = videoWrapper.frame
            if direction == UIPanGestureRecognizerDirectionDown {
                //                             [parentView bringSubviewToFront:self.view];
                bringToFront()
            }
        })
        
    }

    
    func animateMiniView(toNormalPosition recognizer: UIPanGestureRecognizer, completion: @escaping () -> Void) {
        setFinalFrame()

        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {() -> Void in
            pageWrapper.frame = wFrame
            videoWrapper.frame = vFrame
            videoView.frame = CGRect(x: videoView.frame.origin.x, y: videoView.frame.origin.x, width: vFrame.size.width, height: vFrame.size.height)
            pageWrapper.alpha = 0
            videoWrapper.alpha = 1
            borderView.alpha = 1
            self.controllerView.frame = videoView.frame
        }, completion: {(_ finished: Bool) -> Void in
            if completion {
                completion()
            }
        })
        recognizer.setTranslation(CGPoint.zero, in: recognizer.view)
    }
    
    func fadeOutView(toRight recognizer: UIPanGestureRecognizer, completion: @escaping () -> Void) {
        vFrame.origin.x = maxW + minimamVideoWidth
        wFrame.origin.x = maxW + minimamVideoWidth
        
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseInOut, animations: {() -> Void in
            pageWrapper.frame = wFrame
            videoWrapper.frame = vFrame
            videoView.frame = CGRect(x: videoView.frame.origin.x, y: videoView.frame.origin.x, width: vFrame.size.width, height: vFrame.size.height)
            pageWrapper.alpha = 0
            videoWrapper.alpha = 0
            borderView.alpha = 0
            self.controllerView.frame = videoView.frame
        }, completion: {(_ finished: Bool) -> Void in
            if completion {
                completion()
            }
            self.didDisappear()
        })
        recognizer.setTranslation(CGPoint.zero, in: recognizer.view)
    }
    
    
    func fadeOutView(toLeft recognizer: UIPanGestureRecognizer, completion: @escaping () -> Void) {
        vFrame.origin.x = -maxW
        wFrame.origin.x = -maxW
        
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseInOut, animations: {() -> Void in
            pageWrapper.frame = wFrame
            videoWrapper.frame = vFrame
            videoView.frame = CGRect(x: videoView.frame.origin.x, y: videoView.frame.origin.x, width: vFrame.size.width, height: vFrame.size.height)
            pageWrapper.alpha = 0
            videoWrapper.alpha = 0
            borderView.alpha = 0
            self.controllerView.frame = videoView.frame
        }, completion: {(_ finished: Bool) -> Void in
            if completion {
                completion()
            }
            self.didDisappear()
        })
        
        recognizer.setTranslation(CGPoint.zero, in: recognizer.view)
    }
    
    
    
    func gestureRecognizerShould(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.view?.frame.origin.y < 0 {
            return false
        }
        else {
            return true
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    
    
   override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    
}

















