//
//  MeshManager.swift
//  SwiftMesh
//
//  Created by iOS on 2019/12/26.
//  Copyright © 2019 iOS. All rights reserved.
//
import Foundation
import Alamofire
 
public class Mesh {

    /// 可观测下载进度0--1
//    @Published public var downloadProgress: Float = 0
//    
//    /// 可观测上传进度0--1
//    @Published public var uploadProgress: Float = 0
    
    public init() { }
 
    ///全局 headers
    public static var defaultHeaders: [String: String]?
    ///全局 默认参数
    public static var defaultParameters: [String: Any]?
    ///全局 UrlHost
    public static var defaultUrlHost : String?
 
    /// 超时配置
    public var timeout : TimeInterval = 15.0
    ///请求失败重试
    public var interceptor: RequestInterceptor?
    /// 请求方式
    public var requestMethod : HTTPMethod = .post
    /// 添加请求头
    public var addHeads : [String: String] = [:]
    /// 请求编码
    public var requestEncoding: ParameterEncoding = URLEncoding.default //JSONEncoding.default
    /// 请求地址
    public var urlHost : String?
    public var urlPath : String?
    
    ///参数  表单上传也可以用
    public var parameters : [String: Any]?
    
    //MARK: 下载
    public var downloadType : DownloadType = .download
    //设置文件下载地址覆盖方式等等
    public var destination : DownloadRequest.Destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory, in: .userDomainMask)
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
    ///表单数据
    public var uploadDatas : [MultipleUpload] = []
}

