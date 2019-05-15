//
//  BaseVC.swift
//  UIBezierPathDemo
//
//  Created by Chiao-Te Ni on 2018/7/21.
//  Copyright © 2018年 aaron. All rights reserved.
//

import UIKit
import Vision

class BaseVC: UIViewController {
    
    var closeBtn: UIButton = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        closeBtn.setTitle("", for: .normal)
        closeBtn.setImage(#imageLiteral(resourceName: "closeBtn"), for: .normal)
        closeBtn.frame = CGRect(x: UIScreen.main.bounds.width - 30, y: 30, width: 20, height: 20)
        closeBtn.addTarget(self, action: #selector(close), for: UIControl.Event.allEvents)
        view.insertSubview(closeBtn, at: 0)
    }
    
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
    
    func getRegionRectLayer(boxes: [VNRectangleObservation]?, with size: CGSize) -> CALayer? {
        guard let boxes = boxes else { return nil }
        var xMin: CGFloat = 9999.0
        var xMax: CGFloat = 0.0
        var yMin: CGFloat = 9999.0
        var yMax: CGFloat = 0.0
        
        // 用charBoxes調整observation顯示範圍
        for char in boxes {
            xMin = min(xMin, char.bottomLeft.x)
            xMax = max(xMax, char.bottomRight.x)
            yMin = min(yMin, char.bottomRight.y)
            yMax = max(yMax, char.topRight.y)
        }
        
        let layer = CALayer()
        layer.frame = transferBoxRect(maxX: xMax, minX: xMin, maxY: yMax, minY: yMin, size: size)
        layer.borderWidth = 2.0
        layer.borderColor = UIColor.green.cgColor
        return layer
    }
    
    func getRectLayer(box: VNDetectedObjectObservation, with size: CGSize) -> CALayer {
        let layer = CALayer()
        layer.frame = transferBoxRect(with: box, in: size)
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.blue.cgColor
        return layer
    }
    
    // 座標轉換方法一
    func transferBoxRect(maxX: CGFloat, minX: CGFloat, maxY: CGFloat, minY: CGFloat, size: CGSize) -> CGRect {
        let x = minX * size.width
        let y = (1 - maxY) * size.height
        let width = (maxX - minX) * size.width
        let height = (maxY - minY) * size.height
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    // 座標轉換方法二
    func transferBoxRect(with box: VNDetectedObjectObservation, in size: CGSize) -> CGRect {
//        if let box = box as? VNRectangleObservation {
//            return transferBoxRect(maxX: box.topRight.x,
//                                   minX: box.topLeft.x,
//                                   maxY: box.topLeft.y,
//                                   minY: box.bottomLeft.y,
//                                   size: size)
//        } else {
            let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -size.height)
            let translate = CGAffineTransform.identity.scaledBy(x: size.width, y: size.height)
            return box.boundingBox.applying(translate).applying(transform)
//        }
    }
}
