//
//  Reachability.swift
//  Umbria
//
//  Created by Imbibe Desk16 on 08/07/15.
//  Copyright (c) 2015 Imbibe Desk16. All rights reserved.
//


import UIKit

//Infix overload method
func /(lhs: CGFloat, rhs: Int) -> CGFloat {
    return lhs / CGFloat(rhs)
}

//Toast Config
let ToastDefaultDuration  =   2.0
let ToastFadeDuration     =   0.2
let ToastHorizontalMargin : CGFloat  =   15.0
let ToastVerticalMargin   : CGFloat  =   15.0

let ToastPositionDefault  =   "bottom"
let ToastPositionTop      =   "top"
let ToastPositionCenter   =   "center"

//Activity
let ToastActivityWidth  :  CGFloat  = 100.0
let ToastActivityHeight :  CGFloat  = 100.0
let ToastActivityPositionDefault    = "center"

//Image size
let ToastImageViewWidth :  CGFloat  = 80.0
let ToastImageViewHeight:  CGFloat  = 80.0

//Label setting
let ToastMaxWidth       :  CGFloat  = 0.8;      // 80% of parent view width
let ToastMaxHeight      :  CGFloat  = 0.8;
let ToastFontSize       :  CGFloat  = 15.0
let ToastMaxTitleLines              = 0
let ToastMaxMessageLines            = 0

//Shadow appearance
let ToastShadowOpacity  : CGFloat   = 0.8
let ToastShadowRadius   : CGFloat   = 6.0
let ToastShadowOffset   : CGSize    = CGSize(width: CGFloat(4.0), height: CGFloat(4.0))

let ToastOpacity        : CGFloat   = 0.5
let ToastCornerRadius   : CGFloat   = 10.0

var ToastActivityView: UnsafePointer<UIView>?    =   nil
var ToastTimer: UnsafePointer<Timer>?          =   nil
var ToastView: UnsafePointer<UIView>?            =   nil

//Custom Config
let ToastHidesOnTap       =   true
let ToastDisplayShadow    =   true

//Toast (UIView + Toast using Swift)

extension UIView {
    
    //Public methods
    func makeToast(message msg: String) {
        self.makeToast(message: msg, duration: ToastDefaultDuration, position: ToastPositionDefault as AnyObject)
    }
    
    func makeToast(message msg: String, duration: Double, position: AnyObject) {
        let toast = self.viewForMessage(msg, title: nil, image: nil)
        self.showToast(toast: toast!, duration: duration, position: position)
    }
    
    func makeToast(message msg: String, duration: Double, position: AnyObject, title: String) {
        let toast = self.viewForMessage(msg, title: title, image: nil)
        self.showToast(toast: toast!, duration: duration, position: position)
    }
    
    func makeToast(message msg: String, duration: Double, position: AnyObject, image: UIImage) {
        let toast = self.viewForMessage(msg, title: nil, image: image)
        self.showToast(toast: toast!, duration: duration, position: position)
    }
    
    func makeToast(message msg: String, duration: Double, position: AnyObject, title: String, image: UIImage) {
        let toast = self.viewForMessage(msg, title: title, image: image)
        self.showToast(toast: toast!, duration: duration, position: position)
    }
    
    func showToast(toast: UIView) {
        self.showToast(toast: toast, duration: ToastDefaultDuration, position: ToastPositionDefault as AnyObject)
    }
    
