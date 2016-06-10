//
//  LoadingView.swift
//  StudentExperienceMonitor
//
//  Created by Andreas Wulf on 20/08/2015.
//  Copyright (c) 2015 Adelaide University. All rights reserved.
//

import UIKit

class LoadingView : UIView {
    let indicatorView = UIImageView()
    let messageLabel = UILabel()
    
    init() {
        super.init(frame: CGRectZero)
        
        indicatorView.image = UIImage(named: "indicator_loading")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        indicatorView.sizeToFit()
        indicatorView.tintColor = Appearance.blueColour
        self.addSubview(indicatorView)
        
        messageLabel.numberOfLines = 0
        self.addSubview(messageLabel)
        
        self.backgroundColor = UIColor.whiteColor()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    required init?(coder aDecoder: NSCoder) {
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//        super.init(coder: aDecoder)!
//    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let pad: CGFloat = Appearance.spad
        
        self.indicatorView.center = self.center
        self.messageLabel.frame = CGRectMake(pad, CGFloat(roundf(Float(self.indicatorView.frame.maxY + pad))), self.frame.width - (pad * 2.0), CGFloat(1.0))
        self.messageLabel.sizeToFit()
        self.messageLabel.frame.origin.x = CGFloat(roundf(Float(self.frame.width - self.messageLabel.frame.width)/2.0))
    }
    
    func hide(animated: Bool) {
        if animated {
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.alpha = 0.0
                }, completion: { (finished) -> Void in
                    self.hidden = true
            })
        } else {
            self.alpha = 0.0
            self.hidden = true
        }
    }
    
    func show(animated: Bool) {
        self.hidden = false
        self.alpha = 0.0
        
        if animated {
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.alpha = 1.0
            })
        } else {
            self.alpha = 1.0
        }
    }
    
    override var hidden: Bool {
        set(hidden) {
            super.hidden = hidden
            
            if hidden {
                self.indicatorView.layer.removeAllAnimations()
                
            } else {
                if self.indicatorView.layer.animationKeys() == nil {
                    let animation = CABasicAnimation(keyPath: "transform.rotation.z")
                    animation.fromValue = 0
                    animation.toValue = 2 * M_PI
                    animation.duration = 1;
                    animation.repeatCount = Float.infinity
                    
                    self.indicatorView.layer.addAnimation(animation, forKey: "SpinnerAnimation")
                }
            }
            
        }
        get {
            return super.hidden
        }
    }
}
