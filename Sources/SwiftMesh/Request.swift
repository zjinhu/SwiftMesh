//
//  Request.swift
//  SwiftMesh
//
//  Created by iOS on 2023/6/13.
//

import Foundation
import Alamofire

extension Mesh {

    // MARK: - Send Request and Decode to Codable Model
    // MARK: - 发送请求并解码为 Codable 模型

    /// Send an HTTP request and decode the response into a Codable type.
    /// Supports optional key path for partial JSON parsing.
    /// 发送 HTTP 请求并将响应解码为 Codable 类型。
    /// 支持可选的 key path 用于局部 JSON 解析。
    ///
    /// - Parameters:
    ///   - type: The Decodable model type to decode into / 要解码的数据模型类型
    ///   - modelKeyPath: Optional dot-separated key path for nested JSON extraction
    ///                   (e.g., "data.yesterday" extracts the value at `data.yesterday`)
    ///                   可选的点分隔键路径，用于嵌套 JSON 提取（例如 "data.yesterday"）
    /// - Returns: Decoded model instance / 解码后的模型实例
    /// - Throws: Network or decoding errors / 网络或解码错误
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

    // MARK: - Send URLRequest and Decode to Codable Model
    // MARK: - 发送 URLRequest 请求并解码为 Codable 模型

    /// Send a URLRequest and decode the response into a Codable type.
    /// Useful when you already have a URLRequestConvertible (e.g., from URLBuilding).
    /// 发送 URLRequest 并将响应解码为 Codable 类型。
    /// 适用于已经拥有 URLRequestConvertible 的场景。
    ///
    /// - Parameters:
    ///   - urlRequest: A URLRequestConvertible object / URLRequestConvertible 对象
    ///   - type: The Decodable model type to decode into / 要解码的数据模型类型
    ///   - modelKeyPath: Optional dot-separated key path for nested JSON extraction
    ///                   可选的点分隔键路径，用于嵌套 JSON 提取
    /// - Returns: Decoded model instance / 解码后的模型实例
    /// - Throws: Network or decoding errors / 网络或解码错误
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

    // MARK: - Send Request and Return Raw Data
    // MARK: - 发送请求并返回原始 Data

    /// Send an HTTP request and return the raw response Data.
    /// Useful for manual JSON parsing, String conversion, or custom processing.
    /// 发送 HTTP 请求并返回原始响应 Data。
    /// 适用于手动 JSON 解析、字符串转换或自定义处理。
    ///
    /// - Returns: Raw response data / 原始响应数据
    /// - Throws: Network errors / 网络错误
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

        let requestTask = request.serializingData()
        let result = await requestTask.response.result
        return try await withCheckedThrowingContinuation { continuation in
            switch result {
            case .success(let data):
                continuation.resume(returning: data)
            case .failure(let error):
                continuation.resume(throwing: self.handleError(error: error))
            }
        }
    }

    // MARK: - Send Request and Return String
    // MARK: - 发送请求并返回字符串

    /// Send an HTTP request and return the response as a String.
    /// 发送 HTTP 请求并将响应作为字符串返回。
    ///
    /// - Returns: Response string / 响应字符串
    /// - Throws: Network errors / 网络错误
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

        let requestTask = request.serializingString()
        let result = await requestTask.response.result
        return try await withCheckedThrowingContinuation { continuation in
            switch result {
            case .success(let str):
                continuation.resume(returning: str)
            case .failure(let error):
                continuation.resume(throwing: self.handleError(error: error))
            }
        }
    }
}
