//
//  Download.swift
//  SwiftMesh
//
//  Created by iOS on 2023/6/13.
//

import Foundation
import Alamofire

extension Mesh {

    // MARK: - File Download Entry Point
    // MARK: - 文件下载入口

    /// Download a file and return the local file URL.
    /// Dispatches based on `downloadType`: standard or resumable.
    /// 下载文件并返回本地文件 URL。
    /// 根据 `downloadType` 分发：普通下载或断点续传。
    ///
    /// - Returns: Local file URL of the downloaded file / 下载文件的本地 URL
    /// - Throws: Network errors / 网络错误
    public func download() async throws -> URL {

        switch downloadType {
        case .resume:
            // Resumable download / 断点续传
            return try await sendDownloadResume()
        default:
            // Standard download / 普通下载
            return try await sendDownload()
        }
    }
}

extension Mesh {

    // MARK: - Standard Download
    // MARK: - 普通下载

    /// Perform a standard file download.
    /// 执行普通文件下载。
    private func sendDownload() async throws -> URL {

        let url = checkUrl()
        mergeConfig()
        let request = AF.download(url,
                                  method: requestMethod,
                                  parameters: parameters,
                                  encoding: requestEncoding,
                                  headers: HTTPHeaders(addHeads),
                                  interceptor: interceptor,
                                  requestModifier: { request in request.timeoutInterval = self.timeout },
                                  to: destination)

        return try await handleDownload(request: request)
    }

    // MARK: - Resumable Download
    // MARK: - 断点续传下载

    /// Resume an interrupted download using resumeData.
    /// resumeData is obtained from a previous failed download response.
    /// 使用 resumeData 恢复中断的下载。
    /// resumeData 来自之前失败的下载响应。
    private func sendDownloadResume() async throws -> URL {
        guard let resumeData = resumeData else {
            fatalError("resumeData nil — 续传数据不能为空")
        }

        let request = AF.download(resumingWith: resumeData,
                                  interceptor: interceptor,
                                  to: destination)

        return try await handleDownload(request: request)
    }
}
