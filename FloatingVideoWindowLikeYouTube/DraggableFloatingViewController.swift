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
    //please add loading spiner on this
    var messageView:UIView?
    
    
    //local Frame storee
    var videoWrapperFrame:CGRect?
    var minimizedVideoFrame:CGRect?
    var pageWrapperFrame:CGRect?
    
    // animation Frame
    var wFrame:CGRect?
    var vFrame:CGRect?
    
    //local touch location
    var  _touchPositionInHeaderY:CGFloat?
    var _touchPositionInHeaderX:CGFloat?
    
    //detecting Pan gesture Direction
    var direction:UIPanGestureRecognizerDirection?
    
    var tapRecognizer:UITapGestureRecognizer?
    
    //Creating a transparent Black layer view
    var transparentBlackSheet:UIView?
    
    //Just to Check wether view  is expanded or not
    var isExpandedMode:Bool?
    
    
    var pageWrapper:UIView?
    var videoWrapper:UIView?
    //    UIButton *foldButton;
    
    var videoView:UIView?
    // border of mini vieo view
    var borderView:UIView?
    
    var maxH:CGFloat?
    var maxW:CGFloat?
    var videoHeightRatio:CGFloat?
    var finalViewOffsetY:CGFloat?
    var minimamVideoHeight:CGFloat?
    
    var parentView:UIView?
    
    var isDisplayController:Bool
    var hideControllerTimer:Timer?
    
    var isMinimizingByGesture:Bool?
    
    var isAppear:Bool?
    var isSetuped:Bool?
    var windowFrame:CGRect?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

}

extension DraggableFloatingViewController: UIGestureRecognizerDelegate {
    
}
