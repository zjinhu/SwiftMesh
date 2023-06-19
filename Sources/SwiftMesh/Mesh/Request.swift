//
//  Request.swift
//  SwiftMesh
//
//  Created by iOS on 2023/6/13.
//

import Foundation
import Alamofire
extension Mesh{
    // MARK: 发送请求
    /// 设置默认参数
    /// - type : Model数据模型
    /// - configClosure: 配置config,请求类型
    public func request<T: Decodable>(of type: T.Type,
                                      modelKeyPath: String? = nil,
                                      _ configClosure: (_ config: Config) -> Void) async throws -> T  {
        
        let config = Config()
        configClosure(config)
        
        return try await requestWithConfig(of : T.self,
                                           modelKeyPath: modelKeyPath,
                                           config: config)
    }
}

extension Mesh{
    private func requestWithConfig<T: Decodable>(of type: T.Type,
                                                 modelKeyPath: String? = nil,
                                                 config: Config) async throws -> T {
        
        guard let url = config.URLString else {
            fatalError("URLString 为空")
        }
        
        mergeConfig(config)
        
        let request = AF.request(url,
                                 method: config.requestMethod,
                                 parameters: config.parameters,
                                 encoding: config.requestEncoding,
                                 headers: config.addHeads,
                                 interceptor: config.interceptor,
                                 requestModifier: { $0.timeoutInterval = config.timeout }
        )
        
        return try await handleCodable(of: type,
                                       request: request,
                                       modelKeyPath: modelKeyPath,
                                       config: config)
    }
    
}
