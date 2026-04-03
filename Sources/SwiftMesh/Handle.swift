//
//  Handle.swift
//  SwiftMesh
//
//  Created by iOS on 2023/6/14.
//

import Foundation
import Alamofire
import Combine

extension Mesh {

    // MARK: - URL Construction / URL 构建

    /// Validate and construct the full URL from urlHost + urlPath.
    /// Falls back to global defaults if per-request values are not set.
    /// 验证并拼接完整的 URL（urlHost + urlPath）。
    /// 如果未设置单次请求的值，则回退到全局默认值。
    ///
    /// - Returns: Full URL string / 完整 URL 字符串
    /// - FatalError: If urlPath or urlHost is nil / 如果 urlPath 或 urlHost 为空则崩溃
    public func checkUrl() -> String {
        guard let urlPath else {
            fatalError("urlHost OR urlPath nil — urlPath 不能为空")
        }

        var url: String?

        // Use global default host first / 优先使用全局默认 host
        if let host = Mesh.defaultUrlHost {
            url = host
        }

        // Override with per-request host if set / 如果设置了单次请求的 host 则覆盖
        if let urlHost {
            url = urlHost
        }

        guard let url else {
            fatalError("urlHost nil — urlHost 不能为空")
        }
        return url + urlPath
    }

    // MARK: - Configuration Merging / 配置合并

    /// Merge global default parameters and headers with per-request ones.
    /// Per-request values override global defaults.
    /// 将全局默认参数和请求头与单次请求的值合并。
    /// 单次请求的值会覆盖全局默认值。
    public func mergeConfig() {
        // Merge parameters: global defaults + per-request overrides
        // 合并参数：全局默认值 + 单次请求覆盖值
        var param = Mesh.defaultParameters ?? [:]
        param.merge(parameters ?? [:]) { (_, new) in new }
        parameters = param

        // Merge headers: per-request + global defaults
        // 合并请求头：单次请求 + 全局默认值
        let headers = Mesh.defaultHeaders ?? [:]
        addHeads.merge(headers) { (_, new) in new }
    }

    // MARK: - Error Handling / 错误处理

