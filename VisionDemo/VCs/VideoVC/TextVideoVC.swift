//
//  BaseVideoVC.swift
//  VisionDemo
//
//  Created by admin on 2019/5/13.
//  Copyright © 2019 aaronni. All rights reserved.
//

import UIKit
import Vision
import AVFoundation

class TextVideoVC: BaseVideoVC {
    
    override var cameraPosition: AVCaptureDevice.Position {
        return .back
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - delegate func.
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let orientation: CGImagePropertyOrientation = .init(UIDevice.current.orientation, position: cameraPosition)
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientation, options: [:])
        let textRequest = VNDetectTextRectanglesRequest(completionHandler: self.handleRectangles)
        textRequest.reportCharacterBoxes = true
        
        do {
            try imageRequestHandler.perform([textRequest])
        } catch {
            print(error)
        }
    }
    
    private func handleRectangles(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNTextObservation] else { return }
        DispatchQueue.main.async() {
            self.previewView.layer.sublayers?.removeSubrange(1...)
            let size = self.previewView.frame.size
            
            for observation in observations {
                guard let characterBoxes = observation.characterBoxes else { continue }
                guard characterBoxes.count >= 2 else { continue }
                self.drawBox(with: self.getRegionRectLayer(boxes: characterBoxes, with: size))
                
                for characterBox in characterBoxes {
                    self.drawBox(with: self.getRectLayer(box: characterBox, with: size))
                }
            }
        }
    }
}
