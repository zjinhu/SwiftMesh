//
//  Upload.swift
//  SwiftMesh
//
//  Created by iOS on 2023/6/13.
//

import Foundation
import Alamofire
extension Mesh{
    
    /// 上传文件
    /// - Parameters:
    ///   - type: 上传完成后接口返回的数据模型
    ///   - modelKeyPath: 解析路径
    ///   - configClosure: 根据需要设置config的uploadType fileURL fileData stream uploadDatas等参数
    /// - Returns: 返回解析后的数据模型
    public func upload<T: Decodable>(of type: T.Type,
                                     modelKeyPath: String? = nil,
                                     _ configClosure: (_ config: Config) -> Void) async throws -> T{
        
        let config = Config()
        configClosure(config)
        
        switch config.uploadType {
        case .multipart:
            return try await sendUploadMultipart(of: type,
                                                 modelKeyPath: modelKeyPath,
                                                 config: config)
        default:
            return try await sendUpload(of: type,
                                        modelKeyPath: modelKeyPath,
                                        config: config)
        }
    }
}

extension Mesh{
    private func sendUpload<T: Decodable>(of type: T.Type,
                                          modelKeyPath: String? = nil,
                                          config: Config) async throws -> T{
        
        guard let url = config.URLString else {
            fatalError("URLString 为空")
        }
        
        var uploadRequest : UploadRequest
        
        switch config.uploadType {
        case .file:
            guard let fileURL = config.fileURL else {
                fatalError("fileURL 为空")
            }
            uploadRequest = AF.upload(fileURL,
                                      to: url,
                                      method: config.requestMethod,
                                      headers: config.addHeads,
                                      interceptor: config.interceptor,
                                      requestModifier: { request in request.timeoutInterval = config.timeout})
            
        case .stream:
            guard let stream = config.stream else {
                fatalError("stream 为空")
            }
            uploadRequest = AF.upload(stream,
                                      to: url,
                                      method: config.requestMethod,
                                      headers: config.addHeads,
                                      interceptor: config.interceptor,
                                      requestModifier: { request in request.timeoutInterval = config.timeout})
            
        default:
            guard let fileData = config.fileData else {
                fatalError("fileData 为空")
            }
            uploadRequest = AF.upload(fileData,
                                      to: url,
                                      method: config.requestMethod,
                                      headers: config.addHeads,
                                      interceptor: config.interceptor,
                                      requestModifier: { request in request.timeoutInterval = config.timeout})
            
        }

        handleUploadProgress(request: uploadRequest)
        
        return try await handleCodable(of: type, request: uploadRequest, config: config)
        
    }
    
    private func sendUploadMultipart<T: Decodable>(of type: T.Type,
                                                   modelKeyPath: String? = nil,
                                                   config: Config) async throws -> T{
        
        guard let url = config.URLString,
              !config.uploadDatas.isEmpty  else {
            fatalError("URLString / uploadDatas 为空")
        }
        
        let uploadRequest = AF.upload(multipartFormData: { multi in
            
            config.uploadDatas.forEach { multipleUpload in
                if let fileData = multipleUpload.fileData{
                    ///Data数据表单,图片等类型
                    if let fileName = multipleUpload.fileName,
                       let mimeType =  multipleUpload.mimeType {
                        
                        multi.append(fileData,
                                     withName: multipleUpload.name ?? "",
                                     fileName: fileName,
                                     mimeType: mimeType)
                    }else{
                        
                        multi.append(fileData,
                                     withName: multipleUpload.name ?? "")
                    }
                }else if let fileURL = multipleUpload.fileURL{
                    ///文件类型表单,从 URL 路径获取文件上传
                    if let fileName = multipleUpload.fileName,
                       let mimeType =  multipleUpload.mimeType {
                        
                        multi.append(fileURL,
                                     withName: multipleUpload.name ?? "",
                                     fileName: fileName,
                                     mimeType: mimeType)
                    }else{
                        
                        multi.append(fileURL,
                                     withName: multipleUpload.name ?? "")
                    }
                }
            }
        },
                                      to: url,
                                      method: config.requestMethod,
                                      headers: config.addHeads,
                                      interceptor: config.interceptor,
                                      requestModifier: { request in request.timeoutInterval = config.timeout}
        )
        
        handleUploadProgress(request: uploadRequest)
        
        return try await handleCodable(of: type, request: uploadRequest, config: config)
    }
}
