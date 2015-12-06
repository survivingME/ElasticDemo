//
//  ViewController.swift
//  ElasticDemo
//
//  Created by survivingME on 15/11/15.
//  Copyright © 2015年 survivingME. All rights reserved.
//

import UIKit

extension UIView {
    func dg_center(usePresentationLayerIfPossible:Bool) -> CGPoint {
        if usePresentationLayerIfPossible,let presentationLayer = layer.presentationLayer() as? CALayer {
            return presentationLayer.position
        }
        return center
    }
}

class ViewController: UIViewController {
    
    private let minimalHeight:CGFloat = 100.0
    private let shapeLayer = CAShapeLayer()
    private let maxWaveHeight:CGFloat = 100.0
    private let l1ControlPointView = UIView()
    private let l2ControlPointView = UIView()
    private let l3ControlPointView = UIView()
    private let cControlPointView = UIView()
    private let r1ControlPointView = UIView()
    private let r2ControlPointView = UIView()
    private let r3ControlPointView = UIView()
    
    private var displayLink: CADisplayLink!
    
    private var animating = false {
        didSet {
            view.userInteractionEnabled = !animating
            displayLink.paused = !animating
        }
    }
    private func currentPath() -> CGPath {
        let width = view.bounds.width
        
        let bezierPath = UIBezierPath()
        
        bezierPath.moveToPoint(CGPoint(x : 0.0, y : 0.0))
        bezierPath.addLineToPoint(CGPoint(x : 0.0, y : l3ControlPointView.dg_center(animating).y))
        bezierPath.addCurveToPoint(l1ControlPointView.dg_center(animating), controlPoint1: l3ControlPointView.dg_center(animating), controlPoint2: l2ControlPointView.dg_center(animating))
        bezierPath.addCurveToPoint(r1ControlPointView.dg_center(animating), controlPoint1: cControlPointView.dg_center(animating), controlPoint2: r1ControlPointView.dg_center(animating))
        bezierPath.addCurveToPoint(r3ControlPointView.dg_center(animating), controlPoint1: r1ControlPointView.dg_center(animating), controlPoint2: r2ControlPointView.dg_center(animating))
        bezierPath.addLineToPoint(CGPoint(x: width, y: 0.0))
        
        bezierPath.closePath()
        
        return bezierPath.CGPath
    }
    func updateShapeLayer() {
        shapeLayer.path = currentPath()
    }
    private func layoutControlPoints(baseHeight baseHeight:CGFloat,waveHeight : CGFloat,locationX : CGFloat) {
        let width = view.bounds.width
        let minLeftX = min((locationX - width / 2.0) * 0.28,0.0)
        let maxRightX = max(width + (locationX - width / 2.0) * 0.28, width)
        let leftPartWidth = locationX - minLeftX
        let rightPartWidth = maxRightX - locationX
        l3ControlPointView.center = CGPoint(x : minLeftX, y : baseHeight)
        l2ControlPointView.center = CGPoint(x : minLeftX + leftPartWidth * 0.44, y : baseHeight)
        l1ControlPointView.center = CGPoint(x : minLeftX + leftPartWidth * 0.71, y : baseHeight + waveHeight * 0.64)
        cControlPointView.center = CGPoint(x : locationX, y : baseHeight + waveHeight * 1.36)
        r1ControlPointView.center = CGPoint(x : maxRightX - rightPartWidth * 0.71, y : baseHeight + waveHeight * 0.64)
        r2ControlPointView.center = CGPoint(x : maxRightX - rightPartWidth * 0.44, y : baseHeight)
        r3ControlPointView.center = CGPoint(x : maxRightX,y : baseHeight)
    }
    
    override func loadView() {
        super.loadView()
        
        shapeLayer.frame = CGRect(x:0.0,y:0.0,width: view.bounds.width,height:minimalHeight)
        shapeLayer.fillColor = UIColor(red: 218/255.0, green: 112/255.0, blue: 214/255.0, alpha: 1.0).CGColor
        shapeLayer.actions = ["position":NSNull(),"bounds":NSNull(),"path":NSNull()]
        view.layer.addSublayer(shapeLayer)
        
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "panGestureDidMove:"))
        
        
        l3ControlPointView.frame = CGRect(x : 0.0,y : 0.0,width : 3.0,height : 3.0)
        l2ControlPointView.frame = CGRect(x : 0.0,y : 0.0,width : 3.0,height : 3.0)
        l1ControlPointView.frame = CGRect(x : 0.0,y : 0.0,width : 3.0,height : 3.0)
        cControlPointView.frame = CGRect(x : 0.0,y : 0.0,width : 3.0,height : 3.0)
        r1ControlPointView.frame = CGRect(x : 0.0,y : 0.0,width : 3.0,height : 3.0)
        r2ControlPointView.frame = CGRect(x : 0.0,y : 0.0,width : 3.0,height : 3.0)
        r3ControlPointView.frame = CGRect(x : 0.0,y : 0.0,width : 3.0,height : 3.0)
        
        /*l3ControlPointView.backgroundColor = .redColor()
        l2ControlPointView.backgroundColor = .redColor()
        l1ControlPointView.backgroundColor = .redColor()
        cControlPointView.backgroundColor = .redColor()
        r1ControlPointView.backgroundColor = .redColor()
        r2ControlPointView.backgroundColor = .redColor()
        r3ControlPointView.backgroundColor = .redColor()*/
        
        view.addSubview(l3ControlPointView)
        view.addSubview(l2ControlPointView)
        view.addSubview(l1ControlPointView)
        view.addSubview(cControlPointView)
        view.addSubview(r1ControlPointView)
        view.addSubview(r2ControlPointView)
        view.addSubview(r3ControlPointView)
        
        layoutControlPoints(baseHeight: minimalHeight, waveHeight: 0.0, locationX: view.bounds.width / 2.0)
        updateShapeLayer()
        
        displayLink = CADisplayLink(target: self, selector: Selector("updateShapeLayer"))
        
        displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        displayLink.paused = true
    }
    
    func panGestureDidMove(gesture:UIPanGestureRecognizer) {
        if gesture.state == .Ended || gesture.state == .Failed || gesture.state == .Cancelled {
            let centerY = minimalHeight
            
            animating = true
            UIView.animateWithDuration(0.9, delay: 0.0, usingSpringWithDamping: 0.57,initialSpringVelocity: 0.0, options: [],animations: { () ->Void in
                self.l3ControlPointView.center.y = centerY
                self.l2ControlPointView.center.y = centerY
                self.l1ControlPointView.center.y = centerY
                self.cControlPointView.center.y = centerY
                self.r1ControlPointView.center.y = centerY
                self.r2ControlPointView.center.y = centerY
                self.r3ControlPointView.center.y = centerY
                }, completion:  { _ in
                    self.animating = false
            })
            
        } else {
            let additionHeight = max(gesture.translationInView(view).y,0)
            let waveHeight = min(additionHeight * 0.6,maxWaveHeight)
            let baseHeight = minimalHeight + additionHeight - waveHeight
            let locationX = gesture.locationInView(view).x
            layoutControlPoints(baseHeight: baseHeight, waveHeight: waveHeight, locationX: locationX)
            updateShapeLayer()
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

