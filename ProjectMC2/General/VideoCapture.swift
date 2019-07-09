//
//  VideoCapture.swift
//  ProjectMC2
//
//  Created by Randy Noel on 08/07/19.
//  Copyright © 2019 whiteHat. All rights reserved.
//

import AVFoundation
import UIKit
import CoreVideo

public protocol VideoCaptureDelegate: class {
    func videoCapture(_ capture: VideoCapture, didCaptureVideoFrame: CVPixelBuffer?, timedtamp:CMTime)
}

public class VideoCapture: NSObject {
    public var previewLayer: AVCaptureVideoPreviewLayer?
    public weak var delegate: VideoCaptureDelegate?
    public var fps = 15
    
    let captureSession = AVCaptureSession()
    let videoOutput = AVCaptureVideoDataOutput()
    let queue = DispatchQueue(label: "com.whiteHat98.camera-queue")
    
    var lastTimeStamp = CMTime()
    
    public func setUp(sessionPreset: AVCaptureSession.Preset = .vga640x480, completion: @escaping (Bool)->Void){
        self.setUpCamera(SessionPreset: sessionPreset) { success in
            completion(success)
        }
        
    }
    
    func setUpCamera(SessionPreset: AVCaptureSession.Preset, completion: @escaping (_ success:Bool)-> Void){
        
        captureSession.beginConfiguration()
        captureSession.sessionPreset = SessionPreset
        
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("error: no video device available")
            return
        }
        
        guard let videoInput = try? AVCaptureDeviceInput(device: captureDevice) else {
            print("error: ccould not create AVCaptureDeviceInput")
            return
        }
        
        if captureSession.canAddInput(videoInput){
            captureSession.addInput(videoInput)
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        previewLayer.connection?.videoOrientation = .portrait
        self.previewLayer = previewLayer
        
        let settings: [String : Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32BGRA),
        ]
        
        videoOutput.videoSettings = settings
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self as! AVCaptureVideoDataOutputSampleBufferDelegate, queue: queue)
        if captureSession.canAddOutput(videoOutput){
            captureSession.addOutput(videoOutput)
        }
        
        videoOutput.connection(with: AVMediaType.video)?.videoOrientation = .portrait
        
        captureSession.commitConfiguration()
        
        let success = true
        completion(success)
        
    }
    
    public func start(){
        if !captureSession.isRunning{
            captureSession.startRunning()
        }
    }
    
    public func stop(){
        if captureSession.isRunning{
            captureSession.stopRunning()
        }
    }
}

extension VideoCapture : AVCaptureVideoDataOutputSampleBufferDelegate{
    public func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        let deltaTime = timestamp - lastTimeStamp
        if deltaTime >=  CMTimeMake(value: 1, timescale: Int32(fps)){
            lastTimeStamp = timestamp
            let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
            delegate?.videoCapture(self, didCaptureVideoFrame: imageBuffer, timedtamp: timestamp)
        }
    }
    
}

