//
//  RawImage.swift
//  
//
//  Created by 尤坤 on 2023/3/30.
//

import UIKit
import Metal

public class RawImage {
    public enum RawImageFormat {
        case Gray
        case BGRA
        case RGBA
    }
    
    public var width: Int = 0
    public var height: Int = 0
    public var format: RawImageFormat = .RGBA
    public var data: UnsafeMutableRawPointer? = nil
    
    public var pixelFormat: MTLPixelFormat {
        switch format {
        case .Gray:
            return .r8Unorm
        case .BGRA:
            return .bgra8Unorm
        case .RGBA:
            return .rgba8Unorm
        }
    }
    
    public var bytesPerPixel: Int {
        switch format {
        case .Gray:
            return 1
        default:
            return 4
        }
    }
    
    public init() {}
    
    public init(width: Int, height: Int, format: RawImageFormat, data: UnsafeMutableRawPointer) {
        self.width = width
        self.height = height
        self.format = format
        self.data = data
    }
    
    deinit {
        destroy()
    }
    
    public func destroy() {
        if let data = data {
            data.deallocate()
            self.data = nil
        }
    }
}

public extension RawImage {
    static func stripedImage(width: Int, height: Int, color1: UIColor, color2: UIColor, format: RawImage.RawImageFormat) -> RawImage? {
        let bytesPerPixel: Int
        let bytesPerRow: Int
        
        switch format {
        case .Gray:
            bytesPerPixel = 1
            bytesPerRow = bytesPerPixel * width
        case .BGRA:
            bytesPerPixel = 4
            bytesPerRow = bytesPerPixel * width
        case .RGBA:
            bytesPerPixel = 4
            bytesPerRow = bytesPerPixel * width
        }
        
        let dataSize = width * height * bytesPerPixel
        let data = UnsafeMutableRawPointer.allocate(byteCount: dataSize, alignment: bytesPerPixel)
        
        for y in 0..<height {
            let row = data.advanced(by: y * bytesPerRow).assumingMemoryBound(to: UInt32.self)
            let isEvenRow = y % 2 == 0
            
            for x in 0..<width {
                let color: UIColor = (x % 2 == 0) == isEvenRow ? color1 : color2
                let rgba = color.rgba
                
                if format == .Gray {
                    let gray = UInt8(round(0.2989 * CGFloat(rgba >> 16 & 0xff) + 0.5870 * CGFloat(rgba >> 8 & 0xff) + 0.1140 * CGFloat(rgba & 0xff)))
                    row[x] = UInt32(gray)
                } else {
                    row[x] = rgba
                }
            }
        }
        
        return RawImage(width: width, height: height, format: format, data: data)
    }
}

public extension RawImage {
    func toUIImage() -> UIImage? {
        guard let data = data else {
            return nil
        }
        
        let bytesPerRow = bytesPerPixel * width
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        guard let context = CGContext(data: data, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
            return nil
        }
        
        guard let cgImage = context.makeImage() else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    func toTexture(device: MTLDevice) -> MTLTexture? {
        guard let data = data else {
            return nil
        }
        
        let rowBytes = width * bytesPerPixel
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: pixelFormat, width: width, height: height, mipmapped: false)
        let texture = device.makeTexture(descriptor: textureDescriptor)
        
        texture?.replace(region: MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0, withBytes: data, bytesPerRow: rowBytes)
        
        return texture
    }
}
