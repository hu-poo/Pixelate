//
//  MetalRenderer.swift
//  
//
//  Created by 尤坤 on 2023/3/31.
//

import Metal
import QuartzCore
import simd

public class MetalRenderer {
    private var device: MTLDevice
    private var commandQueue: MTLCommandQueue?
    private var pipelineState: MTLRenderPipelineState?
    private var vertexBuffer: MTLBuffer?
    private var texture: MTLTexture?
    private var drawableRenderDescriptor: MTLRenderPassDescriptor?
    
    public init(device: MTLDevice, pixelFormat: MTLPixelFormat) {
        self.device = device
        preparePipelineState(pixelFormat)
    }
    
    private func preparePipelineState(_ pixelFormat: MTLPixelFormat) {
        commandQueue = device.makeCommandQueue()
        
        drawableRenderDescriptor = MTLRenderPassDescriptor()
        drawableRenderDescriptor?.colorAttachments[0].loadAction = .clear
        drawableRenderDescriptor?.colorAttachments[0].storeAction = .store
        drawableRenderDescriptor?.colorAttachments[0].clearColor = MTLClearColorMake(255, 255, 255, 1)
        
        let quadVertices: [Vertex] = [
            Vertex(position: vector_float2(1, -1), textureCoordinate: vector_float2(1, 1)),
            Vertex(position: vector_float2(-1, -1), textureCoordinate: vector_float2(0, 1)),
            Vertex(position: vector_float2(-1, 1), textureCoordinate: vector_float2(0, 0)),
            Vertex(position: vector_float2(1, -1), textureCoordinate: vector_float2(1, 1)),
            Vertex(position: vector_float2(-1, 1), textureCoordinate: vector_float2(0, 0)),
            Vertex(position: vector_float2(1, 1), textureCoordinate: vector_float2(1, 0)),
        ]

        vertexBuffer = device.makeBuffer(bytes: quadVertices, length: MemoryLayout<Vertex>.stride * quadVertices.count, options: .storageModeShared)
        vertexBuffer?.label = "Quad"
        
        let library = try? device.makeDefaultLibrary(bundle: Bundle.module)
        let vertexFunction = library?.makeFunction(name: "vertexShader")
        let fragmentFunction = library?.makeFunction(name: "bgraFragmentShader")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.label = "MyPipeline"
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = pixelFormat
        
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            print("Error: Failed to create pipeline state: \(error)")
        }
    }
    
    public func setTexture(_ texture: MTLTexture) {
        self.texture = texture
    }
    
    public func render(to metalLayer: CAMetalLayer) {
        guard let drawable = metalLayer.nextDrawable() else {
            return
        }
        
        let commandBuffer = commandQueue?.makeCommandBuffer()
        
        drawableRenderDescriptor?.colorAttachments[0].texture = drawable.texture
        
        guard let pipelineState = pipelineState,
              let texture = texture else {
            return
        }
        
        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: drawableRenderDescriptor!)
        renderEncoder?.setRenderPipelineState(pipelineState)
        
        renderEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        renderEncoder?.setFragmentTexture(texture, index: 0)
        renderEncoder?.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 6)
        renderEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
