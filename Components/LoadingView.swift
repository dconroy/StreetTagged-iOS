//
//  LoadingView.swift
//  StreetTagged
//
//  Created by John O'Sullivan on 1/17/20.
//  Copyright © 2020 John O'Sullivan. All rights reserved.
//

import Foundation
import UIKit

public enum LoadingType {
    case large
    case small
}

class SpinningLoading: UIView {
    public var color:UIColor = UIColor.red
    public var lineWidth:CGFloat = 3
    public var duration:Double = 1
    
    lazy var bView: UIView = {
        let bView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        bView.backgroundColor = UIColor.clear
        setAnimation(view: bView, isReturn: false)
        setLayer(view: bView)
        return bView
    }()
    
    
    lazy var sView: UIView = {
        let sView = UIView(frame: CGRect(x: 10, y: 10, width: frame.width - 20, height: frame.height - 20))
        sView.backgroundColor = UIColor.clear
        setAnimation(view: sView, isReturn: true)
        setLayer(view: sView)
        return sView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clear
        
    }
    
    func setup(color:UIColor) {
        self.color = color
        addSubview(bView)
        addSubview(sView)
    }
    
    func setAnimation(view:UIView,isReturn:Bool) {
        let rotation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        if isReturn {
            rotation.toValue = -Double.pi * 2
        }else{
            rotation.toValue = Double.pi * 2
        }
        rotation.duration = duration
        rotation.isCumulative = true
        rotation.repeatCount = Float.greatestFiniteMagnitude
        view.layer.add(rotation, forKey: "rotationAnimation")
    }
    
    func setLayer(view:UIView) {
        
        let layerView = CAShapeLayer()
        
        let path = UIBezierPath()
        
        let radius: Double = Double(view.frame.width) / 2 - 20
        
        let center = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)
        
        path.move(to: CGPoint(x: center.x + CGFloat(radius), y: center.y))
        
        for i in stride(from: 0, to: 220.0, by: 1) {
            // radians = degrees * PI / 180
            let radians = i * Double.pi / 180
            
            let x = Double(center.x) + radius * cos(radians)
            let y = Double(center.y) + radius * sin(radians)
            
            path.addLine(to: CGPoint(x: x , y: y))
        }
        
        layerView.path = path.cgPath
        layerView.fillColor = UIColor.clear.cgColor
        layerView.lineWidth = lineWidth
        layerView.strokeColor = color.cgColor
        view.layer.addSublayer(layerView)
    }
    
}

open class LoadingView: UIView {
    var overlayView:UIView!
    
    public var colorBackground:UIColor = .clear
    public var isBlurEffect = true
    public var loadingType: LoadingType = .large
    public var duration:Double = 1
    private var label: UILabel?
    
    public func show(view:UIView?,color:UIColor = UIColor.red) {
        self.frame = view!.frame
        self.backgroundColor = UIColor.clear
        overlayView = UIView()
        overlayView.frame = view!.frame
        overlayView.backgroundColor = colorBackground
        
        if isBlurEffect {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = frame
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            overlayView.addSubview(blurEffectView)
        }
        
        var size:CGFloat = 90
        var lineWidth:CGFloat = 3
        
        switch loadingType {
        case .large:
            size = 90
            lineWidth = 3
        case .small:
            size = 75
            lineWidth = 2
        }
        
        let loading = SpinningLoading(frame: CGRect(x: view!.center.x - (size/2), y: view!.center.y - (size/2), width: size, height: size))
        loading.duration = duration
        loading.lineWidth = lineWidth
        loading.setup(color: color)
        overlayView.addSubview(loading)
        
        label = UILabel(frame: CGRect(x: view!.center.x - (size/2), y: view!.center.y - (size/2), width: (size * 3), height: size))
        label!.center = CGPoint(x: view!.center.x, y: view!.center.y - 60)
        label!.textAlignment = NSTextAlignment.center
        label!.textColor = .white
        overlayView.addSubview(label!)
        view!.addSubview(overlayView)
    }
    
    public func hide() {
        if overlayView != nil {
            overlayView.removeFromSuperview()
        }
    }
    
    public func setColorBackground(color:UIColor){
        colorBackground = color
    }
    
    public func setTitle(text:String){
        label!.text = text
    }
    
    public func setBackgroundBlurEffect(){
        isBlurEffect = true
    }
}
