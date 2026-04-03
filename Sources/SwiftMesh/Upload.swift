//
//  Upload.swift
//  SwiftMesh
//
//  Created by iOS on 2023/6/13.
//

import Foundation
import Alamofire

extension Mesh {

    // MARK: - File Upload Entry Point
    // MARK: - 文件上传入口

    /**
     Multipart form upload example / 多部分表单上传示例:

     ```swift
     try await Mesh()
         .setRequestMethod(.post)
         .setUrlHost("http://192.168.0.18:8887/api/podcast/v1/")
         .setUrlPath("upload/image")
         .setUploadType(.multipart)
         .setAddformData(name: "file",
                         fileName: "file.jpg",
                         fileData: imageData,
                         mimeType: "image/jpeg")
         .upload(of: EditResult.self)
     ```
     */

    /// Upload a file and decode the response into a Codable type.
    /// Dispatches to the appropriate upload method based on `uploadType`.
    /// 上传文件并将响应解码为 Codable 类型。
    /// 根据 `uploadType` 分发到对应的上传方法。
    ///
    /// - Parameters:
    ///   - type: The Decodable model type for the response / 响应数据模型类型
    ///   - modelKeyPath: Optional dot-separated key path for nested JSON extraction
    ///                   可选的点分隔键路径，用于嵌套 JSON 提取
    /// - Returns: Decoded response model / 解码后的响应模型
    /// - Throws: Network or decoding errors / 网络或解码错误
    public func upload<T: Decodable>(of type: T.Type,
                                     modelKeyPath: String? = nil) async throws -> T {

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

extension Mesh {

    // MARK: - Single File Upload
    // MARK: - 单文件上传

    /// Upload a single file (via URL, Data, or InputStream).
    /// 上传单个文件（通过 URL、Data 或 InputStream）。
    private func sendUpload<T: Decodable>(of type: T.Type,
                                          modelKeyPath: String? = nil) async throws -> T {

        let url = checkUrl()
        mergeConfig()
        var uploadRequest: UploadRequest

        switch uploadType {
        case .file:
            // Upload from file URL / 通过文件 URL 上传
            guard let fileURL = fileURL else {
                fatalError("fileURL nil — 文件 URL 不能为空")
            }
            uploadRequest = AF.upload(fileURL,
                                      to: url,
                                      method: requestMethod,
                                      headers: HTTPHeaders(addHeads),
                                      interceptor: interceptor,
                                      requestModifier: { request in request.timeoutInterval = self.timeout })

        case .stream:
            // Upload from InputStream / 通过输入流上传
            guard let stream = stream else {
                fatalError("stream nil — 输入流不能为空")
            }
            uploadRequest = AF.upload(stream,
                                      to: url,
                                      method: requestMethod,
                                      headers: HTTPHeaders(addHeads),
                                      interceptor: interceptor,
                                      requestModifier: { request in request.timeoutInterval = self.timeout })

        default:
            // Upload from Data object / 通过 Data 对象上传
            guard let fileData = fileData else {
                fatalError("fileData nil — 文件 Data 不能为空")
            }
            uploadRequest = AF.upload(fileData,
                                      to: url,
                                      method: requestMethod,
                                      headers: HTTPHeaders(addHeads),
                                      interceptor: interceptor,
                                      requestModifier: { request in request.timeoutInterval = self.timeout })
        }

        return try await handleCodable(of: type,
                                       request: uploadRequest,
                                       modelKeyPath: modelKeyPath)
    }

    // MARK: - Multipart Form Upload
    // MARK: - 多部分表单上传

    /// Upload files using multipart form data.
    /// Iterates over `uploadDatas` and appends each entry as a form field.
    /// Also appends regular parameters as form fields.
    /// 使用多部分表单数据上传文件。
    /// 遍历 `uploadDatas` 并将每个条目添加为表单字段。
    /// 同时将普通参数也添加为表单字段。
    private func sendUploadMultipart<T: Decodable>(of type: T.Type,
                                                   modelKeyPath: String? = nil) async throws -> T {

        let url = checkUrl()
        mergeConfig()
        let uploadRequest = AF.upload(multipartFormData: { multi in

            self.uploadDatas.forEach { multipleUpload in
                if let fileData = multipleUpload.fileData {
                    // Data-based form field (e.g., images) / Data 类型表单字段（如图片）
                    if let fileName = multipleUpload.fileName,
                       let mimeType = multipleUpload.mimeType {

                        multi.append(fileData,
                                     withName: multipleUpload.name ?? "",
                                     fileName: fileName,
                                     mimeType: mimeType)
                    } else {
                        multi.append(fileData,
                                     withName: multipleUpload.name ?? "")
                    }
                } else if let fileURL = multipleUpload.fileURL {
                    // File URL-based form field / 文件 URL 类型表单字段
                    if let fileName = multipleUpload.fileName,
                       let mimeType = multipleUpload.mimeType {

                        multi.append(fileURL,
                                     withName: multipleUpload.name ?? "",
                                     fileName: fileName,
                                     mimeType: mimeType)
                    } else {
                        multi.append(fileURL,
                                     withName: multipleUpload.name ?? "")
                    }
                }
            }

            // Append regular parameters as form fields
            // 将普通参数添加为表单字段
            if let parameters = self.parameters {
                for (key, value) in parameters {
                    let data = "\(value)".data(using: .utf8) ?? Data()
                    multi.append(data, withName: key)
                }
            }
        },
        to: url,
        method: requestMethod,
        headers: HTTPHeaders(addHeads),
        interceptor: interceptor,
        requestModifier: { request in request.timeoutInterval = self.timeout }
        )

        return try await handleCodable(of: type,
                                       request: uploadRequest,
                                       modelKeyPath: modelKeyPath)
    }
}
