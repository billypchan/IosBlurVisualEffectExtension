
//
//  ViewController.swift
//  testBlurAnimation
//
//  Created by chan bill on 1/7/2016.
//  Copyright © 2016 billchan. All rights reserved.
//

import UIKit

extension UIVisualEffectView {
    ///NOTICE: this func will pause all other animations in the visual effect view! If you want to add other animation with this visual effect view, do it in a container view
    func blurEffectView(enable enable: Bool, percentage:Double, animationTime:Double = 0.1) {
        
        let enabled = self.effect != nil
        guard enable != enabled else { return }
        
        switch enable {
        case true:
            let blurEffect = UIBlurEffect(style: .Dark)
            UIView.animateWithDuration(animationTime) {
                self.effect = blurEffect
            }
            
            self.pauseAnimation(delay: animationTime * percentage)
        case false:
            self.resumeAnimation()
            
            UIView.animateWithDuration(0.1) {
                self.effect = nil
            }
        }
    }
}

extension UIView {
    
    public func pauseAnimation(delay delay: Double) {
        let time = delay + CFAbsoluteTimeGetCurrent()
        let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, time, 0, 0, 0, { timer in
            let layer = self.layer
            let pausedTime = layer.convertTime(CACurrentMediaTime(), fromLayer: nil)
            layer.speed = 0.0
            layer.timeOffset = pausedTime
        })
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, kCFRunLoopCommonModes)
    }
    
    public func resumeAnimation() {
        let pausedTime  = layer.timeOffset
        
        layer.speed = 1.0
        layer.timeOffset = 0.0
        layer.beginTime = layer.convertTime(CACurrentMediaTime(), fromLayer: nil) - pausedTime
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var blurviewInView: UIVisualEffectView!
    @IBOutlet weak var viewContainer: UIView!
    
    func animateTranslate() {
        viewContainer.center = CGPoint(x: viewContainer.center.x, y: viewContainer.center.y+viewContainer.frame.size.height)
        
        UIView.animateWithDuration(3, delay: 0, options:UIViewAnimationOptions.CurveLinear, animations: {
            self.viewContainer.center = self.view.center
            }, completion: {
                (value: Bool) in
        })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        blurviewInView.effect = nil
        
        animateTranslate()
        
        /// When percentage < 0.1, the effect is not obivious
        blurviewInView.blurEffectView(enable: true, percentage:0.2, animationTime:3)
    }
    
    func testAnimationRemovedIssue(){
        blurviewInView.effect = nil
        delayedBlurEffect(blurviewInView, time:0, percentage: 0.7)
        blurviewInView.center = CGPoint(x: blurviewInView.center.x, y: blurviewInView.center.y+blurviewInView.frame.size.height)
        
        UIView.animateWithDuration(0.5, delay: 0.5, options:UIViewAnimationOptions.CurveLinear, animations: {
            self.blurviewInView.center = self.view.center
            }, completion: {
                (value: Bool) in
        })
    }
    
    ///The Hack works even the view is hidden
    func testBlurWhenHidden() {
        blurviewInView.hidden = true
        blurviewInView.blurEffectView(enable: true, percentage:0.7)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(10 * Double(NSEC_PER_SEC)))
        
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.blurviewInView.hidden = false
        }
    }
    
    func testBlurInDifferentLevel(){
        blurviewInView.blurEffectView(enable: true, percentage:0.3)
        
        delayedUndoBlurEffect(2)
        
        delayedBlurEffect(blurviewInView, time:5, percentage:0.5)
        delayedUndoBlurEffect(7)
        delayedBlurEffect(blurviewInView, time:9, percentage:0.7)
        delayedUndoBlurEffect(11)
        delayedBlurEffect(blurviewInView, time:13, percentage:1.0)
    }
    
    func delayedBlurEffect(blurview:UIVisualEffectView!, time:Double, percentage:Double) {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(time * Double(NSEC_PER_SEC)))
        
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.blurviewInView.blurEffectView(enable: true, percentage:percentage)
        }
    }
    
    func delayedUndoBlurEffect(time:Double) {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(time * Double(NSEC_PER_SEC)))
        
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.blurviewInView.blurEffectView(enable: false, percentage:0)
        }
    }
    
}

