//
//  RecordViewController.swift
//  RND_VideoRecord
//
//  Created by wenjing on 2019/11/13.
//  Copyright © 2019 wenjing. All rights reserved.
//

import UIKit
import AVFoundation

class RecordViewController: UIViewController {
    
    let fileOutput = AVCaptureMovieFileOutput()
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.fileOutput.stopRecording()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
    }
    
    @objc func record(_ recordBtn: UIButton) {
        if self.fileOutput.isRecording == false {
            fileOutput.startRecording(to: URL(fileURLWithPath: self.getFileLocalPath()), recordingDelegate: self)
        }else {
            self.fileOutput.stopRecording()
        }
        recordBtn.isSelected = !recordBtn.isSelected
    }
}

extension RecordViewController: AVCaptureFileOutputRecordingDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        print("开始录制")
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print("完成录制-路径--\(outputFileURL)")
    }
    
}

extension RecordViewController {
    
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
