//
//  FaceVideoVC.swift
//  VisionDemo
//
//  Created by admin on 2019/5/13.
//  Copyright © 2019 aaronni. All rights reserved.
//

import UIKit
import Vision
import AVFoundation

class FaceVideoVC: BaseVideoVC {
    
    override var cameraPosition: AVCaptureDevice.Position {
        return .front
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func drawFaceLandMark(on targetLayer: CALayer, landMarkRegion: VNFaceLandmarkRegion2D?, isClosed: Bool = true) {
        guard let landMarkRegion = landMarkRegion else { return }
        let rect = targetLayer.bounds
        let points = landMarkRegion.pointsInImage(imageSize: rect.size)
        
        guard let path = getPath(with: points) else { return }
        let mirrorOverYOrigin = CGAffineTransform.init(scaleX: 1.0, y: -1.0)
        let translate = CGAffineTransform.init(translationX: 0, y: rect.height)
        path.apply(mirrorOverYOrigin)
        path.apply(translate)
        
        let line: CAShapeLayer = .init()
        line.path = path.cgPath
        line.strokeColor = UIColor.orange.cgColor
        line.borderWidth = 0.3
        line.fillColor = UIColor.white.withAlphaComponent(0).cgColor
        targetLayer.addSublayer(line)
    }
    
    private func getPath(with pts: [CGPoint], isClosed: Bool = true) -> UIBezierPath? {
        guard let firstPt = pts.first else { return nil }
        let path = UIBezierPath()
        path.move(to: firstPt)
        
        for pt in pts {
            path.addLine(to: pt)
        }
        
        if isClosed {
            path.close()
        }
        return path
    }
}

// MARK: - delegate func.
extension FaceVideoVC {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let orientation: CGImagePropertyOrientation = .init(UIDevice.current.orientation, position: cameraPosition)
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientation, options: [:])
        let request = VNDetectFaceLandmarksRequest(completionHandler: self.handleRectangles)
        
        do {
            try imageRequestHandler.perform([request])
        } catch {
            print(error)
        }
    }
    
    private func handleRectangles(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNFaceObservation] else { return }
        
        DispatchQueue.main.async() {
            self.previewView.layer.sublayers?.removeSubrange(1...)
            let size = self.previewView.frame.size
            
            for observation in observations {
                self.drawBox(with: self.getRectLayer(box: observation, with: size))
                self.drawFaceLandMark(on: self.previewView.layer, landMarkRegion: observation.landmarks?.nose, isClosed: false)
                self.drawFaceLandMark(on: self.previewView.layer, landMarkRegion: observation.landmarks?.noseCrest, isClosed: false)
                self.drawFaceLandMark(on: self.previewView.layer, landMarkRegion: observation.landmarks?.medianLine, isClosed: false)
                self.drawFaceLandMark(on: self.previewView.layer, landMarkRegion: observation.landmarks?.leftEye)
                self.drawFaceLandMark(on: self.previewView.layer, landMarkRegion: observation.landmarks?.leftPupil)
                self.drawFaceLandMark(on: self.previewView.layer, landMarkRegion: observation.landmarks?.leftEyebrow, isClosed: false)
                self.drawFaceLandMark(on: self.previewView.layer, landMarkRegion: observation.landmarks?.rightEye)
                self.drawFaceLandMark(on: self.previewView.layer, landMarkRegion: observation.landmarks?.rightPupil)
                self.drawFaceLandMark(on: self.previewView.layer, landMarkRegion: observation.landmarks?.rightEyebrow, isClosed: false)
                self.drawFaceLandMark(on: self.previewView.layer, landMarkRegion: observation.landmarks?.innerLips)
                self.drawFaceLandMark(on: self.previewView.layer, landMarkRegion: observation.landmarks?.outerLips)
                self.drawFaceLandMark(on: self.previewView.layer, landMarkRegion: observation.landmarks?.faceContour, isClosed: false)
            }
        }
    }
}
