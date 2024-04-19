//
//  MeshManager.swift
//  SwiftMesh
//
//  Created by iOS on 2019/12/26.
//  Copyright © 2019 iOS. All rights reserved.
//
import Foundation
import Alamofire

public enum LogLevel {
    case off
    case debug
    case info
    case error
}

public class Mesh: ObservableObject {

    /// 可观测下载进度0--1
    @Published public var downloadProgress: Float = 0
    
    /// 可观测上传进度0--1
    @Published public var uploadProgress: Float = 0
    
    public static let shared = Mesh()

    private init() {
        log = .off
        startLogging()
    }
    
    deinit {
        stopLogging()
    }
    
    var log: LogLevel
    ///全局 headers
    var globalHeaders: HTTPHeaders?
    ///默认参数
    var defaultParameters: [String: Any]?

    /// 超时配置
    var timeout : TimeInterval = 15.0
    ///请求失败重试
    var interceptor: RequestInterceptor?
    /// 请求方式
    var requestMethod : HTTPMethod = .post
    /// 添加请求头
    var addHeads : HTTPHeaders?
    /// 请求编码
    var requestEncoding: ParameterEncoding = URLEncoding.default
    /// 请求地址
    var URLString : String?
    ///参数  表单上传也可以用
    var parameters : [String: Any]?
    
    //MARK: 下载
    var downloadType : DownloadType = .download
    //设置文件下载地址覆盖方式等等
    var destination : DownloadRequest.Destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory, in: .userDomainMask)
    ///已经下载的部分,下载续传用,从请求结果中获取
    var resumeData : Data?
    
    //MARK: 上传
    var uploadType : UploadType = .file
    ///上传文件地址
    var fileURL: URL?
    ///上传文件地址
    var fileData: Data?
    ///上传文件InputStream
    var stream: InputStream?
    ///表单数据
    var uploadDatas : [MultipleUpload] = []
}

