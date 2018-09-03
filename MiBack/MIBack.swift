//
//  MIBack.swift
//  MiBack
//
//  Created by 荆文征 on 2018/9/3.
//  Copyright © 2018年 com.jwz. All rights reserved.
//

import UIKit

protocol MIBackGestureRecognizerProtocol {
    
    /// 是否 Mi Back
    func miBackDidBack()
}

extension MIBackGestureRecognizerProtocol where Self: UIViewController{
    
    func miBackInitialization(){
        
        let layer = MiBackShapeLayer(miback: self)
        
        self.mibackLayer = layer
        self.view.layer.addSublayer(layer)
        
        self.makeMiBackMethod()
    }
}

extension UIViewController{
    
    fileprivate func makeMiBackMethod() {
        
        let screenEdgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(mibackPanHandleMethod(pan:)))
        screenEdgePanGestureRecognizer.edges = .left
        self.view.addGestureRecognizer(screenEdgePanGestureRecognizer)
    }
    
    /// 存储
    fileprivate struct MIBackLayerKeys {
        static var layer = "MIBackLayerKeys_mibackLayer"
    }
    
    fileprivate var mibackLayer: MiBackShapeLayer? {
        set {
            if let newValue = newValue { objc_setAssociatedObject(self, &MIBackLayerKeys.layer, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN) }
        }
        get {
            return objc_getAssociatedObject(self, &MIBackLayerKeys.layer) as? MiBackShapeLayer
        }
    }
    
    @objc fileprivate func mibackPanHandleMethod(pan: UIScreenEdgePanGestureRecognizer){
        
        guard let layer = mibackLayer else { return }
        
        switch pan.state {
        case .began,.changed: layer.updateLayer(by: pan.location(in: pan.view))
        default: layer.recoveryLayer(by: pan.location(in: pan.view))
        }
    }
}

private class MiBackShapeLayer:CAShapeLayer,CAAnimationDelegate{
    
    /// layer的上下 增量 基于屏幕的高度进行评测
    private let increment:CGFloat
    private let maxPointX:CGFloat = 30 // 被牵扯的最大的宽度
    
    private let pointUnder:CGFloat = 10    /// 山底上下距离
    private let pointUnderWidth:CGFloat = -3    /// 山底 左右
    
    private let pointDrumtopWitdh:CGFloat = 6 /// 针对山顶的 左右艰巨
    private let pointDrumtop:CGFloat = 15 // 山顶的 上下艰巨
    
    private let miBackProtocol:MIBackGestureRecognizerProtocol
    
    /// 箭头 Layer
    private let arrowLayer = CAShapeLayer()
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(miback: MIBackGestureRecognizerProtocol) {
        
        miBackProtocol = miback
        increment = UIScreen.main.bounds.height/8
        
        super.init()
        
        self.fillColor = UIColor.black.withAlphaComponent(0.6).cgColor
        
        arrowLayer.fillColor = UIColor.clear.cgColor
        arrowLayer.strokeColor = UIColor.white.cgColor
        self.addSublayer(arrowLayer)
    }
    
    /// 修改 正在滑动状态的 Layer的 Path
    ///
    /// - Parameter point: 滑动的触发 Point
    fileprivate func updateLayer(by point:CGPoint){
        
        let realPoint = CGPoint(x: min(maxPointX, point.x), y: point.y)
        
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: 0, y: realPoint.y - increment))
        path.addQuadCurve(to: CGPoint(x: realPoint.x - pointDrumtopWitdh, y: realPoint.y - pointDrumtop), controlPoint: CGPoint(x: pointUnderWidth, y: realPoint.y - increment + pointUnder)) // 绘制上方山坡
        
        path.addQuadCurve(to: CGPoint(x: realPoint.x - pointDrumtopWitdh, y: realPoint.y + pointDrumtop), controlPoint: realPoint) // 绘制山顶
        
        path.addQuadCurve(to: CGPoint(x: 0, y: realPoint.y + increment), controlPoint: CGPoint(x: pointUnderWidth, y: realPoint.y + increment - pointUnder)) // 绘制下方 山坡
        
        self.path = path.cgPath
        
        updateArrowMethod(by: realPoint)
    }
    
    /// 修改 结束滑动状态的layer的 Path
    ///
    /// - Parameter point: 结束或者失败时的 触发 Point
    fileprivate func recoveryLayer(by point:CGPoint) {
        
        let realPoint = CGPoint(x: min(maxPointX, point.x), y: point.y)
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: realPoint.y - increment))
        path.addQuadCurve(to: CGPoint(x: 0, y: realPoint.y - pointDrumtop), controlPoint: CGPoint(x: 0, y: realPoint.y - increment + pointUnder))
        path.addQuadCurve(to: CGPoint(x: 0, y: realPoint.y + pointDrumtop), controlPoint: CGPoint(x: 0, y: realPoint.y))
        path.addQuadCurve(to: CGPoint(x: 0, y: realPoint.y + increment), controlPoint: CGPoint(x: 0, y: realPoint.y + increment - pointUnder))
        
        let recoveryAnimation = CABasicAnimation(keyPath: "path")
        
        recoveryAnimation.toValue = path.cgPath
        recoveryAnimation.duration = 0.2
        
        recoveryAnimation.delegate = self
        
        self.add(recoveryAnimation, forKey: "path")
        
        updateArrowMethod(by: CGPoint(x: 0, y: realPoint.y))
        
        if point.x >= maxPointX/2 {
            
            miBackProtocol.miBackDidBack() // block
        }
    }
    
    /// 当动画结束 重新配置 Path
    fileprivate func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        self.path = UIBezierPath().cgPath
    }
    
    /// 修改肩头 Path 方法
    fileprivate func updateArrowMethod(by point:CGPoint)  {
        
        let progress = max(0, min(1, point.x / maxPointX))
        
        let afterProgress = max(0, min(1, (progress - 0.5)/0.5))
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: point.x/2 - 2 + 2*afterProgress, y: point.y-5))
        path.addLine(to: CGPoint(x: point.x/2 - 2 - 2*afterProgress, y: point.y))
        path.addLine(to: CGPoint(x: point.x/2 - 2 + 2*afterProgress, y: point.y + 5))
        
        arrowLayer.path = path.cgPath
    }
}
