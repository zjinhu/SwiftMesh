//
//  MeshManager.swift
//  SwiftMesh
//
//  Created by iOS on 2019/12/26.
//  Copyright © 2019 iOS. All rights reserved.
//
import Foundation
import Alamofire

public typealias ConfigClosure = (_ config: Config) -> Void

public class Mesh {
    
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
    
    private var globalHeaders: HTTPHeaders?
    private var defaultParameters: [String: Any]?
    
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

extension Mesh{
    ///私有方法
    func mergeConfig(_ config: Config){
        ///设置默认参数
        var param = defaultParameters ?? [:]
        param.merge(config.parameters ?? [:]) { (_, new) in new}
        config.parameters = param
        ///设置默认header
        guard let headers = globalHeaders else {
            return
        }
        
        if let _ = config.addHeads{
            
        }else{
            config.addHeads = []
        }
        
        headers.forEach {
            config.addHeads?.update($0)
        }
    }
    
    func handleError(error: AFError) -> Error {
        if let underlyingError = error.underlyingError {
            let nserror = underlyingError as NSError
            let code = nserror.code
            if code == NSURLErrorNotConnectedToInternet ||
                code == NSURLErrorTimedOut ||
                code == NSURLErrorInternationalRoamingOff ||
                code == NSURLErrorDataNotAllowed ||
                code == NSURLErrorCannotFindHost ||
                code == NSURLErrorCannotConnectToHost ||
                code == NSURLErrorNetworkConnectionLost {
                var userInfo = nserror.userInfo
                userInfo[NSLocalizedDescriptionKey] = "Unable to connect to the server"
                let currentError = NSError(
                    domain: nserror.domain,
                    code: code,
                    userInfo: userInfo
                )
                return currentError
            }
        }
        return error
    }
}
