//
//  PhotoLibraryAuthorizationManager.swift
//  
//
//  Created by 尤坤 on 2023/3/30.
//

import Photos

//NSPhotoLibraryUsageDescription 是必需的权限描述，它用于请求用户授权访问照片库，包括读和写的权限。而 NSPhotoLibraryAddUsageDescription 是可选的权限描述，它用于请求用户授权访问照片库，但只包括写的权限，即用户只能向照片库中添加照片，无法读取照片库中的内容。
//如果只需要向照片库中添加照片，而无需读取照片库中的内容，可以只配置 NSPhotoLibraryAddUsageDescription。但如果需要读取和写入照片库中的内容，则需要同时配置 NSPhotoLibraryUsageDescription 和 NSPhotoLibraryAddUsageDescription。
//TODO: iOS 14之后引入了PHAccessLevel，将相册的权限分成了addOnly和readWrite，这里应该支持单独请求写权限

public class PhotoLibraryAuthorizationManager {
    public enum AuthorizationStatus {
        case notDetermined
        case authorized
        case denied
        case restricted
        case limited
    }
    
    public enum AccessLevel {
        case readWrite
        case addOnly
    }
    
    public typealias AuthorizationCompletionHandler = (AuthorizationStatus) -> Void
    
    public static let shared = PhotoLibraryAuthorizationManager()
    
    private init() {}
    
    public func currentAuthorizationStatus(for accessLevel: AccessLevel = .readWrite) -> AuthorizationStatus {
        if #available(iOS 14, *), accessLevel == .addOnly {
            let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
            switch status {
            case .notDetermined:
                return .notDetermined
            case .authorized:
                return .authorized
            case .denied:
                return .denied
            case .restricted:
                return .restricted
            case .limited:
                return .limited
            default:
                return .denied
            }
        } else {
            let status = PHPhotoLibrary.authorizationStatus()
            switch status {
            case .notDetermined:
                return .notDetermined
            case .authorized:
                return .authorized
            case .denied:
                return .denied
            case .restricted:
                return .restricted
            default:
                return .denied
            }
        }
    }
    
    public func requestAuthorization(for accessLevel: AccessLevel = .readWrite, completion: AuthorizationCompletionHandler?) {
        if #available(iOS 14, *) {
            let phLevel: PHAccessLevel = accessLevel == .addOnly ? .addOnly : .readWrite;
            let status = currentAuthorizationStatus(for: accessLevel)
            switch status {
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization(for: phLevel) { status in
                    DispatchQueue.main.async {
                        completion?(self.currentAuthorizationStatus(for: accessLevel))
                    }
                }
            default:
                completion?(status)
            }
        } else {
            let status = currentAuthorizationStatus()
            switch status {
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization { status in
                    DispatchQueue.main.async {
                        completion?(self.currentAuthorizationStatus(for: .readWrite))
                    }
                }
            default:
                completion?(status)
            }
        }
    }
}

