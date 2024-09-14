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
    public func download() async throws -> URL{

        switch downloadType {
        case .resume:
            return try await sendDownloadResume()
        default:
            return try await sendDownload()
        }
    }
}

extension Mesh{
    private func sendDownload() async throws -> URL{
 
        let url = checkUrl()
        mergeConfig()
        let request = AF.download(url,
                                  method: requestMethod,
                                  parameters: parameters,
                                  encoding: requestEncoding,
                                  headers: HTTPHeaders(addHeads),
                                  interceptor: interceptor,
                                  requestModifier: { request in request.timeoutInterval = self.timeout},
                                  to: destination)
//        handleDownloadProgress(request: request)
        return try await handleDownload(request: request)
        
    }
    
    private func sendDownloadResume() async throws -> URL{
        guard let resumeData = resumeData else {
            fatalError("resumeData nil")
        }
        
        let request = AF.download(resumingWith: resumeData,
                                  interceptor: interceptor,
                                  to: destination)
//        handleDownloadProgress(request: request)
        return try await handleDownload(request: request)
    }
}
