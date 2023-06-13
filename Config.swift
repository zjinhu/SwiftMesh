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

public class Config {
    /// 超时配置
    public var timeout : TimeInterval = 15.0
    ///请求失败重试
    public var interceptor: RequestInterceptor?
    /// 请求方式
    public var requestMethod : HTTPMethod = .post
    /// 添加请求头
    public var addHeads : HTTPHeaders?
    /// 请求编码
    public var requestEncoding: ParameterEncoding = URLEncoding.default
    /// 请求地址
    public var URLString : String?
    ///参数  表单上传也可以用
    public var parameters : [String: Any]?
    
    
    //MARK: 下载
    public var downloadType : DownloadType = .download
    //设置文件下载地址覆盖方式等等
    public var destination : DownloadRequest.Destination = DownloadRequest.suggestedDownloadDestination(for: .cachesDirectory, in: .userDomainMask)
    ///已经下载的部分,下载续传用,从请求结果中获取
    public var resumeData : Data?
    
    
    //MARK: 上传
    public var uploadType : UploadType = .file
    ///上传文件地址
    public var fileURL: URL?
    ///上传文件地址
    public var fileData: Data?
    ///上传文件InputStream
    public var stream: InputStream?
    public var uploadDatas : [MultipleUpload]?
    /// 表单数组快速添加表单
    /// - Parameters:
    ///   - name: 表单 name 必须
    ///   - fileName: 文件名
    ///   - fileData: 文件 Data
    ///   - fileURL:  文件地址
    ///   - mimeType: 数据类型
    public func addformData(name: String, fileName: String? = nil, fileData: Data? = nil, fileURL: URL? = nil, mimeType: String? = nil) {
        let config = MultipleUpload.formData(name: name, fileName: fileName, fileData: fileData, fileURL: fileURL, mimeType: mimeType)
        uploadDatas?.append(config)
    }
}

/// 表单上传配置
public class MultipleUpload {
    
    public var name : String?
    
    public var fileName : String?
    
    public var mimeType : String?
    
    public var fileData : Data?
    
    public var fileURL: URL?
    
    /// 快速返回表单配置
    /// - Parameters:
    ///   - name: 表单 name 必须
    ///   - fileName: 文件名
    ///   - fileData: 文件 Data
    ///   - fileURL:  文件地址
    ///   - mimeType: 数据类型
    public static func formData(name: String, fileName: String? = nil, fileData: Data? = nil, fileURL: URL? = nil, mimeType: String? = nil) -> MultipleUpload {
        let config = MultipleUpload()
        config.name = name
        config.fileName = fileName
        config.mimeType = mimeType
        config.fileData = fileData
        config.fileURL = fileURL
        return config
    }
}
