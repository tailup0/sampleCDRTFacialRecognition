//
//  CameraUtil.swift
//  sampleOpenCVRTFacialRecognition
//
//  Created by Muneharu Onoue on 2017/03/30.
//  Copyright © 2017年 Muneharu Onoue. All rights reserved.
//

import UIKit
import AVFoundation

class CameraUtil {
    // sampleBufferからUIImageへ変換
    class func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage {
        // サンプルバッファからピクセルバッファを取り出す
        let pixelBuffer:CVImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        
        // ピクセルバッファをベースにCoreImageのCIImageオブジェクトを作成
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        //CIImageからCGImageを作成
        let pixelBufferWidth = CGFloat(CVPixelBufferGetWidth(pixelBuffer))
        let pixelBufferHeight = CGFloat(CVPixelBufferGetHeight(pixelBuffer))
        let imageRect:CGRect = CGRect(x:0,y:0,width:pixelBufferWidth, height:pixelBufferHeight)
        let ciContext = CIContext()
        let cgimage = ciContext.createCGImage(ciImage, from: imageRect)
        
        // CGImageからUIImageを作成
        let image = UIImage(cgImage: cgimage!)
        return image
    }
    
}
