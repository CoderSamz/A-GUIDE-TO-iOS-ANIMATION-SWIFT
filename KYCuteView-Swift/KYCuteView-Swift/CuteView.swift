//
//  CuteView.swift
//  CuteView-Swift
//
//  Created by Kitten Yang on 1/19/16.
//  Copyright © 2016 Kitten Yang. All rights reserved.
//

import UIKit

struct BubbleOptions {
    var text: String = ""
    var bubbleWidth: CGFloat = 0.0
    var viscosity: CGFloat = 0.0
    var bubbleColor: UIColor = UIColor.white
}

class CuteView: UIView {
    
    var frontView: UIView?
    var bubbleOptions: BubbleOptions!{
        didSet{
            bubbleLabel.text = bubbleOptions.text
        }
    }
    private var bubbleLabel: UILabel!
    private var containerView: UIView!
    private var cutePath: UIBezierPath!
    private var fillColorForCute: UIColor!
    private var animator: UIDynamicAnimator!
    private var snap: UISnapBehavior!
    private var backView: UIView!
    private var shapeLayer: CAShapeLayer!
    
    private var r1: CGFloat = 0.0
    private var r2: CGFloat = 0.0
    private var x1: CGFloat = 0.0
    private var y1: CGFloat = 0.0
    private var x2: CGFloat = 0.0
    private var y2: CGFloat = 0.0
    private var centerDistance: CGFloat = 0.0
    private var cosDigree: CGFloat = 0.0
    private var sinDigree: CGFloat = 0.0
    
    private var pointA = CGPoint.zero
    private var pointB = CGPoint.zero
    private var pointC = CGPoint.zero
    private var pointD = CGPoint.zero
    private var pointO = CGPoint.zero
    private var pointP = CGPoint.zero
    
    private var initialPoint: CGPoint = CGPoint.zero
    private var oldBackViewFrame: CGRect = CGRect.zero
    private var oldBackViewCenter: CGPoint = CGPoint.zero

    
    init(point: CGPoint, superView: UIView, options: BubbleOptions) {
        super.init(frame: CGRect(x: point.x, y: point.y, width: options.bubbleWidth, height: options.bubbleWidth))
        bubbleOptions = options
        initialPoint = point
        containerView = superView
        containerView.addSubview(self)
        setUp()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func drawRect() {
        guard let frontView = frontView else{
            return
        }
        x1 = backView.center.x
        y1 = backView.center.y
        x2 = frontView.center.x
        y2 = frontView.center.y
        
        let xtimesx = (x2-x1)*(x2-x1)
        centerDistance = sqrt(xtimesx + (y2-y1)*(y2-y1))
        if centerDistance == 0 {
            cosDigree = 1
            sinDigree = 0
        }else{
            cosDigree = (y2-y1)/centerDistance
            sinDigree = (x2-x1)/centerDistance
        }
        
        r1 = oldBackViewFrame.size.width / 2 - centerDistance/bubbleOptions.viscosity
        
        pointA = CGPoint(x: x1-r1*cosDigree, y: y1+r1*sinDigree) // A
        pointB = CGPoint(x: x1+r1*cosDigree, y: y1-r1*sinDigree) // B
        pointD = CGPoint(x: x2-r2*cosDigree, y: y2+r2*sinDigree) // D
        pointC = CGPoint(x: x2+r2*cosDigree, y: y2-r2*sinDigree) // C
        pointO = CGPoint(x: pointA.x + (centerDistance / 2)*sinDigree, y: pointA.y + (centerDistance / 2)*cosDigree)
        pointP = CGPoint(x: pointB.x + (centerDistance / 2)*sinDigree, y: pointB.y + (centerDistance / 2)*cosDigree)
        
        backView.center = oldBackViewCenter;
        backView.bounds = CGRect(x: 0, y: 0, width: r1*2, height: r1*2);
        backView.layer.cornerRadius = r1;
        
        cutePath = UIBezierPath()
        cutePath.move(to: pointA)
        cutePath.addQuadCurve(to: pointD, controlPoint: pointO)
        cutePath.addLine(to: pointC)
        cutePath.addQuadCurve(to: pointB, controlPoint: pointP)
        cutePath.move(to: pointA)
        
        if backView.isHidden == false {
            shapeLayer.path = cutePath.cgPath
            shapeLayer.fillColor = fillColorForCute.cgColor
            containerView.layer.insertSublayer(shapeLayer, below: frontView.layer)
        }

    }
    
    private func setUp() {
        shapeLayer = CAShapeLayer()
        backgroundColor = UIColor.clear
        frontView = UIView(frame: CGRect(x: initialPoint.x, y: initialPoint.y, width: bubbleOptions.bubbleWidth, height: bubbleOptions.bubbleWidth))
        guard let frontView = frontView else {
            print("frontView is nil")
            return
        }
        r2 = frontView.bounds.size.width / 2.0
        frontView.layer.cornerRadius = r2
        frontView.backgroundColor = bubbleOptions.bubbleColor
        
        backView = UIView(frame: frontView.frame)
        r1 = backView.bounds.size.width / 2
        backView.layer.cornerRadius = r1
        backView.backgroundColor = bubbleOptions.bubbleColor
        
        bubbleLabel = UILabel()
        bubbleLabel.frame = CGRect(x: 0, y: 0, width: frontView.bounds.width, height: frontView.bounds.height)
        bubbleLabel.textColor = UIColor.white
        bubbleLabel.textAlignment = .center
        bubbleLabel.text = bubbleOptions.text
        
        frontView.insertSubview(bubbleLabel, at: 0)
        containerView.addSubview(backView)
        containerView.addSubview(frontView)
        
        x1 = backView.center.x
        y1 = backView.center.y
        x2 = frontView.center.x
        y2 = frontView.center.y
        
        pointA = CGPoint(x: x1-r1, y: y1);   // A
        pointB = CGPoint(x: x1+r1, y: y1);  // B
        pointD = CGPoint(x: x2-r2, y: y2);  // D
        pointC = CGPoint(x: x2+r2, y: y2);  // C
        pointO = CGPoint(x: x1-r1, y: y1);   // O
        pointP = CGPoint(x: x2+r2, y: y2);  // P
        
        oldBackViewFrame = backView.frame
        oldBackViewCenter = backView.center
        
        backView.isHidden = true //为了看到frontView的气泡晃动效果，需要暂时隐藏backView
        addAniamtionLikeGameCenterBubble()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleDragGesture(ges: )))
        frontView.addGestureRecognizer(panGesture)
    }
    
    @objc private func handleDragGesture(ges: UIPanGestureRecognizer) {
        let dragPoint = ges.location(in: containerView)
        if ges.state == .began {
            // 不给r1赋初始值的话，如果第一次拖动使得r1少于6，第二次拖动就直接隐藏绘制路径了
            r1 = oldBackViewFrame.width / 2
            backView.isHidden = false
            fillColorForCute = bubbleOptions.bubbleColor
            removeAniamtionLikeGameCenterBubble()
        } else if ges.state == .changed {
            frontView?.center = dragPoint
            if r1 <= 6 {
                fillColorForCute = UIColor.clear
                backView.isHidden = true
                shapeLayer.removeFromSuperlayer()
            }
            drawRect()
        } else if ges.state == .ended || ges.state == .cancelled || ges.state == .failed {
            backView.isHidden = true
            fillColorForCute = UIColor.clear
            shapeLayer.removeFromSuperlayer()
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.0, options: [.curveEaseInOut], animations: { [weak self] () -> Void in
                if let strongsSelf = self {
                    strongsSelf.frontView?.center = strongsSelf.oldBackViewCenter
                }
                }, completion: { [weak self] (finished) -> Void in
                    if let strongsSelf = self {
                        strongsSelf.addAniamtionLikeGameCenterBubble()
                    }
            })
        }
    }
    
}

