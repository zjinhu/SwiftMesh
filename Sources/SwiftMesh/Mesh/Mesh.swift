//
//  MeshManager.swift
//  SwiftMesh
//
//  Created by iOS on 2019/12/26.
//  Copyright © 2019 iOS. All rights reserved.
//
import Foundation
import Alamofire
 
public class Config {
    /// 超时配置
    public var timeout : TimeInterval = 15.0
    /// 请求方式
    public var requestMethod : HTTPMethod = .get
    /// 添加请求头
    public var addHeads : HTTPHeaders?
    /// 请求编码
    public var requestEncoding: ParameterEncoding = URLEncoding.default
    /// 请求地址
    public var URLString : String?
    ///参数  表单上传也可以用
    public var parameters : [String: Any]?
}

public typealias ConfigClosure = (_ config: Config) -> Void

public actor Mesh: GlobalActor {
    public static let shared = Mesh()
    private init() {}
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
    // MARK: 发送请求
    /// 设置默认参数
    /// - type : Model数据模型
    /// - configClosure: 配置config,请求类型
    public func request<T: Decodable>(of type: T.Type, configClosure: ConfigClosure) async throws -> T  {
        
        let config = Config()
        configClosure(config)
        
        return try await requestWithConfig(of : T.self, config: config)
    }
    
    private func requestWithConfig<T: Decodable>(of type: T.Type, config: Config) async throws -> T {
        
        guard let url = config.URLString else {
            fatalError("URLString 为空")
        }
        
        mergeConfig(config)
        
        let requestTask = AF.request(url,
                                  method: config.requestMethod,
                                  parameters: config.parameters,
                                  encoding: config.requestEncoding,
                                  headers: config.addHeads,
                                  requestModifier: { $0.timeoutInterval = config.timeout }
        ).serializingDecodable(T.self)
        
        let result = await requestTask.response.result
        
        return try await withCheckedThrowingContinuation { continuation in
            switch result{
            case .success(let model):
                continuation.resume(returning: model)
            case .failure(let error):
                continuation.resume(throwing: self.handleError(error: error))
            }
        }
    }
    
    ///私有方法
    private func mergeConfig(_ config: Config){
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
    
    private func handleError(error: AFError) -> Error {
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
