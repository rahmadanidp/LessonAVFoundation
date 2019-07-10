//
//  ViewController.swift
//  LessonAVFoundationCamera
//
//  Created by Rahmadani Pratiwi on 10/07/19.
//  Copyright © 2019 Rahmadani Pratiwi. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    let captureSession = AVCaptureSession()
    var previewView = PreviewView()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var photoOutput = AVCapturePhotoOutput()
    var outputImageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        askCameraPermission { (granted) in
            if granted {
                DispatchQueue.main.async {
                    self.setupView()
                    
                    DispatchQueue.global().async {
                        self.configureSession()
                    }
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func configureSession() {
        captureSession.beginConfiguration()
        captureSession.commitConfiguration()
        
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice), captureSession.canAddInput(videoDeviceInput) else { return }
        captureSession.addInput(videoDeviceInput)
        
        guard captureSession.canAddOutput(photoOutput) else { return }
        captureSession.sessionPreset = .photo
        captureSession.addOutput(photoOutput)
        
        DispatchQueue.main.async {
            self.previewView.videoPreviewLayer.session = self.captureSession
            self.captureSession.startRunning()
        }
    }
    
    func setupView() {
        
        view.backgroundColor = .black
        
        let xPosition = (UIScreen.main.bounds.width / 2.0) - 40
        let yPosition = UIScreen.main.bounds.height - 170.0
        let buttonRect = CGRect(x: xPosition, y: yPosition, width: 80, height: 80)
        let buttonShoot = UIButton(frame: buttonRect)
        
        buttonShoot.backgroundColor = .white
        buttonShoot.layer.cornerRadius = buttonShoot.frame.width / 2
        buttonShoot.layer.masksToBounds = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(buttonShootDidTap))
        buttonShoot.addGestureRecognizer(tap)
        
        view.addSubview(buttonShoot)
        
        previewView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 650)
        
        outputImageView.frame = CGRect(x: (xPosition / 2) - 25, y: yPosition + 10, width: 50, height: 50)
        outputImageView.layer.borderColor = UIColor.gray.cgColor
        outputImageView.layer.borderWidth = 1
        outputImageView.layer.masksToBounds = true
        outputImageView.contentMode = .scaleAspectFill
        view.addSubview(outputImageView)
        view.addSubview(previewView)
    }
    
    @objc func buttonShootDidTap() {
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func askCameraPermission(completion: @escaping (Bool)->()) {
        AVCaptureDevice.requestAccess(for: .video) { (granted) in
            if !granted {
                let alert = UIAlertController(title: "Message", message: "If you want to use this feature please give permission to open camera from Setting", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    alert.dismiss(animated: true, completion: nil)
                    completion(false)
                })
                alert.addAction(alertAction)
                self.present(alert, animated: true, completion: nil)
            } else {
                completion(true)
            }
        }
    }

}

extension ViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        let image = UIImage(data: imageData)
        outputImageView.image = image
    }
}

class PreviewView: UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}

