//
//  Download.swift
//  SwiftMesh
//
//  Created by iOS on 2023/6/13.
//

import Foundation
import Alamofire
extension Mesh{
    
    /// 下载文件
    /// - Parameter configClosure: 根据需要需要设置config的 downloadType destination resumeData参数
    /// - Returns: 返回下载后文件地址
    public func download(_ configClosure: (_ config: Config) -> Void) async throws -> URL{
        
        let config = Config()
        configClosure(config)
        
        switch config.downloadType {
        case .resume:
            return try await sendDownloadResume(config)
        default:
            return try await sendDownload(config)
        }
    }
}

extension Mesh{
    private func sendDownload(_ config: Config) async throws -> URL{
        guard let url = config.URLString else {
            fatalError("URLString 为空")
        }
        let request = AF.download(url,
                                  method: config.requestMethod,
                                  parameters: config.parameters,
                                  encoding: config.requestEncoding,
                                  headers: config.addHeads,
                                  interceptor: config.interceptor,
                                  requestModifier: { request in request.timeoutInterval = config.timeout},
                                  to: config.destination)
        
        handleDownloadProgress(request: request)
        
        return try await handleDownload(request: request)
        
    }
    
    private func sendDownloadResume(_ config: Config) async throws -> URL{
        guard let resumeData = config.resumeData else {
            fatalError("resumeData 为空")
        }
        
        let request = AF.download(resumingWith: resumeData,
                                  interceptor: config.interceptor,
                                  to: config.destination)
        
        handleDownloadProgress(request: request)
        
        return try await handleDownload(request: request)
    }
}
