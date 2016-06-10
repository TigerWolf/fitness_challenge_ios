//
//  ErrorView.swift
//  StudentExperienceMonitor
//
//  Created by Andreas Wulf on 1/09/2015.
//  Copyright (c) 2015 Adelaide University. All rights reserved.
//

import UIKit

class ErrorView: UIView {
    let messageLabel = UILabel()
    let retryButton = UIButton()
    
    init() {
        super.init(frame: CGRectZero)
        
        self.backgroundColor = Appearance.whiteColour
        
        self.messageLabel.numberOfLines = 0
        self.messageLabel.textColor = Appearance.blueColour
        self.messageLabel.font = UIFont.systemFontOfSize(17)
        self.messageLabel.textAlignment = .Center
        self.addSubview(self.messageLabel)
        
        self.retryButton.setTitle("Retry", forState: .Normal)
        self.retryButton.setImage(
            UIImage(named: "icon_reload")!.imageWithRenderingMode(.AlwaysTemplate),
            forState: .Normal)
        self.retryButton.tintColor = Appearance.blueColour
        self.retryButton.setTitleColor(Appearance.blueColour, forState: .Normal)
        self.retryButton.sizeToFit()
        self.retryButton.layer.borderColor = Appearance.blueColour.CGColor
        self.retryButton.layer.borderWidth = 1.0
        self.retryButton.layer.cornerRadius = 3.0
        self.retryButton.frame.size = CGSizeMake(
            self.retryButton.frame.width + Appearance.lpad,
            self.retryButton.frame.height + Appearance.spad)
        
        self.retryButton.titleEdgeInsets = UIEdgeInsetsMake(
            0,
            -self.retryButton.imageView!.frame.size.width,
            0,
            self.retryButton.imageView!.frame.size.width);
        self.retryButton.imageEdgeInsets = UIEdgeInsetsMake(
            0,
            self.retryButton.titleLabel!.frame.size.width,
            0,
            -self.retryButton.titleLabel!.frame.size.width);
        
        self.addSubview(self.retryButton)
        self.retryButton.hidden = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setText(title: String?, subtitle: String?) {
        var text = ""
        if let titleText = title {
            text = titleText
        }
        
        if let subtiteText = subtitle {
            if text.characters.count > 0 {
                text += "\n"
            }
            text += subtiteText
        }
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.paragraphSpacingBefore = 10
        paragraph.alignment = .Center
        
        let attributedString = NSMutableAttributedString(
            string: text,
            attributes: [NSParagraphStyleAttributeName: paragraph])
        
        if let titleText = title {
            attributedString.setAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(18)],
                range: NSString(string: text).rangeOfString(titleText))
        }
        
        self.messageLabel.attributedText = attributedString
        self.setNeedsLayout()
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
        
        let pad: CGFloat = Appearance.lpad
        let maxWidth: CGFloat = 280.0
        
        self.messageLabel.frame.size.width = maxWidth
        self.messageLabel.sizeToFit()
        
        var totalHeight = self.messageLabel.frame.height
        if self.retryButton.hidden == false {
            totalHeight += (self.retryButton.frame.height + pad)
        }
        
        self.messageLabel.frame = CGRectMake(
            round((self.frame.width - messageLabel.frame.width)/2.0),
            round((self.frame.height - totalHeight)/2.0),
            self.messageLabel.frame.width,
            self.messageLabel.frame.height)
        
        self.retryButton.frame.origin = CGPointMake(
            round((self.frame.width - self.retryButton.frame.width)/2.0),
            self.messageLabel.frame.maxY + pad)
        
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
}