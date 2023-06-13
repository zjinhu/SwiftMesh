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
                                      configClosure: ConfigClosure) async throws -> T  {
        
        let config = Config()
        configClosure(config)
        
        return try await requestWithConfig(of : T.self,
                                           modelKeyPath: modelKeyPath,
                                           config: config)
    }
    
    
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
        
        if let path = modelKeyPath{
            let requestTask = request.serializingData(automaticallyCancelling: true)
            
            let result = await requestTask.response.result
            
            return try await withCheckedThrowingContinuation { continuation in
                switch result{
                case .success(let data):
                    if let model = try? JSONDecoder.default.decode(T.self, from: data, keyPath: path){
                        continuation.resume(returning: model)
                    }else{
                        continuation.resume(throwing: NSError(domain: "json解析失败,检查keyPath",
                                                              code: 0))
                    }
                case .failure(let error):
                    continuation.resume(throwing: self.handleError(error: error))
                }
            }
        }else{
            let requestTask = request.serializingDecodable(T.self,
                                                           automaticallyCancelling: true,
                                                           decoder: JSONDecoder.default)
            
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
    }
    
}
