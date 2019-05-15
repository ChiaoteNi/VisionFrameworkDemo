//
//  CameraVC.swift
//  VisionDemo
//
//  Created by admin on 2019/5/12.
//  Copyright © 2019 aaronni. All rights reserved.
//

import UIKit
import Vision
import TesseractOCR

typealias CameraDelegate = UIImagePickerControllerDelegate & UINavigationControllerDelegate

class CameraVC: BaseVC {
    
    @IBOutlet private weak var inputImgView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        inputImgView.contentMode = .scaleToFill
    }
    
    @IBAction private func takePicture() {
        showCamera()
    }
    
    private func showCamera() {
        let cameraVC = UIImagePickerController()
        cameraVC.delegate = self
        cameraVC.sourceType = .camera
        cameraVC.cameraCaptureMode = .photo
        cameraVC.showsCameraControls = true
        present(cameraVC, animated: true, completion: nil)
    }
    
    private func drawBox(with layer: CALayer?) {
        guard let boxLayer = layer else { return }
        inputImgView.layer.addSublayer(boxLayer)
    }
    
    // MARK: - regonize text
    private func regonizedTxt(with characterBox: VNRectangleObservation, for image: UIImage?, mode: G8PageSegmentationMode, completion: (_ result: String)->Void) {
        guard let image = image else { return }
        let boxRect = transferBoxRect(with: characterBox, in: image.size)
        let txtImg = image.cropped(in: boxRect)
        recognize(with: txtImg, mode: mode, completion: completion)
    }
    
    private func recognize(with image: UIImage, mode: G8PageSegmentationMode, completion: (_ result: String)->Void) {
        guard let tesseract: G8Tesseract = G8Tesseract.init(language: "eng") else { return }
//        tesseract.charBlacklist = "qazwsxedcrfvtgbyhnujmikolpQAZWSXEDCRFVTGBYHNUJIKOLP"
        tesseract.charWhitelist = "0123456789"
        tesseract.engineMode = .tesseractOnly
        tesseract.pageSegmentationMode = mode
        tesseract.image = image
        tesseract.maximumRecognitionTime = 20
        tesseract.recognize()
        guard let txt = tesseract.recognizedText?// else { return }
            .replacingOccurrences(of: "\n", with: "") else { return }
//            .replacingOccurrences(of: "I", with: "1")
//            .replacingOccurrences(of: "O", with: "0")
//            .replacingOccurrences(of: "o", with: "0")
//            .replacingOccurrences(of: "i", with: "1") else { return }
        completion(txt)
    }
}

extension CameraVC: CameraDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            guard let uiImage = (info[.originalImage] as? UIImage)?.fixOrientation() else { return }
            guard let ciImage = CIImage.init(image: uiImage) else { return }
            
            self.inputImgView.image = uiImage
            self.inputImgView.layer.sublayers?.removeSubrange(1...)

            let orientation: CGImagePropertyOrientation = .init(uiImage.imageOrientation)
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            let request = VNDetectTextRectanglesRequest(completionHandler: self.handleRectangles)
            request.reportCharacterBoxes = true
            
            DispatchQueue.global(qos: .userInteractive).async {
                do {
                    try handler.perform([request])
                } catch {
                    print(error)
                }
            }
            picker.dismiss(animated: true)
        }
    }
    
    private func handleRectangles(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNTextObservation] else { return }
        DispatchQueue.main.async {
            let size = self.inputImgView.frame.size
            
            for observation in observations {
                guard let characterBoxes = observation.characterBoxes else { continue }
                guard characterBoxes.count >= 3, characterBoxes.count <= 21 else { continue }
                self.drawBox(with: self.getRegionRectLayer(boxes: characterBoxes, with: size))
                self.regonizedTxt(with: observation,
                                  for: self.inputImgView.image,
                                  mode: .singleLine,
                                  completion: { txt in print(txt) })
                
                for characterBox in characterBoxes {
                    self.drawBox(with: self.getRectLayer(box: characterBox, with: size))
                    self.regonizedTxt(with: characterBox,
                                      for: self.inputImgView.image,
                                      mode: .singleLine,
                                      completion: { txt in print(txt) })
                }
            }
        }
    }
}
