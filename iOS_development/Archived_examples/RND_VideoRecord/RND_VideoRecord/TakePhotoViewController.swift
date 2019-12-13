//
//  TakePhotoViewController.swift
//  RND_VideoRecord
//
//  Created by wenjing on 2019/11/13.
//  Copyright © 2019 wenjing. All rights reserved.
//

import UIKit
import AVFoundation

class TakePhotoViewController: UIViewController {
    
    let captureSession = AVCaptureSession()
    let photoOutput = AVCapturePhotoOutput()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var photoSettings:AVCapturePhotoSettings? //相机的设置
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Select a depth-capable capture device.
        // builtInTrueDepthCamera 普通拍照，builtInTrueDepthCamera 深度照片
        guard let videoDevice = AVCaptureDevice.default(.builtInTrueDepthCamera,
                                                        for: .video, position: .front)
            else { fatalError("No dual camera.") }
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
            self.captureSession.canAddInput(videoDeviceInput)
            else { fatalError("Can't add video input.") }
        self.captureSession.addInput(videoDeviceInput)
        
        // Set up photo output for depth data capture.
        guard self.captureSession.canAddOutput(photoOutput)
            else { fatalError("Can't add photo output.") }
        self.captureSession.addOutput(photoOutput)
        self.captureSession.sessionPreset = .photo
        photoOutput.isDepthDataDeliveryEnabled = photoOutput.isDepthDataDeliverySupported
        
        self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        self.videoPreviewLayer?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.view.layer.addSublayer(self.videoPreviewLayer!)
        self.captureSession.beginConfiguration()
        self.captureSession.commitConfiguration()
        self.captureSession.startRunning()
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let takeButton = UIButton(frame: CGRect(x: (screenWidth-50)/2, y: screenHeight-100, width: 50, height: 50))
        takeButton.setTitle("拍照", for: .normal)
        takeButton.backgroundColor = UIColor.red
        takeButton.addTarget(self, action: #selector(takePicture), for: .touchUpInside)
        self.view.addSubview(takeButton)
    }
    
    @objc func takePicture() {
        //设置拍照格式
        let photoSetting = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        photoSetting.isDepthDataDeliveryEnabled = photoOutput.isDepthDataDeliverySupported
        self.photoOutput.capturePhoto(with: photoSetting, delegate: self)
    }
}

extension TakePhotoViewController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        print("深度数据---\(String(describing: photo.depthData))")
        guard  let imageData = photo.fileDataRepresentation() , let image = UIImage(data: imageData) else {
            print("转换失败")
            return
        }
        //保存到相册
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(image:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(image: UIImage, didFinishSavingWithError: NSError?, contextInfo: AnyObject) {
        
        
        if didFinishSavingWithError != nil {
            print("保存失败")
            return
        }
        print("保存成功")
    }
    
}
