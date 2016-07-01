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
        blurEffectView(enable: true, blurView: blurview)
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.blurEffectView(enable: false, blurView: self.blurview)
        }
    }
    
    func blurEffectView(enable enable: Bool, blurView: UIVisualEffectView!) {
        let enabled = blurView.effect != nil
        guard enable != enabled else { return }
        
        switch enable {
        case true:
            let blurEffect = UIBlurEffect(style: .Dark)
            UIView.animateWithDuration(1.5) {
                blurView.effect = blurEffect
            }
            
            blurView.pauseAnimation(delay: 0.3)
        case false:
            blurView.resumeAnimation()
            
            UIView.animateWithDuration(0.1) {
                blurView.effect = nil
            }
        }
    }
}

