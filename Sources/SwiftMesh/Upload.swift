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
                                     modelKeyPath: String? = nil) async throws -> T{

        switch uploadType {
        case .multipart:
            return try await sendUploadMultipart(of: type,
                                                 modelKeyPath: modelKeyPath)
        default:
            return try await sendUpload(of: type,
                                        modelKeyPath: modelKeyPath)
        }
    }
}

extension Mesh{
    private func sendUpload<T: Decodable>(of type: T.Type,
                                          modelKeyPath: String? = nil) async throws -> T{
        
        guard let urlHost, let urlPath else {
            fatalError("urlHost OR urlPath nil")
        }
        let url = urlHost + urlPath
        
        var uploadRequest : UploadRequest
        
        switch uploadType {
        case .file:
            guard let fileURL = fileURL else {
                fatalError("fileURL nil")
            }
            uploadRequest = AF.upload(fileURL,
                                      to: url,
                                      method: requestMethod,
                                      headers: addHeads,
                                      interceptor: interceptor,
                                      requestModifier: { request in request.timeoutInterval = self.timeout})
            
        case .stream:
            guard let stream = stream else {
                fatalError("stream nil")
            }
            uploadRequest = AF.upload(stream,
                                      to: url,
                                      method: requestMethod,
                                      headers: addHeads,
                                      interceptor: interceptor,
                                      requestModifier: { request in request.timeoutInterval = self.timeout})
            
        default:
            guard let fileData = fileData else {
                fatalError("fileData nil")
            }
            uploadRequest = AF.upload(fileData,
                                      to: url,
                                      method: requestMethod,
                                      headers: addHeads,
                                      interceptor: interceptor,
                                      requestModifier: { request in request.timeoutInterval = self.timeout})
            
        }

        handleUploadProgress(request: uploadRequest)
        
        return try await handleCodable(of: type,
                                       request: uploadRequest,
                                       modelKeyPath: modelKeyPath)
        
    }
    
    private func sendUploadMultipart<T: Decodable>(of type: T.Type,
                                                   modelKeyPath: String? = nil) async throws -> T{

        guard let urlHost, let urlPath, !uploadDatas.isEmpty else {
            fatalError("urlHost OR urlPath OR uploadDatas nil")
        }
        let url = urlHost + urlPath
        
        let uploadRequest = AF.upload(multipartFormData: { multi in
            
            self.uploadDatas.forEach { multipleUpload in
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
                                      method: requestMethod,
                                      headers: addHeads,
                                      interceptor: interceptor,
                                      requestModifier: { request in request.timeoutInterval = self.timeout}
        )
        
        handleUploadProgress(request: uploadRequest)
        
        return try await handleCodable(of: type,
                                       request: uploadRequest,
                                       modelKeyPath: modelKeyPath)
    }
}