    /// Normalize Alamofire errors into user-friendly NSError objects.
    /// Handles common network issues: no connection, timeout, roaming, etc.
    /// 将 Alamofire 错误标准化为用户友好的 NSError 对象。
    /// 处理常见网络问题：无连接、超时、漫游、网络中断等。
    ///
    /// - Parameter error: Alamofire error / Alamofire 错误
    /// - Returns: Normalized error (NSError for common cases, original AFError otherwise)
    ///            标准化错误（常见情况返回 NSError，否则返回原始 AFError）
    public func handleError(error: AFError) -> Error {
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

    // MARK: - Download Response Handling / 下载响应处理

    /// Handle download response and return the downloaded file URL.
    /// 处理下载响应并返回下载文件的 URL。
    ///
    /// - Parameter request: Alamofire DownloadRequest / Alamofire 下载请求
    /// - Returns: Downloaded file URL / 下载文件 URL
    /// - Throws: Network errors / 网络错误
    func handleDownload(request: DownloadRequest) async throws -> URL {

        let downloadTask = request.serializingDownloadedFileURL(automaticallyCancelling: true)
        let result = await downloadTask.response.result

        return try await withCheckedThrowingContinuation { continuation in
            switch result {
            case .success(let url):
                continuation.resume(returning: url)
            case .failure(let error):
                continuation.resume(throwing: self.handleError(error: error))
            }
        }
    }

    // MARK: - Codable Response Handling / Codable 响应处理

    /// Core JSON decoding logic. Supports both full response decoding and
    /// nested key path extraction for partial JSON parsing.
    /// 核心 JSON 解码逻辑。支持完整响应解码和嵌套键路径提取（局部 JSON 解析）。
    ///
    /// - Parameters:
    ///   - type: The Decodable model type / 数据模型类型
    ///   - request: Alamofire DataRequest / Alamofire 数据请求
    ///   - modelKeyPath: Optional dot-separated key path for nested extraction
    ///                   可选的点分隔键路径，用于嵌套提取
    /// - Returns: Decoded model instance / 解码后的模型实例
    /// - Throws: Network or decoding errors / 网络或解码错误
    func handleCodable<T: Decodable>(of type: T.Type,
                                     request: DataRequest,
                                     modelKeyPath: String? = nil) async throws -> T {

        if let path = modelKeyPath {
            // Key path extraction: parse only the nested portion needed
            // 键路径提取：仅解析所需的嵌套部分
            let requestTask = request.serializingData(automaticallyCancelling: true)
            let result = await requestTask.response.result

            return try await withCheckedThrowingContinuation { continuation in
                switch result {
                case .success(let data):
                    if let model = try? JSONDecoder.default.decode(T.self, from: data, keyPath: path) {
                        continuation.resume(returning: model)
                    } else {
                        continuation.resume(throwing: NSError(domain: "json parsing failure, check keyPath — JSON 解析失败，请检查 keyPath",
                                                              code: 0))
                    }
                case .failure(let error):
                    continuation.resume(throwing: self.handleError(error: error))
                }
            }
        } else {
            // Full response decoding using Alamofire's built-in decoder
            // 使用 Alamofire 内置解码器进行完整响应解码
            let requestTask = request.serializingDecodable(T.self,
                                                           automaticallyCancelling: true,
                                                           decoder: JSONDecoder.default)

            let result = await requestTask.response.result

            return try await withCheckedThrowingContinuation { continuation in
                switch result {
                case .success(let model):
                    continuation.resume(returning: model)
                case .failure(let error):
                    continuation.resume(throwing: self.handleError(error: error))
                }
            }
        }
    }
}

// MARK: - Retry Policy / 重试策略

/// Built-in retry policy with linear backoff.
/// Automatically retries failed requests up to a configurable max count.
/// 内置重试策略，采用线性退避。
/// 自动重试失败的请求，最多达到可配置的最大次数。
///
/// Example / 示例:
/// ```swift
/// let retryPolicy = RetryPolicy(maxRetryCount: 3)
/// Mesh.shared.setInterceptor(retryPolicy)
/// ```
public class RetryPolicy: RequestInterceptor {

    /// Maximum number of retry attempts / 最大重试次数
    private let maxRetryCount: Int

    /// Initialize with a custom max retry count (default: 3)
    /// 初始化自定义最大重试次数（默认 3 次）
    /// - Parameter maxRetryCount: Maximum retry attempts / 最大重试次数
    public init(maxRetryCount: Int = 3) {
        self.maxRetryCount = maxRetryCount
    }

    /// Determine whether to retry the failed request.
    /// Uses linear backoff: retry after (retryCount + 1) seconds.
    /// 判断是否应重试失败的请求。
    /// 采用线性退避：在 (retryCount + 1) 秒后重试。
    ///
    /// - Parameters:
    ///   - request: The failed request / 失败的请求
    ///   - session: The session that made the request / 发起请求的会话
    ///   - error: The error that caused the failure / 导致失败的错误
    ///   - completion: Closure to call with the retry decision / 重试决策闭包
    public func retry(_ request: Request,
                      for session: Session,
                      dueTo error: Error,
                      completion: @escaping (RetryResult) -> Void) {
        let retryCount = request.retryCount

        if retryCount < maxRetryCount {
            // Retry with linear backoff: 1s, 2s, 3s, ...
            // 线性退避重试：1秒、2秒、3秒...
            let retryInterval = TimeInterval(retryCount + 1)
            completion(.retryWithDelay(retryInterval))
        } else {
            // Max retries reached, do not retry
            // 达到最大重试次数，不再重试
            completion(.doNotRetry)
        }
    }
}
