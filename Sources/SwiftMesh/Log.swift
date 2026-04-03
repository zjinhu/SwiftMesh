//
//  Log.swift
//  SwiftMesh
//
//  Created by iOS on 2023/6/13.
//

import Foundation
import Alamofire
import os

// MARK: - Network Logging
// MARK: - 网络日志

extension MeshLog {

    /// Start observing and logging all Alamofire network requests.
    /// Logs cURL commands, HTTP status codes, elapsed time, and pretty-printed JSON responses.
    /// 开始观察并记录所有 Alamofire 网络请求。
    /// 记录 cURL 命令、HTTP 状态码、耗时和格式化后的 JSON 响应。
    func startLogging() {
        stopLogging()

        NotificationCenter.default.addObserver(forName: Request.didFinishNotification, object: nil, queue: .main) { notification in
            guard let dataRequest = notification.request as? DataRequest,
                  let task = dataRequest.task,
                  let metrics = dataRequest.metrics,
                  let request = task.originalRequest,
                  let httpMethod = request.httpMethod,
                  let requestURL = request.url
            else { return }

            let elapsedTime = metrics.taskInterval.duration

            if let error = task.error {
                // Log error details / 记录错误详情
                self.logDivider("Alamofire Error", level: .error)
                self.logMessage("[Error] \(httpMethod) '\(requestURL.absoluteString)' [\(String(format: "%.04f", elapsedTime)) s]:", level: .error)
                self.logMessage("\(error)", level: .error)
                self.logDivider("Alamofire END", level: .error)
            } else {
                guard let response = task.response as? HTTPURLResponse else { return }
                let cURL = dataRequest.cURLDescription()

                self.logDivider("Alamofire Log", level: .debug)
                self.logMessage("\(cURL)", level: .debug)

                self.logDivider("State", level: .debug)
                self.logMessage("\(String(response.statusCode)) [\(String(format: "%.04f", elapsedTime)) s]:", level: .debug)

                guard let data = dataRequest.data else { return }

                self.logDivider("Response", level: .debug)

                do {
                    // Pretty-print JSON response / 格式化 JSON 响应
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)

                    if let prettyString = String(data: prettyData, encoding: .utf8) {
                        self.logMessage("\(prettyString)", level: .debug)
                    }
                } catch {
                    // Fallback to raw string if not valid JSON / 如果不是有效 JSON 则回退到原始字符串
                    if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                        self.logMessage("\(string)", level: .debug)
                    }
                }
                self.logDivider("Alamofire END", level: .debug)
            }
        }
    }

    /// Stop logging and remove all observers.
    /// 停止日志记录并移除所有观察者。
    func stopLogging() {
        NotificationCenter.default.removeObserver(self)
    }

    /// Log a divider line for visual separation.
    /// 记录分隔线以进行视觉分隔。
    private func logDivider(_ text: String, level: OSLogType) {
        logMessage("<><><><><>-「\(text)」-<><><><><>", level: level)
    }

    /// Log HTTP headers as key-value pairs.
    /// 以键值对形式记录 HTTP 请求头。
    private func logHeaders(headers: [AnyHashable: Any], level: OSLogType) {
        for (key, value) in headers {
            logMessage("\(key): \(value)", level: level)
        }
    }

    /// Log a message using the appropriate output method (print or os.log).
    /// 使用适当的输出方法（print 或 os.log）记录消息。
    private func logMessage(_ text: String, level: OSLogType) {
        if type == .print {
            switch level {
            case .error:
                print("⭕️\(text)")
            default:
                print("🌐\(text)")
            }
        } else {
            switch level {
            case .error:
                error(text)
            default:
                debug(text)
            }
        }
    }
}

/// Log output mode enumeration
/// 日志输出模式枚举
public enum LogType {
    /// Use Swift's print() function / 使用 Swift 的 print() 函数
    case print
    /// Use Apple's unified Logger framework (os.log) / 使用 Apple 统一日志框架 (os.log)
    case log
}

/// Singleton network logger
/// 单例网络日志记录器
class MeshLog {
    /// Shared singleton instance / 共享单例实例
    static let shared = MeshLog()

    /// Apple unified Logger / Apple 统一日志记录器
    private let logger: Logger

    /// Current log output mode / 当前日志输出模式
    public var type: LogType = .log

    /// Initialize with custom subsystem and category (defaults to "Mesh")
    /// 使用自定义子系统和类别初始化（默认为 "Mesh"）
    public init(subsystem: String = "Mesh", category: String = "Mesh") {
        self.logger = Logger(subsystem: subsystem, category: category)
    }
}

fileprivate extension MeshLog {

    /// Log a debug message using the unified Logger
    /// 使用统一日志记录器记录调试消息
    func debug(_ message: String) {
        logger.log("🌐\(message, privacy: .public)")
    }

    /// Log an error message using the unified Logger
    /// 使用统一日志记录器记录错误消息
    func error(_ message: String) {
        logger.log("⭕️\(message, privacy: .public)")
    }
}
