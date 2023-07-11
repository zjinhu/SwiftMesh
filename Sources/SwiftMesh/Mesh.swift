//
//  MeshManager.swift
//  SwiftMesh
//
//  Created by iOS on 2019/12/26.
//  Copyright © 2019 iOS. All rights reserved.
//
import Foundation
import Alamofire

public class Mesh: ObservableObject {

    /// 可观测下载进度0--1
    @Published public var downloadProgress: Float = 0
    
    /// 可观测上传进度0--1
    @Published public var uploadProgress: Float = 0
    
    public static let shared = Mesh()
    
    public enum LogLevel {
        case off
        case debug
        case info
        case error
    }
    
    public var log: LogLevel
    
    private init() {
        log = .off
        startLogging()
    }
    
    deinit {
        stopLogging()
    }
    
    var globalHeaders: HTTPHeaders?
    var defaultParameters: [String: Any]?
    
    // MARK: 设置全局 headers
    /// 设置全局 headers
    /// - Parameter headers:全局 headers
    public func setGlobalHeaders(_ headers: HTTPHeaders?) {
        globalHeaders = headers
    }
    // MARK: 设置默认参数
    /// 设置默认参数
    /// - Parameter parameters: 默认参数
    public func setDefaultParameters(_ parameters: [String: Any]?) {
        defaultParameters = parameters
    }
}

