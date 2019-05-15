//
//  TrackingVideoVC.swift
//  VisionDemo
//
//  Created by admin on 2019/5/14.
//  Copyright © 2019 aaronni. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class TrackingVideoVC: BaseVideoVC {
    
    private var trackingObservation: VNDetectedObjectObservation?
    private let requestHandler = VNSequenceRequestHandler()

    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(pressScreen(_:)))
        tap.numberOfTapsRequired = 2
        previewView.addGestureRecognizer(tap)
        previewView.isUserInteractionEnabled = true
    }
    
    @objc private func pressScreen(_ sender: UITapGestureRecognizer) {
        let pt = sender.location(in: view)
        let size = CGSize(width: 120, height: 120)
        guard var convertRect = previewView.videoPreviewLayer?.metadataOutputRectConverted(fromLayerRect: CGRect(origin: pt, size: size)) else { return }
        convertRect.origin.y = 1 - convertRect.origin.y
        trackingObservation = VNDetectedObjectObservation(boundingBox: convertRect)
    }
    
    override func getRectLayer(box: VNDetectedObjectObservation, with size: CGSize) -> CALayer {
        var boundingBox = box.boundingBox
        boundingBox.origin.y = 1 - boundingBox.origin.y
        guard let rect = previewView.videoPreviewLayer?.layerRectConverted(fromMetadataOutputRect: boundingBox) else { return CALayer() }
        
        let layer = CALayer()
        layer.frame = rect
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.red.cgColor
        return layer
    }
}

//MARK: delegate func.
extension TrackingVideoVC {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        guard let target = trackingObservation else { return }
        
        let request = VNTrackObjectRequest(detectedObjectObservation: target, completionHandler: self.handleRectangles(request:error:))
        request.trackingLevel = .accurate
        
        do {
            try requestHandler.perform([request], on: pixelBuffer)
        } catch {
            print(error)
        }
    }
    
    private func handleRectangles(request: VNRequest, error: Error?) {
        guard let observation = request.results?.first as? VNDetectedObjectObservation else { return }
        DispatchQueue.main.async() {
            self.trackingObservation = observation
            self.previewView.layer.sublayers?.removeSubrange(1...)
            let size = self.previewView.frame.size
            self.drawBox(with: self.getRectLayer(box: observation, with: size))
        }
    }
}
