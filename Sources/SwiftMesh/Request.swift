//
//  Request.swift
//  SwiftMesh
//
//  Created by iOS on 2023/6/13.
//

import Foundation
import Alamofire
extension Mesh{
    // MARK: 发送请求返回Codable
    /// 设置默认参数
    /// - type : Model数据模型
    /// - modelKeyPath: 可以指定解析路径用.区分比如 data.message
    @discardableResult
    public func request<T: Decodable>(of type: T.Type,
                                      modelKeyPath: String? = nil) async throws -> T {
        
        let url = checkUrl()
        mergeConfig()
        
        let request = AF.request(url,
                                 method: requestMethod,
                                 parameters: parameters,
                                 encoding: requestEncoding,
                                 headers: HTTPHeaders(addHeads),
                                 interceptor: interceptor,
                                 requestModifier: { $0.timeoutInterval = self.timeout }
        )
        
        return try await handleCodable(of: type,
                                       request: request,
                                       modelKeyPath: modelKeyPath)
    }
    
    // MARK: 发送URLRequest请求返回Codable
    /// 设置默认参数
    /// - type : Model数据模型
    /// - modelKeyPath: 可以指定解析路径用.区分比如 data.message
    @discardableResult
    public func urlRequest<T: Decodable>(_ urlRequest: URLRequestConvertible,
                                         type: T.Type,
                                         modelKeyPath: String? = nil) async throws -> T {
        
        let request = AF.request(urlRequest,
                                 interceptor: interceptor)
        
        return try await handleCodable(of: type,
                                       request: request,
                                       modelKeyPath: modelKeyPath)
    }
    
    // MARK: 发送请求返回jsonData,可以用于转换String或者Dic
    public func requestData() async throws -> Data {
        let url = checkUrl()
        
        mergeConfig()
        
        let request = AF.request(url,
                                 method: requestMethod,
                                 parameters: parameters,
                                 encoding: requestEncoding,
                                 headers: HTTPHeaders(addHeads),
                                 interceptor: interceptor,
                                 requestModifier: { $0.timeoutInterval = self.timeout }
        )
        
        let requestTask =  request.serializingData()
        let result = await requestTask.response.result
        return try await withCheckedThrowingContinuation { continuation in
            switch result{
            case .success(let date):
                continuation.resume(returning: date)
            case .failure(let error):
                continuation.resume(throwing: self.handleError(error: error))
            }
        }
    }
    
    // MARK: 发送请求返回json
    public func requestString() async throws -> String {
        let url = checkUrl()
        
        mergeConfig()
        
        let request = AF.request(url,
                                 method: requestMethod,
                                 parameters: parameters,
                                 encoding: requestEncoding,
                                 headers: HTTPHeaders(addHeads),
                                 interceptor: interceptor,
                                 requestModifier: { $0.timeoutInterval = self.timeout }
        )
        
        let requestTask =  request.serializingString()
        let result = await requestTask.response.result
        return try await withCheckedThrowingContinuation { continuation in
            switch result{
            case .success(let str):
                continuation.resume(returning: str)
            case .failure(let error):
                continuation.resume(throwing: self.handleError(error: error))
            }
        }
    }
}
