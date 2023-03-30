//
//  ShaderTypes.swift
//  
//
//  Created by 尤坤 on 2023/3/31.
//

import simd

@objc
enum VertexInputIndex: Int {
    case vertices = 0
    case uniforms = 1
}

@objc
enum TextureIndex: Int {
    case baseColor = 0
}

struct Vertex {
    var position: SIMD2<Float>
    var textureCoordinate: SIMD2<Float>
    
    init(position: SIMD2<Float>, textureCoordinate: SIMD2<Float>) {
        self.position = position
        self.textureCoordinate = textureCoordinate
    }
}

struct Uniforms {
    var scale: Float
    var viewportSize: vector_uint2
    
    init(scale: Float, viewportSize: vector_uint2) {
        self.scale = scale
        self.viewportSize = viewportSize
    }
}

