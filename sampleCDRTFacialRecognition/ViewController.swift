//
//  ViewController.swift
//  sampleCDRTFacialRecognition
//
//  Created by Muneharu Onoue on 2017/03/28.
//  Copyright © 2017年 Muneharu Onoue. All rights reserved.
//

import UIKit
import CoreImage
import AVFoundation

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    @IBOutlet weak var myImage: UIImageView!
    var mySession : AVCaptureSession!
    var myDevice : AVCaptureDevice!
    var myOutput : AVCaptureVideoDataOutput!

    override func viewDidLoad() {
        super.viewDidLoad()
        guard initCamera() else { return }
        mySession.startRunning()

    }
    
    func initCamera() -> Bool {
        // セッションの作成.
        mySession = AVCaptureSession()
        
        // 解像度の指定.
        mySession.sessionPreset = AVCaptureSessionPresetHigh
//        mySession.sessionPreset = AVCaptureSessionPresetMedium
        
        
        myDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .back)
        guard myDevice != nil else { return false }
        
        // バックカメラからVideoInputを取得.
        guard let myInput = try? AVCaptureDeviceInput(device: myDevice) else { return false }
        
        // セッションに追加.
        guard mySession.canAddInput(myInput) else { return false }
        mySession.addInput(myInput)
        
        // 出力先を設定
        myOutput = AVCaptureVideoDataOutput()
        myOutput.videoSettings = [ kCVPixelBufferPixelFormatTypeKey as AnyHashable: Int(kCVPixelFormatType_32BGRA) ]
        
        // FPSを設定
        guard let _ = try? myDevice.lockForConfiguration() else { return false }
//        myDevice.activeVideoMinFrameDuration = CMTimeMake(1, 15)
        myDevice.activeVideoMinFrameDuration = CMTimeMake(1, 30)
        myDevice.unlockForConfiguration()
        
        // デリゲートを設定
//        let queue = DispatchQueue(label: "myqueue")
//        let queue = DispatchQueue(label: "myqueue", attributes: .concurrent)
        let queue = DispatchQueue.global()
        myOutput.setSampleBufferDelegate(self, queue: queue)
        
        
        // 遅れてきたフレームは無視する
        myOutput.alwaysDiscardsLateVideoFrames = true
        
        // セッションに追加.
        guard mySession.canAddOutput(myOutput) else { return false }
        mySession.addOutput(myOutput)
        
        // カメラの向きを合わせる
        for connection in myOutput.connections {
            guard let conn = connection as? AVCaptureConnection else { continue }
            guard conn.isVideoOrientationSupported else { continue }
            conn.videoOrientation = .portrait
        }
        
        return true
    }

    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        let image = CameraUtil.imageFromSampleBuffer(sampleBuffer: sampleBuffer)
        let faceImage = detectFace(image: image)
        // 顔認識
        DispatchQueue.main.async {
            // 表示
        // uiimageへ変換
            self.myImage.image = faceImage
        }
    }

    func detectFace(image: UIImage) -> UIImage {
        let options : [String: String] = [
            CIDetectorAccuracy:CIDetectorAccuracyLow,
        ]
        
        let detector : CIDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: options)!

        let faces :[CIFeature] = detector.features(in: CIImage(cgImage: image.cgImage!))
        
        let transform : CGAffineTransform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -image.size.height)
        UIGraphicsBeginImageContextWithOptions(image.size, true, 1)
        
//        let width = Int(image.size.width)
//        let height = Int(image.size.height)
//        let bitsPerComponent = 8
//        let bytesPerRow = width*4
//        let space = CGColorSpaceCreateDeviceRGB()
//        let bitmapInfo: UInt32 = CGImageAlphaInfo.noneSkipFirst.rawValue
//        let bitmapInfo: UInt32 = 8198
        
        let drawCtxt = UIGraphicsGetCurrentContext()!
//        let drawCtxt = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: space, bitmapInfo: bitmapInfo)!

        image.draw(at: CGPoint.zero)
//        drawCtxt.draw(image.cgImage!, in: CGRect(origin: CGPoint.zero, size: image.size))
        
        for feature in faces {
            let faceRect : CGRect = feature.bounds.applying(transform)
//            let faceRect : CGRect = feature.bounds
            drawCtxt.setStrokeColor(UIColor.red.cgColor)
            drawCtxt.stroke(faceRect)
        }

        let faceImage = UIGraphicsGetImageFromCurrentImageContext()!
//        let faceImage = UIImage(cgImage: drawCtxt.makeImage()!)
        UIGraphicsEndImageContext()
        return faceImage
    }

}
extension CGContext {
    func showInfo() {
        print("data")
        print(data!)
        print("width")
        print(width)
        print("height")
        print(height)
        print("bitsPerComponent")
        print(bitsPerComponent)
        print("bytesPerRow")
        print(bytesPerRow)
        print("bitsPerPixel")
        print(bitsPerPixel)
        print("model")
        print(colorSpace!.model.rawValue)
        print("bitmapInfo")
        print(bitmapInfo)
    }
}
