//
//  MeshConfig.swift
//  SwiftMesh
//
//  Created by iOS on 2019/12/27.
//  Copyright © 2019 iOS. All rights reserved.
//

import Foundation
import Alamofire

public enum DownloadType : Int {
    case download , resume
}
public enum UploadType : Int {
    case file , data , stream , multipart
}

public enum RequestCode : Int {
    case success = 0 //请求成功的状态吗
    case errorResult = -1 //接口请求失败,有错误返回
    case errorResponse = -2 //请求返回的数据为空
    case errorRequest = -3 //请求失败,无网络
}

/// 网络请求配置
public class MeshConfig {
    //MARK: 请求相关配置
    /// 超时配置
    public var timeout : TimeInterval = 15.0
    /// 添加请求头
    public var addHeads : HTTPHeaders?
    /// 请求方式
    public var requestMethod : HTTPMethod = .get
    /// 请求编码
    public var requestEncoding: ParameterEncoding = URLEncoding.default  //PropertyListEncoding.xml//JSONEncoding.default
    //MARK: 请求地址以及参数
    /// 请求地址
    public var URLString : String?
    ///参数  表单上传也可以用
    public var parameters : [String: Any]?
    //MARK: 请求完成返回数据
    //服务端返回参数 定义错误码 错误信息 或者 正确信息
    public var code : Int?
    public var mssage : String?
    
    /// AF请求下来的完整response，可自行处理
    public var response: AFDataResponse<Any>?
    //MARK: 下载
    ///下载用 设置文件下载地址覆盖方式等等
    public var destination : DownloadRequest.Destination?
    
    public var downloadType : DownloadType = .download
    public var fileURL: URL?   
    public var resumeData : Data?
    
    //MARK: 上传
    public var uploadType : UploadType = .file
    public var fileData: Data?
    public var stream: InputStream?
    public var uploadDatas : [MeshMultipartConfig]?
    
    /// 表单数组快速添加表单
    /// - Parameters:
    ///   - name: 表单 name 必须
    ///   - fileName: 文件名
    ///   - fileData: 文件 Data
    ///   - fileURL:  文件地址
    ///   - mimeType: 数据类型
    public func addformData(name: String, fileName: String? = nil, fileData: Data? = nil, fileURL: URL? = nil, mimeType: String? = nil) {
        let config = MeshMultipartConfig.formData(name: name, fileName: fileName, fileData: fileData, fileURL: fileURL, mimeType: mimeType)
        uploadDatas?.append(config)
    }
}

/// 表单上传配置
public class MeshMultipartConfig {
    
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
    public class func formData(name: String, fileName: String? = nil, fileData: Data? = nil, fileURL: URL? = nil, mimeType: String? = nil) -> MeshMultipartConfig {
        let config = MeshMultipartConfig.init()
        config.name = name
        config.fileName = fileName
        config.mimeType = mimeType
        config.fileData = fileData
        config.fileURL = fileURL
        return config
    }
}

