//
//  ViewController.swift
//  MiBack
//
//  Created by 荆文征 on 2018/9/3.
//  Copyright © 2018年 com.jwz. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private let layer = MiBackShapeLayer()
    private let mibackPan = UIScreenEdgePanGestureRecognizer()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.layer.addSublayer(layer)
        
        mibackPan.edges = .left
        mibackPan.addTarget(self, action: #selector(mibackPanHandleMethod(pan:)))
        self.view.addGestureRecognizer(mibackPan)
    }


}


extension ViewController{
    
    @objc func mibackPanHandleMethod(pan: UIScreenEdgePanGestureRecognizer){
        
        switch pan.state {
        case .began,.changed:
            layer.updateLayer(by: pan.location(in: pan.view))
        default:
            layer.recoveryLayer(by: pan.location(in: pan.view))
        }
        
        print("--")
    }
}


private class MiBackShapeLayer:CAShapeLayer,CAAnimationDelegate{
    
    /// layer的上下 增量 基于屏幕的高度进行评测
    let increment:CGFloat = 60
    let maxPointX:CGFloat = 30
    
    
    let arrowLayer = CAShapeLayer()
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init() {
        
        super.init()
        
        self.fillColor = UIColor.black.withAlphaComponent(0.6).cgColor
        
//        self.backgroundColor = UIColor.black.withAlphaComponent(0.6).cgColor
        
        //        self.addSublayer(arrowLayer)
    }
    
    func updateLayer(by point:CGPoint){
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: point.y - increment))
        
        path.addQuadCurve(to: CGPoint(x: 0, y: point.y + increment), controlPoint: CGPoint(x: min(point.x, maxPointX), y: point.y))
        
        self.path = path.cgPath
        self.layoutIfNeeded()
    }
    
    func recoveryLayer(by point:CGPoint) {

        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: point.y - increment))
        path.addQuadCurve(to: CGPoint(x: 0, y: point.y + increment), controlPoint: CGPoint(x: 0, y: point.y))
        
        let recoveryAnimation = CABasicAnimation(keyPath: "path")
        
        recoveryAnimation.toValue = path.cgPath
        recoveryAnimation.duration = 0.2
        
        recoveryAnimation.delegate = self
        
        self.add(recoveryAnimation, forKey: "path")
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        self.path = UIBezierPath().cgPath
    }
}
