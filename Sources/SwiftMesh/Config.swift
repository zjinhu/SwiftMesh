//
//  Config.swift
//  SwiftMesh
//
//  Created by iOS on 2023/6/13.
//

import Foundation
import Alamofire

public enum DownloadType : Int {
    case download , resume
}

public enum UploadType : Int {
    case file , data , stream , multipart
}

public extension Mesh{
    /// 超时配置
    /// timeout
    @discardableResult
    func setTimeout(_ timeout: TimeInterval) -> Self {
        self.timeout = timeout
        return self
    }
    ///请求失败重试策略
    ///Request Failure Retry Policy
    @discardableResult
    func setInterceptor(_ interceptor: RequestInterceptor?) -> Self {
        self.interceptor = interceptor
        return self
    }
    /// 请求方式
    /// RequestMethod
    @discardableResult
    func setRequestMethod(_ requestMethod: HTTPMethod) -> Self {
        self.requestMethod = requestMethod
        return self
    }
    /// 添加请求头
    /// addHeads
    @discardableResult
    func setHeads(_ addHeads: [String: String]) -> Self {
        self.addHeads = addHeads
        return self
    }
    /// 请求编码
    /// RequestEncoding
    @discardableResult
    func setRequestEncoding(_ requestEncoding: ParameterEncoding) -> Self {
        self.requestEncoding = requestEncoding
        return self
    }
    /// 请求地址
    /// UrlPath
    @discardableResult
    func setUrlPath(_ path: String?) -> Self {
        self.urlPath = path
        return self
    }
    ///参数  表单上传也用
    ///Parameters
    @discardableResult
    func setParameters(_ parameters: [String: Any]?) -> Self {
        self.parameters = parameters
        return self
    }
}
//MARK: 下载
public extension Mesh{
    ///下载类型
    ///DownloadType
    @discardableResult
    func setDownloadType(_ downloadType: DownloadType) -> Self {
        self.downloadType = downloadType
        return self
    }
    ///设置文件下载地址覆盖方式等等
    ///DownloadRequest.Destination
    @discardableResult
    func setDestination(_ destination: @escaping DownloadRequest.Destination) -> Self {
        self.destination = destination
        return self
    }
    
    ///已经下载的部分,下载续传用,从请求结果中获取
    ///ResumeData
    @discardableResult
    func setResumeData(_ resumeData: Data?) -> Self {
        self.resumeData = resumeData
        return self
    }
}
//MARK: 上传
public extension Mesh{
    ///上传类型
    ///UploadType
    @discardableResult
    func setUploadType(_ uploadType: UploadType) -> Self {
        self.uploadType = uploadType
        return self
    }
    ///上传文件地址
    ///FileURL
    @discardableResult
    func setFileURL(_ fileURL: URL?) -> Self {
        self.fileURL = fileURL
        return self
    }
    ///上传文件地址
    ///FileData
    @discardableResult
    func setFileData(_ fileData: Data?) -> Self {
        self.fileData = fileData
        return self
    }
    ///上传文件InputStream
    ///InputStream
    @discardableResult
    func setStream(_ stream: InputStream?) -> Self {
        self.stream = stream
        return self
    }
    ///表单数据
    ///[MultipleUpload]
    @discardableResult
    func setUploadDatas(_ uploadDatas: [MultipleUpload]) -> Self {
        self.uploadDatas = uploadDatas
        return self
    }

    /// 表单数组快速添加表单
    /// - Parameters:
    ///   - name: 表单 name 必须
    ///   - fileName: 文件名
    ///   - fileData: 文件 Data
    ///   - fileURL:  文件地址
    ///   - mimeType: 数据类型
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

public extension Mesh{
    ///全局 Log 开关
    static func enableLog(_ type: LogType = .log){
        MeshLog.shared.type = type
        MeshLog.shared.startLogging()
    }
    // MARK: 设置全局 headers
    /// 设置全局 headers
    /// - Parameter headers:全局 headers
    static func setHeaders(_ headers: [String: String]){
        Mesh.defaultHeaders = headers
    }
    // MARK: 设置全局默认参数
    /// 设置全局默认参数
    /// - Parameter parameters: 默认参数
    static func setParameters(_ parameters: [String: Any]?){
        Mesh.defaultParameters = parameters
    }
    // MARK: 设置全局默认Url Host
    /// - Parameter url: 全局默认urlHost,用于拼接完整的URL地址,设置一次即可
    static func setUrlHost(_ url: String?){
        Mesh.defaultUrlHost = url
    }
    // MARK: 设置当次Url Host
    /// 仅当次请求有效
    @discardableResult
    func setUrlHost(_ url: String?) -> Self {
        self.urlHost = url
        return self
    }
}

/// 表单上传配置
public class MultipleUpload {
    
    /// 快速返回表单配置
    /// - Parameters:
    ///   - name: 表单 name 必须
    ///   - fileName: 文件名
    ///   - fileData: 文件 Data
    ///   - fileURL:  文件地址
    ///   - mimeType: 数据类型
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
    
    var name : String?
    var fileName : String?
    var mimeType : String?
    var fileData : Data?
    var fileURL: URL?
}
