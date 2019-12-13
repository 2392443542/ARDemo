//
//  RecordWithDataViewController.swift
//  RND_VideoRecord
//
//  Created by wenjing on 2019/11/19.
//  Copyright © 2019 wenjing. All rights reserved.
//

import UIKit
import AVFoundation

class RecordWithDataViewController: UIViewController {
    
    let fileOutput = AVCaptureVideoDataOutput()
     
    
    var writer: AVAssetWriter? //将媒体数据写入指定的文件类型
     var writerInput: AVAssetWriterInput?  //
     var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?  //像素缓冲适配器
     var currentSeconds = 0
     var currentTime: CMTime = .invalid
     var initialTime: CMTime = .invalid
    var queue = DispatchQueue(label: "faceTracking")
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        self.fileOutput.stopRecording()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fileOutput.setSampleBufferDelegate(self, queue: queue)
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        // 设置视频的input
        guard  let videoDevice = AVCaptureDevice.default(for: .video) else { fatalError("无相机") }
//        videoDevice.position = AVCaptureDevice.Position.front
//        AVCaptureDevice.default(<#T##deviceType: AVCaptureDevice.DeviceType##AVCaptureDevice.DeviceType#>, for: <#T##AVMediaType?#>, position: AVCaptureDevice.Position.front)

        guard let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else { fatalError("添加输入设备失败") }
        guard captureSession.canAddInput(videoInput) else {fatalError("添加视频输入设备到会话失败") }
        captureSession.addInput(videoInput)
        
        //设置音频录制的input
        guard  let audioDevice = AVCaptureDevice.default(for: .audio) else { fatalError("无音频硬件") }
        guard let audioInput = try? AVCaptureDeviceInput(device: audioDevice) else { fatalError("添加音频输入设备失败") }
        guard captureSession.canAddInput(audioInput) else {fatalError("添加音频输入设备到会话失败") }
        captureSession.addInput(audioInput)
        
//
          guard captureSession.canAddOutput(fileOutput) else { fatalError("添加视频输出源失败") }
//        guard let captureConnection = fileOutput.connection(with: .muxed) else {  fatalError("获取输入输出的链接失败")  }
                  //设置视频录制方向和预览层一致
//                  captureConnection.videoOrientation = videoPreView.connection?.videoOrientation ?? .portraitUpsideDown
//          fileOutput.setOutputSettings([AVVideoCodecKey: AVVideoCodecType.hevc], for: captureConnection)
        
          captureSession.addOutput(fileOutput)
        
        //创建视频预览
        let videoPreView = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreView.frame = UIScreen.main.bounds
        self.view.layer.addSublayer(videoPreView)
        captureSession.startRunning()

        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let recordButton = UIButton(frame: CGRect(x: (screenWidth-50)/2, y: screenHeight-100, width: 50, height: 50))
        recordButton.setTitle("录制", for: .normal)
        recordButton.setTitle("完成", for: .selected)
        recordButton.backgroundColor = UIColor.red
        recordButton.addTarget(self, action: #selector(record), for: .touchUpInside)
        recordButton.layer.cornerRadius = 25
        recordButton.layer.masksToBounds = true
        self.view.addSubview(recordButton)
        self.initWrite()
        
    }
    
    @objc func record(_ recordBtn: UIButton) {
//        if self.fileOutput.isRecording == false {
//            fileOutput.startRecording(to: URL(fileURLWithPath: self.getFileLocalPath()), recordingDelegate: self)
//        }else {
//            self.fileOutput.stopRecording()
//        }
        recordBtn.isSelected = !recordBtn.isSelected
        
        self.startRecording()
    }
    
    
    
     func initWrite()  {
            let pathUrl = URL(fileURLWithPath: self.getFileLocalPath())
            guard let writer = try? AVAssetWriter(outputURL: pathUrl, fileType: .mov) else { fatalError("创建写入器失败") }
             self.writer = writer
            guard let writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: [AVVideoCodecKey: AVVideoCodecType.h264,AVVideoWidthKey:UIScreen.main.bounds.width,AVVideoHeightKey:UIScreen.main.bounds.height]) as? AVAssetWriterInput else { fatalError("创建输入对象失败") }
//        writerInput.
             self.writerInput = writerInput
              self.writer?.add(self.writerInput!)
            pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput, sourcePixelBufferAttributes: [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA])
            self.initialTime = self.getCurrentCMTime()
    //        PixelFormatType
        }
    
    func startRecording() {
         self.writer?.startWriting()
         self.writer?.startSession(atSourceTime: CMTime.zero)
     }
}

extension RecordWithDataViewController: AVCaptureFileOutputRecordingDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        print("开始录制")
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print("完成录制-路径--\(outputFileURL)")
    }
    
}

extension RecordWithDataViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//          CFRetain(sampleBuffer);
        
        if self.writer?.status == AVAssetWriter.Status.unknown {
            
            self.startRecording()
        }
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return  }
        let time = CMSampleBufferGetDuration(sampleBuffer)
        let success  =  self.pixelBufferAdaptor?.append(pixelBuffer, withPresentationTime: CMTime(value: time.value, timescale: 600))
//        if  self.writerInput?.isReadyForMoreMediaData == true {
//            let success = self.writerInput?.append(sampleBuffer)
            print(success)
//        }
      
//          CFRelease(sampleBuffer);
    }
    
    func getCurrentCMTime() -> CMTime {
           return CMTimeMakeWithSeconds(CACurrentMediaTime(), preferredTimescale: 1000);
       }
       
       func getAppendTime() -> CMTime {
           self.currentTime = CMTimeSubtract(self.getCurrentCMTime(), self.initialTime);
             return self.currentTime;
       }
}

extension RecordWithDataViewController {
    
    func getFileLocalPath() -> String {
        
        guard let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last else {
            return ""
        }
        let timeTempStr = self.getTimeTemp()
        let videoPath = documentPath.appending("/\(timeTempStr).mov")
        return videoPath
    }
    
    
    func getTimeTemp() -> String {
        
        let currentDate = Date(timeIntervalSinceNow: 0)
        let timeTemp = currentDate.timeIntervalSince1970*1000
        let timeTempStr = String(format: "%f", timeTemp)
        return timeTempStr
    }
}
