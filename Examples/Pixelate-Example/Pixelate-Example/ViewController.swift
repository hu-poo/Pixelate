//
//  ViewController.swift
//  Pixelate-Example
//
//  Created by 尤坤 on 2023/3/29.
//

import UIKit
import Pixelate

class ViewController: UIViewController {
    lazy var metalView = {
        let view = MetalView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var dividerView: UIView = {
        let dividerView = UIView()
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        dividerView.backgroundColor = .lightGray
        return dividerView
    }()
    
    lazy var displayView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var controlView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var generateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Generate Striped Image", for: .normal)
        button.addTarget(self, action: #selector(generateStripedImage), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save to Album", for: .normal)
        button.addTarget(self, action: #selector(saveImageToAlbum), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(displayView)
        view.addSubview(dividerView)
        view.addSubview(controlView)

        displayView.addSubview(imageView)
        displayView.addSubview(metalView)
        controlView.addSubview(buttonStackView)
        
        buttonStackView.addArrangedSubview(generateButton)
        buttonStackView.addArrangedSubview(saveButton)
        
        // 设置子视图的约束
        NSLayoutConstraint.activate([
            displayView.topAnchor.constraint(equalTo: view.topAnchor),
            displayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            displayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            displayView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
            
            controlView.topAnchor.constraint(equalTo: displayView.bottomAnchor),
            controlView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controlView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            controlView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            metalView.topAnchor.constraint(equalTo: displayView.topAnchor),
            metalView.leadingAnchor.constraint(equalTo: displayView.leadingAnchor),
            metalView.trailingAnchor.constraint(equalTo: displayView.trailingAnchor),
            metalView.bottomAnchor.constraint(equalTo: displayView.bottomAnchor),

            // imageView 在 displayView 居中
            imageView.centerXAnchor.constraint(equalTo: displayView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: displayView.centerYAnchor),
            // imageView 的宽度不能超过屏幕宽度的 90%
            imageView.widthAnchor.constraint(lessThanOrEqualTo: displayView.widthAnchor, multiplier: 0.9),
            
            // 将 stackView 放在 controlView 中央
            buttonStackView.centerXAnchor.constraint(equalTo: controlView.centerXAnchor),
            buttonStackView.centerYAnchor.constraint(equalTo: controlView.centerYAnchor),

            // dividerView 的顶部距离 imageView 底部 20 点
            dividerView.topAnchor.constraint(equalTo: controlView.topAnchor),
            // dividerView 的左侧与父视图左侧对齐
            dividerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            // dividerView 的右侧与父视图右侧对齐
            dividerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // dividerView 的高度为 1 点
            dividerView.heightAnchor.constraint(equalToConstant: 1),
        ])
    }
    
    @objc
    func generateStripedImage() {
        // 生成一张 400x400 像素的条纹图
        let image = RawImage.stripedImage(width: 400, height: 400, color1: .red, color2: .green, format: .BGRA)
        
        // 将 RawImage 转换为 UIImage
        let uiImage = image?.toUIImage()
        
        // 显示生成的图像
        imageView.image = uiImage
    }
    
    @objc
    func saveImageToAlbum() {
        guard let image = imageView.image else {
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeMutableRawPointer?) {
        if let error = error {
            print("Error saving image: \(error.localizedDescription)")
        } else {
            print("Image saved successfully.")
        }
    }
}
