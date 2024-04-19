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
                                      modelKeyPath: String? = nil) async throws -> T {
        
        guard let url = URLString else {
            fatalError("URLString 为空")
        }
        
        mergeConfig()
        
        let request = AF.request(url,
                                 method: requestMethod,
                                 parameters: parameters,
                                 encoding: requestEncoding,
                                 headers: addHeads,
                                 interceptor: interceptor,
                                 requestModifier: { $0.timeoutInterval = self.timeout }
        )
        
        return try await handleCodable(of: type,
                                       request: request,
                                       modelKeyPath: modelKeyPath)
    }
    
}
