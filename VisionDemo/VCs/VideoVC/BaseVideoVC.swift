//
//  BaseVideoVC.swift
//  VisionDemo
//
//  Created by admin on 2019/5/12.
//  Copyright © 2019 aaronni. All rights reserved.
//

import UIKit
import Vision
import AVFoundation
import SwiftOCR

class BaseVideoVC: BaseVC, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var previewView: VideoView!
    
    var cameraPosition: AVCaptureDevice.Position {
        return .back
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        previewView.isUserInteractionEnabled = false
        showCamera()
    }
    
    func drawBox(with layer: CALayer?) {
        guard let boxLayer = layer else { return }
        previewView.layer.addSublayer(boxLayer)
    }
    
    private func showCamera() {
        previewView.delegate = self
        previewView.cameraPosition = cameraPosition
        previewView.run()
    }
}