// MARK : GameCenter Bubble Animation

extension CuteView {
    private func addAniamtionLikeGameCenterBubble() {
        let pathAnimation = CAKeyframeAnimation(keyPath: "position")
        pathAnimation.calculationMode = CAAnimationCalculationMode.paced

        pathAnimation.fillMode = CAMediaTimingFillMode.forwards
        pathAnimation.isRemovedOnCompletion = false
        pathAnimation.repeatCount = Float.infinity
        pathAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        pathAnimation.duration = 5.0
        
        
        guard let frontView = frontView else {
            print("frontView is nil!")
            return
        }
        let circleContainer = frontView.frame.insetBy(dx: frontView.bounds.width / 2 - 3, dy: frontView.bounds.size.width / 2 - 3)

        let curvedPath = CGMutablePath(ellipseIn: circleContainer, transform: nil)
    
        pathAnimation.path = curvedPath
        frontView.layer.add(pathAnimation, forKey: "circleAnimation")
        
        let scaleX = CAKeyframeAnimation(keyPath: "transform.scale.x")
        scaleX.duration = 1.0
        scaleX.values = [NSNumber(value: 1.0),NSNumber(value: 1.1),NSNumber(value: 1.0)]
        scaleX.keyTimes = [NSNumber(value: 0.0), NSNumber(value: 0.5), NSNumber(value: 1.0)]
        scaleX.repeatCount = Float.infinity
        scaleX.autoreverses = true
        
        scaleX.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        frontView.layer.add(scaleX, forKey: "scaleXAnimation")
        
        let scaleY = CAKeyframeAnimation(keyPath: "transform.scale.y")
        scaleY.duration = 1.5
        scaleY.values = [NSNumber(value: 1.0),NSNumber(value: 1.1),NSNumber(value: 1.0)]
        scaleY.keyTimes = [NSNumber(value: 0.0), NSNumber(value: 0.5), NSNumber(value: 1.0)]
        scaleY.repeatCount = Float.infinity
        scaleY.autoreverses = true
        scaleY.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        frontView.layer.add(scaleY, forKey: "scaleYAnimation")

    }

    private func removeAniamtionLikeGameCenterBubble() {
        if let frontView = frontView {
            frontView.layer.removeAllAnimations()
        }
    }
    
}
