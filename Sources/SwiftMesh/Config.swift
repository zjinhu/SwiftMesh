//
//  Config.swift
//  SwiftMesh
//
//  Created by iOS on 2023/6/13.
//

import Foundation
import Alamofire

/// Download mode enumeration
/// 下载模式枚举
public enum DownloadType: Int {
    /// Standard download / 普通下载
    case download
    /// Resumable download (requires resumeData) / 断点续传（需要提供 resumeData）
    case resume
}

/// Upload mode enumeration
/// 上传模式枚举
public enum UploadType: Int {
    /// Upload from file URL / 通过文件 URL 上传
    case file
    /// Upload from Data object / 通过 Data 对象上传
    case data
    /// Upload from InputStream / 通过输入流上传
    case stream
    /// Multipart form upload / 多部分表单上传
    case multipart
}

// MARK: - Basic Configuration / 基础配置

public extension Mesh {
    /// Set request timeout interval (chainable)
    /// 设置请求超时时间（链式调用）
    /// - Parameter timeout: Timeout in seconds / 超时时间（秒）
    /// - Returns: Self for chaining / 返回自身以支持链式调用
    @discardableResult
    func setTimeout(_ timeout: TimeInterval) -> Self {
        self.timeout = timeout
        return self
    }

    /// Set request interceptor for retry policies (chainable)
    /// 设置请求拦截器，用于重试策略（链式调用）
    /// - Parameter interceptor: Request interceptor / 请求拦截器
    /// - Returns: Self for chaining / 返回自身以支持链式调用
    @discardableResult
    func setInterceptor(_ interceptor: RequestInterceptor?) -> Self {
        self.interceptor = interceptor
        return self
    }

    /// Set HTTP request method (chainable)
    /// 设置 HTTP 请求方法（链式调用）
    /// - Parameter requestMethod: HTTP method (GET, POST, etc.) / HTTP 方法
    /// - Returns: Self for chaining / 返回自身以支持链式调用
    @discardableResult
    func setRequestMethod(_ requestMethod: HTTPMethod) -> Self {
        self.requestMethod = requestMethod
        return self
    }

    /// Set per-request headers (chainable)
    /// 设置单次请求头（链式调用）
    /// - Parameter addHeads: Headers dictionary / 请求头字典
    /// - Returns: Self for chaining / 返回自身以支持链式调用
    @discardableResult
    func setHeads(_ addHeads: [String: String]) -> Self {
        self.addHeads = addHeads
        return self
    }

    /// Set parameter encoding strategy (chainable)
    /// 设置参数编码方式（链式调用）
    /// - Parameter requestEncoding: Encoding type (URLEncoding, JSONEncoding, etc.) / 编码类型
    /// - Returns: Self for chaining / 返回自身以支持链式调用
    @discardableResult
    func setRequestEncoding(_ requestEncoding: ParameterEncoding) -> Self {
        self.requestEncoding = requestEncoding
        return self
    }

    /// Set URL path for this request (chainable)
    /// 设置单次请求的 URL 路径（链式调用）
    /// - Parameter path: URL path / URL 路径
    /// - Returns: Self for chaining / 返回自身以支持链式调用
    @discardableResult
    func setUrlPath(_ path: String?) -> Self {
        self.urlPath = path
        return self
    }

    /// Set request parameters (chainable)
    /// Also used for multipart form upload fields
    /// 设置请求参数（链式调用）
    /// 表单上传时也可使用
    /// - Parameter parameters: Parameters dictionary / 参数字典
    /// - Returns: Self for chaining / 返回自身以支持链式调用
    @discardableResult
    func setParameters(_ parameters: [String: Any]?) -> Self {
        self.parameters = parameters
        return self
    }
}

// MARK: - Download Configuration / 下载配置

public extension Mesh {
    /// Set download type: standard or resumable (chainable)
    /// 设置下载类型：普通下载或断点续传（链式调用）
    /// - Parameter downloadType: Download mode / 下载模式
    /// - Returns: Self for chaining / 返回自身以支持链式调用
    @discardableResult
    func setDownloadType(_ downloadType: DownloadType) -> Self {
        self.downloadType = downloadType
        return self
    }

    /// Set file destination for download (chainable)
    /// 设置文件下载地址及覆盖方式等（链式调用）
    /// - Parameter destination: Download destination closure / 下载目标地址闭包
    /// - Returns: Self for chaining / 返回自身以支持链式调用
    @discardableResult
    func setDestination(_ destination: @escaping DownloadRequest.Destination) -> Self {
        self.destination = destination
        return self
    }

    /// Set resume data for resumable download (chainable)
    /// 设置断点续传数据（链式调用）
    /// Resume data is obtained from a previous interrupted download response
    /// 续传数据来自之前中断的下载响应
    /// - Parameter resumeData: Resume data / 续传数据
    /// - Returns: Self for chaining / 返回自身以支持链式调用
    @discardableResult
    func setResumeData(_ resumeData: Data?) -> Self {
        self.resumeData = resumeData
        return self
    }
}

// MARK: - Upload Configuration / 上传配置

public extension Mesh {
    /// Set upload type: file, data, stream, or multipart (chainable)
    /// 设置上传类型：文件、数据、流或多部分表单（链式调用）
    /// - Parameter uploadType: Upload mode / 上传模式
    /// - Returns: Self for chaining / 返回自身以支持链式调用
    @discardableResult
    func setUploadType(_ uploadType: UploadType) -> Self {
        self.uploadType = uploadType
        return self
    }