    func showToast(toast: UIView, duration: Double, position: AnyObject) {
        let existToast = objc_getAssociatedObject(self, &ToastView) as! UIView?
        if existToast != nil {
            if let timer: Timer = objc_getAssociatedObject(existToast, &ToastTimer) as? Timer {
                timer.invalidate();
            }
            self.hideToast(toast: existToast!, force: false);
        }
        
        toast.center = self.centerPointForPosition(position, toast: toast)
        toast.alpha = 0.0
        
        if ToastHidesOnTap {
            let tapRecognizer = UITapGestureRecognizer(target: toast, action: #selector(UIView.handleToastTapped(_:)))
            toast.addGestureRecognizer(tapRecognizer)
            toast.isUserInteractionEnabled = true;
            toast.isExclusiveTouch = true;
        }
        
        self.addSubview(toast)
        objc_setAssociatedObject(self, &ToastView, toast, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        
        UIView.animate(withDuration: ToastFadeDuration,
            delay: 0.0, options: [.curveEaseOut, .allowUserInteraction],
            animations: {
                toast.alpha = 1.0
            },
            completion: { (finished: Bool) in
                let timer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(UIView.toastTimerDidFinish(_:)), userInfo: toast, repeats: false)
                objc_setAssociatedObject(toast, &ToastTimer, timer, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        })
    }
    
    func makeToastActivity() {
        self.makeToastActivity(position: ToastActivityPositionDefault as AnyObject)
    }
    
    func makeToastActivityWithMessage(message msg: String){
        self.makeToastActivity(position: ToastActivityPositionDefault as AnyObject, message: msg)
    }
    
    func makeToastActivity(position pos: AnyObject, message msg: String = "") {
        let existingActivityView: UIView? = objc_getAssociatedObject(self, &ToastActivityView) as? UIView
        if existingActivityView != nil { return }
        
        let activityView = UIView(frame: CGRect(x: 0, y: 0, width: ToastActivityWidth, height: ToastActivityHeight))
        activityView.center = self.centerPointForPosition(pos, toast: activityView)
        activityView.backgroundColor = UIColor.black.withAlphaComponent(ToastOpacity)
        activityView.alpha = 0.0
        activityView.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin]
        activityView.layer.cornerRadius = ToastCornerRadius
        
        if ToastDisplayShadow {
            activityView.layer.shadowColor = UIColor.black.cgColor
            activityView.layer.shadowOpacity = Float(ToastShadowOpacity)
            activityView.layer.shadowRadius = ToastShadowRadius
            activityView.layer.shadowOffset = ToastShadowOffset
        }
        
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicatorView.center = CGPoint(x: activityView.bounds.size.width / 2, y: activityView.bounds.size.height / 2)
        activityView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        
        if (!msg.isEmpty){
            activityIndicatorView.frame.origin.y -= 10
            let activityMessageLabel = UILabel(frame: CGRect(x: activityView.bounds.origin.x, y: (activityIndicatorView.frame.origin.y + activityIndicatorView.frame.size.height + 10), width: activityView.bounds.size.width, height: 20))
            activityMessageLabel.textColor = UIColor.white
            activityMessageLabel.font = msg.characters.count <= 10 ? UIFont(name:activityMessageLabel.font.fontName, size: 16) : UIFont(name:activityMessageLabel.font.fontName, size: 13)
            activityMessageLabel.textAlignment = .center
            activityMessageLabel.text = msg
            activityView.addSubview(activityMessageLabel)
        }
        
        self.addSubview(activityView)
        
        //Associate activity view with self
        objc_setAssociatedObject(self, &ToastActivityView, activityView, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        UIView.animate(withDuration: ToastFadeDuration,
            delay: 0.0,
            options: UIViewAnimationOptions.curveEaseOut,
            animations: {
                activityView.alpha = 1.0
            },
            completion: nil)
    }
    
    func hideToastActivity() {
        let existingActivityView = objc_getAssociatedObject(self, &ToastActivityView) as! UIView?
        if existingActivityView == nil { return }
        UIView.animate(withDuration: ToastFadeDuration,
            delay: 0.0,
            options: UIViewAnimationOptions.curveEaseOut,
            animations: {
                existingActivityView!.alpha = 0.0
            },
            completion: { (finished: Bool) in
                existingActivityView!.removeFromSuperview()
                objc_setAssociatedObject(self, &ToastActivityView, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        })
    }
    
    //Private methods (helper)
    func hideToast(toast: UIView) {
        self.hideToast(toast: toast, force: false);
    }
    
    func hideToast(toast: UIView, force: Bool) {
        let completeClosure = { (finish: Bool) -> () in
            toast.removeFromSuperview()
            objc_setAssociatedObject(self, &ToastTimer, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        if force {
            completeClosure(true)
        } else {
            UIView.animate(withDuration: ToastFadeDuration,
                delay: 0.0,
                options: [.curveEaseIn, .beginFromCurrentState],
                animations: {
                    toast.alpha = 0.0
                },
                completion:completeClosure)
        }
    }
    
    @objc func toastTimerDidFinish(_ timer: Timer) {
        self.hideToast(toast: timer.userInfo as! UIView)
    }
    
    @objc func handleToastTapped(_ recognizer: UITapGestureRecognizer) {
        let timer = objc_getAssociatedObject(self, &ToastTimer) as! Timer
        timer.invalidate()
        
        self.hideToast(toast: recognizer.view!)
    }
    
    func centerPointForPosition(_ position: AnyObject, toast: UIView) -> CGPoint {
        if position is String {
            let toastSize = toast.bounds.size
            let viewSize  = self.bounds.size
            if position.lowercased == ToastPositionTop {
                return CGPoint(x: viewSize.width/2, y: toastSize.height/2 + ToastVerticalMargin)
            } else if position.lowercased == ToastPositionDefault {
                //Changed by me: changed 'toastSize.height/2' to 'toastSize.height+10'
                return CGPoint(x: viewSize.width/2, y: viewSize.height - (toastSize.height+10) - ToastVerticalMargin)
            } else if position.lowercased == ToastPositionCenter {
                return CGPoint(x: viewSize.width/2, y: viewSize.height/2)
            }
        } else if position is NSValue {
            return position.cgPointValue
        }
        print("Warning: Invalid position for toast.")
        return self.centerPointForPosition(ToastPositionDefault as AnyObject, toast: toast)
    }
    
    func viewForMessage(_ msg: String?, title: String?, image: UIImage?) -> UIView? {
        if msg == nil && title == nil && image == nil { return nil }
        
        var msgLabel: UILabel?
        var titleLabel: UILabel?
        var imageView: UIImageView?
        
        let wrapperView = UIView()
        wrapperView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        wrapperView.layer.cornerRadius = ToastCornerRadius
        wrapperView.backgroundColor =  UIColor.black.withAlphaComponent(ToastOpacity)
        
        if ToastDisplayShadow {
            wrapperView.layer.shadowColor = UIColor.black.cgColor
            wrapperView.layer.shadowOpacity = Float(ToastShadowOpacity)
            wrapperView.layer.shadowRadius = ToastShadowRadius
            wrapperView.layer.shadowOffset = ToastShadowOffset
        }
        
        if image != nil {
            imageView = UIImageView(image: image)
            imageView!.contentMode = .scaleAspectFit
            imageView!.frame = CGRect(x: ToastHorizontalMargin, y: ToastVerticalMargin, width: CGFloat(ToastImageViewWidth), height: CGFloat(ToastImageViewHeight))
        }
        
        var imageWidth: CGFloat, imageHeight: CGFloat, imageLeft: CGFloat
        if imageView != nil {
            imageWidth = imageView!.bounds.size.width
            imageHeight = imageView!.bounds.size.height
            imageLeft = ToastHorizontalMargin
        } else {
            imageWidth  = 0.0; imageHeight = 0.0; imageLeft   = 0.0
        }
        
        if title != nil {
            titleLabel = UILabel()
            titleLabel!.numberOfLines = ToastMaxTitleLines
            titleLabel!.font = UIFont.boldSystemFont(ofSize: ToastFontSize)
            titleLabel!.textAlignment = .center
            titleLabel!.lineBreakMode = .byWordWrapping
            titleLabel!.textColor = UIColor.white
            titleLabel!.backgroundColor = UIColor.clear
            titleLabel!.alpha = 1.0
            titleLabel!.text = title
            
            //Size the title label according to the length of the text
            let maxSizeTitle = CGSize(width: (self.bounds.size.width * ToastMaxWidth) - imageWidth, height: self.bounds.size.height * ToastMaxHeight);
            let expectedHeight = title!.stringHeightWithFontSize(ToastFontSize, width: maxSizeTitle.width)
            titleLabel!.frame = CGRect(x: 0.0, y: 0.0, width: maxSizeTitle.width, height: expectedHeight)
        }
        
        if msg != nil {
            msgLabel = UILabel();
            msgLabel!.numberOfLines = ToastMaxMessageLines
            msgLabel!.font = UIFont.systemFont(ofSize: ToastFontSize)
            msgLabel!.lineBreakMode = .byWordWrapping
            msgLabel!.textAlignment = .center
            msgLabel!.textColor = UIColor.white
            msgLabel!.backgroundColor = UIColor.clear
            msgLabel!.alpha = 1.0
            msgLabel!.text = msg
            
            let maxSizeMessage = CGSize(width: (self.bounds.size.width * ToastMaxWidth) - imageWidth, height: self.bounds.size.height * ToastMaxHeight)
            let expectedHeight = msg!.stringHeightWithFontSize(ToastFontSize, width: maxSizeMessage.width)
            msgLabel!.frame = CGRect(x: 0.0, y: 0.0, width: maxSizeMessage.width, height: expectedHeight)
        }
        
        var titleWidth: CGFloat, titleHeight: CGFloat, titleTop: CGFloat, titleLeft: CGFloat
        if titleLabel != nil {
            titleWidth = titleLabel!.bounds.size.width
            titleHeight = titleLabel!.bounds.size.height
            titleTop = ToastVerticalMargin
            titleLeft = imageLeft + imageWidth + ToastHorizontalMargin
        } else {
            titleWidth = 0.0; titleHeight = 0.0; titleTop = 0.0; titleLeft = 0.0
        }
        
        var msgWidth: CGFloat, msgHeight: CGFloat, msgTop: CGFloat, msgLeft: CGFloat
        if msgLabel != nil {
            msgWidth = msgLabel!.bounds.size.width
            msgHeight = msgLabel!.bounds.size.height
            msgTop = titleTop + titleHeight + ToastVerticalMargin
            msgLeft = imageLeft + imageWidth + ToastHorizontalMargin
        } else {
            msgWidth = 0.0; msgHeight = 0.0; msgTop = 0.0; msgLeft = 0.0
        }
        
        let largerWidth = max(titleWidth, msgWidth)
        let largerLeft  = max(titleLeft, msgLeft)
        
        //Set wrapper view's frame
        let wrapperWidth  = max(imageWidth + ToastHorizontalMargin * 2, largerLeft + largerWidth + ToastHorizontalMargin)
        let wrapperHeight = max(msgTop + msgHeight + ToastVerticalMargin, imageHeight + ToastVerticalMargin * 2)
        wrapperView.frame = CGRect(x: 0.0, y: 0.0, width: wrapperWidth, height: wrapperHeight)
        
        //Add subviews
        if titleLabel != nil {
            titleLabel!.frame = CGRect(x: titleLeft, y: titleTop, width: titleWidth, height: titleHeight)
            wrapperView.addSubview(titleLabel!)
        }
        if msgLabel != nil {
            msgLabel!.frame = CGRect(x: msgLeft, y: msgTop, width: msgWidth, height: msgHeight)
            wrapperView.addSubview(msgLabel!)
        }
        if imageView != nil {
            wrapperView.addSubview(imageView!)
        }
        
        return wrapperView
    }
}

extension String {
    func stringHeightWithFontSize(_ fontSize: CGFloat,width: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize: fontSize)
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping;
        let attributes = [kCTFontAttributeName:font,
                          kCTParagraphStyleAttributeName:paragraphStyle.copy()]
        
        let text = self as NSString
        let rect = text.boundingRect(with: size, options:.usesLineFragmentOrigin, attributes: attributes as [NSAttributedStringKey : Any], context:nil)
        return rect.size.height
    }
}


