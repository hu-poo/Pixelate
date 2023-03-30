//
//  UIImage+Extensions.swift
//  
//
//  Created by 尤坤 on 2023/3/30.
//

import UIKit

public extension UIImage {
    func covertToBitmap(width: Int, height: Int, colorSpace: CGColorSpace) -> CGImage? {
        guard let cgImage = cgImage else {
            return nil
        }

        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
            return nil
        }
        
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        context.draw(cgImage, in: rect)
        
        guard let data = context.data else {
            return nil
        }
        let provider = CGDataProvider(data: CFDataCreate(nil, data, bytesPerRow * height))
        let bitsPerPixel = bytesPerPixel * bitsPerComponent
        let colorRenderingIntent = CGColorRenderingIntent.defaultIntent
        let imageRef = CGImage(width: width, height: height, bitsPerComponent: bitsPerComponent, bitsPerPixel: bitsPerPixel, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo, provider: provider!, decode: nil, shouldInterpolate: true, intent: colorRenderingIntent)
        
        return imageRef
    }
    
    func covertToBitmap() -> CGImage? {
        guard let cgImage = cgImage else {
            return nil
        }
        let width = cgImage.width
        let height = cgImage.height
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        return covertToBitmap(width: width, height: height, colorSpace: colorSpace)
    }
    
    func writeToSavedPhotosAlbum() {
        UIImageWriteToSavedPhotosAlbum(self, nil, nil, nil)
    }
}
