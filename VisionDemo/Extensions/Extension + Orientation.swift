//
//  Extension + Orientation.swift
//  VisionDemo
//
//  Created by admin on 2019/5/13.
//  Copyright © 2019 aaronni. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

extension CGImagePropertyOrientation {
    init(_ uiImageOrientation: UIImage.Orientation) {
        switch uiImageOrientation {
        case .up:               self = .up
        case .down:             self = .down
        case .left:             self = .left
        case .right:            self = .right
        case .upMirrored:       self = .upMirrored
        case .downMirrored:     self = .downMirrored
        case .leftMirrored:     self = .leftMirrored
        case .rightMirrored:    self = .rightMirrored
        @unknown default:       self = .right
        }
    }
    
    // 不是絕對，請依照自己需求情境調整
    init(_ orientation: UIDeviceOrientation, position: AVCaptureDevice.Position) {
        switch orientation {
        case .portraitUpsideDown:
            self = .left
        case .landscapeLeft:
            self = position == .front ? .down : .up
        case .landscapeRight:
            self = position == .front ? .up : .down
        default:
            self = position == .front ? .leftMirrored : .right
        }
    }
}
