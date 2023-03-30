//
//  MetalView.swift
//  RawReader
//
//  Created by Archie on 2022/2/14.
//

import MetalKit

public class MetalView: UIView {
    private var metalLayer: CAMetalLayer { return self.layer as! CAMetalLayer }
    private var device: MTLDevice?
    private var renderer: MetalRenderer?
    
    var startTime: CFTimeInterval = 0
    
    public override init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        
        initCommon()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        initCommon()
    }
    
    public override class var layerClass: AnyClass {
        return CAMetalLayer.self
    }

    private func initCommon() {
        guard let device = MTLCreateSystemDefaultDevice() else { return }
        self.device = device
        
        guard let rawImage = RawImage.stripedImage(width: 400, height: 400, color1: .red, color2: .green, format: .Gray), let texture = rawImage.toTexture(device: device) else { return }
        
        metalLayer.device = device
        metalLayer.pixelFormat = rawImage.pixelFormat
        metalLayer.framebufferOnly = true
        
//        guard let rawImage = convertUIImageToRRRawImage() else { return }
//        guard let rawImage = createCustomRawData(width: 100, height: 100, format: .gray) else { return }
        renderer = MetalRenderer(device: device, pixelFormat: rawImage.pixelFormat)
        renderer?.setTexture(texture)
        
        let displayLink = CADisplayLink(target: self, selector: #selector(handleDisplayLink))
        displayLink.add(to: .current, forMode: .default)
    }
    
    public override func display(_ layer: CALayer) {
        renderOnEvent()
    }

    public override func draw(_ layer: CALayer, in ctx: CGContext) {
        renderOnEvent()
    }
    
    public override func draw(_ dirtyRect: CGRect) {
        super.draw(dirtyRect)
        renderOnEvent()
    }
    
    @objc func handleDisplayLink() {
        renderOnEvent()
    }
    
    func renderOnEvent() {
        renderer?.render(to: metalLayer)
    }
}