    /// Set file URL for upload (chainable)
    /// 设置上传文件 URL 地址（链式调用）
    /// - Parameter fileURL: File URL / 文件 URL
    /// - Returns: Self for chaining / 返回自身以支持链式调用
    @discardableResult
    func setFileURL(_ fileURL: URL?) -> Self {
        self.fileURL = fileURL
        return self
    }

    /// Set file Data for upload (chainable)
    /// 设置上传文件 Data 数据（链式调用）
    /// - Parameter fileData: File data / 文件数据
    /// - Returns: Self for chaining / 返回自身以支持链式调用
    @discardableResult
    func setFileData(_ fileData: Data?) -> Self {
        self.fileData = fileData
        return self
    }

    /// Set InputStream for upload (chainable)
    /// 设置上传用输入流（链式调用）
    /// - Parameter stream: Input stream / 输入流
    /// - Returns: Self for chaining / 返回自身以支持链式调用
    @discardableResult
    func setStream(_ stream: InputStream?) -> Self {
        self.stream = stream
        return self
    }

    /// Set multipart form data entries (chainable)
    /// 设置多部分表单数据条目（链式调用）
    /// - Parameter uploadDatas: Array of MultipleUpload configs / MultipleUpload 配置数组
    /// - Returns: Self for chaining / 返回自身以支持链式调用
    @discardableResult
    func setUploadDatas(_ uploadDatas: [MultipleUpload]) -> Self {
        self.uploadDatas = uploadDatas
        return self
    }

    /// Quickly add a form field to the multipart upload (chainable)
    /// 快速添加表单字段到多部分上传（链式调用）
    /// - Parameters:
    ///   - name: Form field name (required) / 表单字段名称（必填）
    ///   - fileName: File name / 文件名
    ///   - fileData: File data / 文件 Data
    ///   - fileURL: File URL / 文件地址
    ///   - mimeType: MIME type (e.g., "image/jpeg") / MIME 类型
    /// - Returns: Self for chaining / 返回自身以支持链式调用
    @discardableResult
    func setAddformData(name: String,
                        fileName: String? = nil,
                        fileData: Data? = nil,
                        fileURL: URL? = nil,
                        mimeType: String? = nil) -> Self {
        let config = MultipleUpload.formData(name: name,
                                             fileName: fileName,
                                             fileData: fileData,
                                             fileURL: fileURL,
                                             mimeType: mimeType)
        uploadDatas.append(config)
        return self
    }
}

// MARK: - Global Configuration / 全局配置

public extension Mesh {
    /// Enable global network logging
    /// 启用全局网络日志
    /// - Parameter type: Log output mode (.print or .log) / 日志输出模式
    static func enableLog(_ type: LogType = .log) {
        MeshLog.shared.type = type
        MeshLog.shared.startLogging()
    }

    /// Set global default headers for all requests
    /// 设置全局默认请求头，应用于所有请求
    /// - Parameter headers: Headers dictionary / 请求头字典
    static func setHeaders(_ headers: [String: String]) {
        Mesh.defaultHeaders = headers
    }

    /// Set global default parameters merged into every request
    /// 设置全局默认参数，合并到每个请求中
    /// - Parameter parameters: Parameters dictionary / 参数字典
    static func setParameters(_ parameters: [String: Any]?) {
        Mesh.defaultParameters = parameters
    }

    /// Set global default URL host for URL construction (set once, used globally)
    /// 设置全局默认 URL 主机地址，用于拼接完整 URL，设置一次即可
    /// - Parameter url: URL host string / URL 主机地址
    static func setUrlHost(_ url: String?) {
        Mesh.defaultUrlHost = url
    }

    /// Set URL host for this single request only (chainable)
    /// 设置单次请求的 URL 主机地址（链式调用）
    /// Only valid for this request / 仅当次请求有效
    /// - Parameter url: URL host string / URL 主机地址
    /// - Returns: Self for chaining / 返回自身以支持链式调用
    @discardableResult
    func setUrlHost(_ url: String?) -> Self {
        self.urlHost = url
        return self
    }
}

// MARK: - Multipart Upload Configuration / 多部分上传配置

/// Multipart form upload configuration
/// 多部分表单上传配置
public class MultipleUpload {

    /// Create a form field configuration
    /// 快速创建表单配置
    /// - Parameters:
    ///   - name: Form field name (required) / 表单字段名称（必填）
    ///   - fileName: File name / 文件名
    ///   - fileData: File data / 文件 Data
    ///   - fileURL: File URL / 文件地址
    ///   - mimeType: MIME type (e.g., "image/jpeg") / MIME 类型
    /// - Returns: MultipleUpload configuration instance / MultipleUpload 配置实例
    public static func formData(name: String,
                                fileName: String? = nil,
                                fileData: Data? = nil,
                                fileURL: URL? = nil,
                                mimeType: String? = nil) -> MultipleUpload {
        let config = MultipleUpload()
        config.name = name
        config.fileName = fileName
        config.mimeType = mimeType
        config.fileData = fileData
        config.fileURL = fileURL
        return config
    }

    /// Form field name / 表单字段名称
    var name: String?
    /// File name / 文件名
    var fileName: String?
    /// MIME type / MIME 类型
    var mimeType: String?
    /// File data / 文件 Data
    var fileData: Data?
    /// File URL / 文件地址
    var fileURL: URL?
}
