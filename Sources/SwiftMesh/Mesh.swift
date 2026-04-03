//
//  Mesh.swift
//  SwiftMesh
//
//  Created by iOS on 2019/12/26.
//  Copyright © 2019 iOS. All rights reserved.
//

import Foundation
import Alamofire

/// Core network request builder and configuration holder
/// 核心网络请求构建器与配置持有者
///
/// Mesh is the central class for building and configuring network requests.
/// It holds both global static properties (shared across all requests) and
/// instance-level properties (per-request configuration).
/// Designed for fluent/chained method calls — all config methods return `Self`.
///
/// Mesh 是用于构建和配置网络请求的核心类。
/// 它同时持有全局静态属性（所有请求共享）和实例级属性（单次请求配置）。
/// 支持链式调用设计 — 所有配置方法均返回 `Self`。
///
/// Example / 示例:
/// ```swift
/// let result = try await Mesh()
///     .setRequestMethod(.get)
///     .setUrlHost("https://api.example.com")
///     .setUrlPath("/weather")
///     .request(of: Weather.self)
/// ```
public class Mesh {

    // MARK: - Global Static Properties / 全局静态属性

    /// Global default headers applied to all requests
    /// 全局默认请求头，应用于所有请求
    public static var defaultHeaders: [String: String]?

    /// Global default parameters merged into every request
    /// 全局默认参数，合并到每个请求中
    public static var defaultParameters: [String: Any]?

    /// Global default URL host used for URL construction
    /// 全局默认 URL 主机地址，用于拼接完整 URL
    public static var defaultUrlHost: String?

    // MARK: - Instance Properties / 实例属性

    /// Request timeout interval in seconds (default: 15.0)
    /// 请求超时时间（秒），默认 15.0 秒
    public var timeout: TimeInterval = 15.0

    /// Request interceptor for retry policies and credential handling
    /// 请求拦截器，用于重试策略和凭证处理
    public var interceptor: RequestInterceptor?

    /// HTTP request method (default: .post)
    /// HTTP 请求方法，默认 POST
    public var requestMethod: HTTPMethod = .post

    /// Per-request headers (merged with global defaults)
    /// 单次请求头（会与全局默认值合并）
    public var addHeads: [String: String] = [:]

    /// Parameter encoding strategy (default: URLEncoding)
    /// 参数编码方式，默认 URL 编码
    public var requestEncoding: ParameterEncoding = URLEncoding.default

    /// URL host for this request (overrides global default if set)
    /// 单次请求的 URL 主机地址（设置后覆盖全局默认值）
    public var urlHost: String?

    /// URL path appended to the host
    /// URL 路径，拼接在 host 之后
    public var urlPath: String?

    /// Request parameters (also used for multipart form uploads)
    /// 请求参数（表单上传时也可使用）
    public var parameters: [String: Any]?

    // MARK: - Download Properties / 下载相关属性

    /// Download mode: standard download or resumable download
    /// 下载模式：普通下载或断点续传
    public var downloadType: DownloadType = .download

    /// File destination configuration (path, overwrite behavior, etc.)
    /// 文件下载地址及覆盖方式等配置
    public var destination: DownloadRequest.Destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory, in: .userDomainMask)

    /// Resume data from an interrupted download, used for resumable downloads
    /// 已下载部分数据，用于断点续传，从请求结果中获取
    public var resumeData: Data?

    // MARK: - Upload Properties / 上传相关属性

    /// Upload mode: file URL, Data, InputStream, or multipart form
    /// 上传模式：文件 URL、Data、输入流或多部分表单
    public var uploadType: UploadType = .file

    /// File URL for upload (used with .file upload type)
    /// 上传文件的 URL 地址（用于 .file 上传类型）
    public var fileURL: URL?

    /// File Data for upload (used with .data upload type)
    /// 上传文件的 Data 数据（用于 .data 上传类型）
    public var fileData: Data?

    /// InputStream for upload (used with .stream upload type)
    /// 上传用的输入流（用于 .stream 上传类型）
    public var stream: InputStream?

    /// Multipart form data entries (used with .multipart upload type)
    /// 多部分表单数据条目（用于 .multipart 上传类型）
    public var uploadDatas: [MultipleUpload] = []
}
