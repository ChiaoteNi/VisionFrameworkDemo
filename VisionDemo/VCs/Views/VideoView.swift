//
//  VideoView.swift
//  VisionDemo
//
//  Created by admin on 2019/5/12.
//  Copyright © 2019 aaronni. All rights reserved.
//

import UIKit
import AVFoundation

class VideoView: UIView {
    
    weak var delegate: AVCaptureVideoDataOutputSampleBufferDelegate?
    var cameraPosition: AVCaptureDevice.Position = .back
    
    private(set) var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        videoPreviewLayer?.frame = bounds
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        videoPreviewLayer?.frame = bounds
    }
    
    func run() {
        videoPreviewLayer?.session?.stopRunning()
        videoPreviewLayer?.removeFromSuperlayer()
        setupCapture(with: delegate, cameraPosition: cameraPosition)
        videoPreviewLayer?.session?.startRunning()
    }
    
    func stop() {
        videoPreviewLayer?.session?.stopRunning()
    }
    
    private func setupCapture(with delegate: AVCaptureVideoDataOutputSampleBufferDelegate?, cameraPosition: AVCaptureDevice.Position) {
        guard let delegate = delegate else { return }
        var captureDevice: AVCaptureDevice?
        for device in AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                       mediaType: .video,
                                                       position: cameraPosition).devices {
            guard device.position == cameraPosition else { continue }
            captureDevice = device
        }
        guard let device = captureDevice else { return }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            let session = AVCaptureSession()
            guard session.canAddInput(input) else { return }
            session.addInput(input)
            
            let output = AVCaptureVideoDataOutput()
            let queue = DispatchQueue(label: "buffer queue")
            output.setSampleBufferDelegate(delegate, queue: queue)
            guard session.canAddOutput(output) else { return }
            session.addOutput(output)
            session.sessionPreset = .high
            
            let videoPreviewLayer = AVCaptureVideoPreviewLayer(session:session)
            videoPreviewLayer.videoGravity = .resizeAspectFill
            layer.addSublayer(videoPreviewLayer)
            self.videoPreviewLayer = videoPreviewLayer
        } catch {
            print(error)
        }
    }
}
