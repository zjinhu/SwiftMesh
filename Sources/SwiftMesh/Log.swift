//
//  Log.swift
//  SwiftMesh
//
//  Created by iOS on 2023/6/13.
//

import Foundation
import Alamofire
import os
extension Mesh {

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
                switch self.log {
                case .debug, .info, .error:
                    self.logDivider("Alamofire Error", level: .error)
                     
                    self.logMessage("[Error] \(httpMethod) '\(requestURL.absoluteString)' [\(String(format: "%.04f", elapsedTime)) s]:", level: .error)
                    self.logMessage("\(error)", level: .error)
                    
                    self.logDivider("Alamofire END", level: .error)
                default:
                    break
                }
            } else {
                guard let response = task.response as? HTTPURLResponse else { return }
                let cURL = dataRequest.cURLDescription()
                
                switch self.log {
                case .debug:
   
                    self.logDivider("Alamofire Log", level: .debug)
                     
                    self.logMessage("\(httpMethod) '\(requestURL.absoluteString)'", level: .debug)
                     
                    self.logMessage("\(cURL)", level: .debug)
                    
                    self.logDivider("状态", level: .debug)
                     
                    self.logMessage("\(String(response.statusCode)) [\(String(format: "%.04f", elapsedTime)) s]:", level: .debug)
                    
                    self.logDivider("Header", level: .debug)
                    
                    self.logHeaders(headers: response.allHeaderFields, level: .debug)
                    
                    guard let data = dataRequest.data else { break }
                    
                    self.logDivider("报文", level: .debug)
                    
                    do {
                        let jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                        let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
                        
                        if let prettyString = String(data: prettyData, encoding: .utf8) {
                            self.logMessage("\(prettyString)", level: .debug)
                        }
                    } catch {
                        if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                            self.logMessage("\(string)", level: .debug)
                        }
                    }
                    self.logDivider("Alamofire END", level: .debug)
                    
                case .info:
                    self.logDivider("Alamofire Log", level: .info)
                     
                    self.logMessage("\(cURL)", level: .info)
                    
                    self.logDivider("状态", level: .info)
 
                    self.logMessage("\(String(response.statusCode)) [\(String(format: "%.04f", elapsedTime)) s]", level: .info)
                    
                    self.logDivider("Alamofire END", level: .info)
                default:
                    break
                }
            }
        }
    }
     
    func stopLogging() {
        NotificationCenter.default.removeObserver(self)
    }

    private func logDivider(_ text: String, level: OSLogType) {
        logMessage("<><><><><>-「\(text)」-<><><><><>", level: level)
    }
    
    private func logHeaders(headers: [AnyHashable : Any], level: OSLogType) {
        for (key, value) in headers {
            logMessage("\(key): \(value)", level: level)
        }
    }
    
    private func logMessage(_ text: String, level: OSLogType) {
        if #available(iOS 14.0, *) {
            logger.log(text, level: level)
        } else {
            debugPrint(text)
        }
    }
    
}
 
@available(iOS 14.0, *)
fileprivate let logger = MeshLog()
@available(iOS 14.0, *)
fileprivate struct MeshLog {
    private let logger: Logger
 
    public init(subsystem: String = "Mesh", category: String = "Mesh") {
        self.logger = Logger(subsystem: subsystem, category: category)
    }
}
@available(iOS 14.0, *)
fileprivate extension MeshLog {
    func log(_ message: String, level: OSLogType = .default,  isPrivate: Bool = false) {
        if isPrivate {
            logger.log(level: level, "\(message, privacy: .private)")
        } else {
            logger.log(level: level, "\(message, privacy: .public)")
        }
    }
}
