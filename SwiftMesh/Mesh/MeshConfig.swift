//
//  MeshConfig.swift
//  SwiftMesh
//
//  Created by iOS on 2019/12/27.
//  Copyright © 2019 iOS. All rights reserved.
//

import Foundation
import Alamofire
enum DownloadType : Int {
    case download , resume
}
enum UploadType : Int {
    case file , data , stream , multipart
}
public class MeshConfig {
    /// 超时配置
    var timeout : TimeInterval = 15.0
    /// 添加请求头
    var addHeads : HTTPHeaders?
    /// 请求方式
    var requestMethod : HTTPMethod = .get
    /// 请求编码
    var requestEncoding: ParameterEncoding = URLEncoding.default  //PropertyListEncoding.xml//JSONEncoding.default
    /// 请求地址
    var URLString : String?
    ///参数  表单上传也可以用
    var parameters : [String: Any]?
    ///下载用 设置文件下载地址覆盖方式等等
    var destination : DownloadRequest.DownloadFileDestination?
    //服务端返回参数 定义错误码 错误信息 或者 正确信息
    var code : Int?
    var mssage : String?
    ///请求成功返回的数据 用 codable 解析
    var responseData : Data?
    ///下载完
    var downloadType : DownloadType = .download
    var downloadData : Data?
    var temporaryURL: URL?
    var destinationURL: URL?
    var resumeData : Data?
    ///上传
    var uploadType : UploadType = .file
    var fileURL: URL?
    var fileData: Data?
    var stream: InputStream?
    var uploadDatas : [MeshMultipartConfig]?
    
    /// 表单数组快速添加表单
    /// - Parameters:
    ///   - name: 表单 name 必须
    ///   - fileName: 文件名
    ///   - fileData: 文件 Data
    ///   - fileURL:  文件地址
    ///   - mimeType: 数据类型
    func addformData(name: String, fileName: String? = nil, fileData: Data? = nil, fileURL: URL? = nil, mimeType: String? = nil) {
        let config = MeshMultipartConfig.formData(name: name, fileName: fileName, fileData: fileData, fileURL: fileURL, mimeType: mimeType)
        self.uploadDatas?.append(config)
    }
}

public class MeshMultipartConfig {

    var name : String?

    var fileName : String?
    
    var mimeType : String?
     
    var fileData : Data?

    var fileURL: URL?
    
    /// 快速返回表单配置
    /// - Parameters:
    ///   - name: 表单 name 必须
    ///   - fileName: 文件名
    ///   - fileData: 文件 Data
    ///   - fileURL:  文件地址
    ///   - mimeType: 数据类型
   static func formData(name: String, fileName: String? = nil, fileData: Data? = nil, fileURL: URL? = nil, mimeType: String? = nil) -> MeshMultipartConfig {
        let config = MeshMultipartConfig.init()
        config.name = name
        config.fileName = fileName
        config.mimeType = mimeType
        config.fileData = fileData
        config.fileURL = fileURL
        return config
    }
}

