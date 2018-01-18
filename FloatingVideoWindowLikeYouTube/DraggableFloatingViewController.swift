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

    // please add subview on this
    var bodyView:UIView?
    //please add controller on this
    var controllerView:UIView?
//    //please add loading spiner on this
    var messageView:UIView?
//
//
//    //local Frame storee
    var videoWrapperFrame:CGRect?
    var minimizedVideoFrame:CGRect?
    var pageWrapperFrame:CGRect?
//
//    // animation Frame
    var wFrame:CGRect?
    var vFrame:CGRect?
//
//    //local touch location
    var  _touchPositionInHeaderY:CGFloat?
    var _touchPositionInHeaderX:CGFloat?
//
//    //detecting Pan gesture Direction
    var direction:UIPanGestureRecognizerDirection?

    var tapRecognizer:UITapGestureRecognizer?
//
    //Creating a transparent Black layer view
    var transparentBlackSheet:UIView?
//
    //Just to Check wether view  is expanded or not
    var isExpandedMode:Bool?
//
//
    var pageWrapper:UIView?
    var videoWrapper:UIView?
//    //    UIButton *foldButton;
//
    var videoView:UIView?
    // border of mini vieo view
    var borderView:UIView?
//
    var maxH:CGFloat?
    var maxW:CGFloat?
    var videoHeightRatio:CGFloat?
    var finalViewOffsetY:CGFloat?
    var minimamVideoHeight:CGFloat?
//
    var parentView:UIView?
//
    var isDisplayController:Bool?
    var hideControllerTimer:Timer?

    var isMinimizingByGesture:Bool?

    var isAppear:Bool?
    var isSetuped:Bool?
    var windowFrame:CGRect?

    let finalMargin:CGFloat = 3.0
    let minimamVideoWidth:CGFloat = 140
    let flickVelocity:CGFloat = 1000

    
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
    

    func show() {
        if let isSetuped = isSetuped {
            if !isSetuped {
                self.setup
            } else {
                if let isAppear = isAppear {
                    if !isAppear {
                        self.reAppearWithAnimation
                    }
                }
            }
        }
//        if (!isSetuped) {
//            [self setup];
//        }else {
//            if (!isAppear) {
//                [self reAppearWithAnimation];
//            }
//        }
    }

    
    func setup() {
        
        isSetuped = true;
        
        NSLog(@"showVideoViewControllerOnParentVC");
        
        //    if( ![parentVC conformsToProtocol:@protocol(DraggableFloatingViewControllerDelegate)] ) {
        //        NSAssert(NO, @"❌❌Parent view controller must confirm to protocol <DraggableFloatingViewControllerDelegate>.❌❌");
        //    }
        //    self.delegate = parentVC;
        
        // set portrait
        if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
            [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationPortrait] forKey:@"orientation"];
        }
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        
        //    parentView = parentVC.view;
        //    [parentView addSubview:self.view];// then, "viewDidLoad" called
        [[self getWindow] addSubview:self.view];
        
        // wait to run "viewDidLoad" before "showThisView"
        [self performSelector:@selector(showThisView) withObject:nil afterDelay:0.0];
        
        isAppear = true;
    }

}

extension DraggableFloatingViewController: UIGestureRecognizerDelegate {
    
}
