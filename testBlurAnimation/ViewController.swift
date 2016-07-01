//
//  ViewController.swift
//  testBlurAnimation
//
//  Created by chan bill on 1/7/2016.
//  Copyright © 2016 billchan. All rights reserved.
//

import UIKit

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
    
    @IBOutlet weak var blurview: UIVisualEffectView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        blurview.effect = nil
        blurEffectView(enable: true, blurView: blurview, percentage:0.3)
        
        delayedUndoBlurEffect(2)
        
        delayedBlurEffect(5, percentage:0.5)
        delayedUndoBlurEffect(7)
        delayedBlurEffect(9, percentage:0.7)
        delayedUndoBlurEffect(11)
        delayedBlurEffect(13, percentage:1.0)
    }

    func delayedBlurEffect(time:Double, percentage:Double) {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(time * Double(NSEC_PER_SEC)))
        
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.blurEffectView(enable: true, blurView: self.blurview, percentage:percentage)
        }
    }

    func delayedUndoBlurEffect(time:Double) {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(time * Double(NSEC_PER_SEC)))
        
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.blurEffectView(enable: false, blurView: self.blurview, percentage:0)
        }
    }
    
    func blurEffectView(enable enable: Bool, blurView: UIVisualEffectView!, percentage:Double) {
        let animationTime = 0.5
        
        let enabled = blurView.effect != nil
        guard enable != enabled else { return }
        
        switch enable {
        case true:
            let blurEffect = UIBlurEffect(style: .Dark)
            UIView.animateWithDuration(animationTime) {
                blurView.effect = blurEffect
            }
            
            blurView.pauseAnimation(delay: animationTime * percentage)
        case false:
            blurView.resumeAnimation()
            
            UIView.animateWithDuration(0.1) {
                blurView.effect = nil
            }
        }
    }
}

