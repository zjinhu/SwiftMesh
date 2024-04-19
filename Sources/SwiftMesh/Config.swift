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
    ///设置日志输出级别
    @discardableResult
    func logStatus(_ log: LogLevel) -> Self {
        self.log = log
        return self
    }
    /// 超时配置
    func timeout(_ timeout: TimeInterval) -> Self {
        self.timeout = timeout
        return self
    }
    ///请求失败重试策略
    func interceptor(_ interceptor: RequestInterceptor?) -> Self {
        self.interceptor = interceptor
        return self
    }
    /// 请求方式
    func requestMethod(_ requestMethod: HTTPMethod) -> Self {
        self.requestMethod = requestMethod
        return self
    }
    /// 添加请求头
    func addHeads(_ addHeads: HTTPHeaders?) -> Self {
        self.addHeads = addHeads
        return self
    }
    /// 请求编码
    func requestEncoding(_ requestEncoding: ParameterEncoding) -> Self {
        self.requestEncoding = requestEncoding
        return self
    }
    /// 请求地址
    func url(_ url: String?) -> Self {
        self.URLString = url
        return self
    }
    ///参数  表单上传也用
    func parameters(_ parameters: [String: Any]?) -> Self {
        self.parameters = parameters
        return self
    }
}
//MARK: 下载
public extension Mesh{
    //下载类型
    func downloadType(_ downloadType: DownloadType) -> Self {
        self.downloadType = downloadType
        return self
    }
    //设置文件下载地址覆盖方式等等
    func destination(_ destination: @escaping DownloadRequest.Destination) -> Self {
        self.destination = destination
        return self
    }
    
    ///已经下载的部分,下载续传用,从请求结果中获取
    func resumeData(_ resumeData: Data?) -> Self {
        self.resumeData = resumeData
        return self
    }
}
//MARK: 上传
public extension Mesh{
    //上传类型
    func uploadType(_ uploadType: UploadType) -> Self {
        self.uploadType = uploadType
        return self
    }
    ///上传文件地址
    func fileURL(_ fileURL: URL?) -> Self {
        self.fileURL = fileURL
        return self
    }
    ///上传文件地址
    func fileData(_ fileData: Data?) -> Self {
        self.fileData = fileData
        return self
    }
    ///上传文件InputStream
    func stream(_ stream: InputStream?) -> Self {
        self.stream = stream
        return self
    }
    ///表单数据
    func uploadDatas(_ uploadDatas: [MultipleUpload]) -> Self {
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
    func addformData(name: String,
                     fileName: String? = nil,
                     fileData: Data? = nil,
                     fileURL: URL? = nil,
                     mimeType: String? = nil)  -> Self {
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
    
    // MARK: 设置全局 headers
    /// 设置全局 headers
    /// - Parameter headers:全局 headers
    func setGlobalHeaders(_ headers: HTTPHeaders?)   -> Self {
        globalHeaders = headers
        return self
    }
    // MARK: 设置默认参数
    /// 设置默认参数
    /// - Parameter parameters: 默认参数
    func setDefaultParameters(_ parameters: [String: Any]?)   -> Self {
        defaultParameters = parameters
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
