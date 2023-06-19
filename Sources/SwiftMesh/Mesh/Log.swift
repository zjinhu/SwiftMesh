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
                    self.logDivider("Alamofire Error")
                     
                    self.logMessage("[Error] \(httpMethod) '\(requestURL.absoluteString)' [\(String(format: "%.04f", elapsedTime)) s]:")
                    self.logMessage("\(error)")
                    
                    self.logDivider("Alamofire END")
                default:
                    break
                }
            } else {
                guard let response = task.response as? HTTPURLResponse else { return }
                let cURL = dataRequest.cURLDescription()
                
                switch self.log {
                case .debug:
   
                    self.logDivider("Alamofire Log")
                     
                    self.logMessage("\(httpMethod) '\(requestURL.absoluteString)'")
                     
                    self.logMessage("\(cURL)")
                    
                    self.logDivider("状态")
                     
                    self.logMessage("\(String(response.statusCode)) [\(String(format: "%.04f", elapsedTime)) s]:")
                    
                    self.logDivider("Header")
                    
                    self.logHeaders(headers: response.allHeaderFields)
                    
                    guard let data = dataRequest.data else { break }
                    
                    self.logDivider("报文")
                    
                    do {
                        let jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                        let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
                        
                        if let prettyString = String(data: prettyData, encoding: .utf8) {
                            print(prettyString)
                        }
                    } catch {
                        if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                            print(string)
                        }
                    }
                    self.logDivider("Alamofire END")
                case .info:
                    self.logDivider("Alamofire Log")
                    
                    print("\(cURL)")
                    self.logDivider("状态")
 
                    self.logMessage("\(String(response.statusCode)) [\(String(format: "%.04f", elapsedTime)) s]")
                    
                    self.logDivider("Alamofire END")
                default:
                    break
                }
            }
        }
    }
     
    func stopLogging() {
        NotificationCenter.default.removeObserver(self)
    }

    private func logDivider(_ text: String) {
        logMessage("<><><><><>-「\(text)」-<><><><><>")
    }
    
    private func logHeaders(headers: [AnyHashable : Any]) {
        for (key, value) in headers {
            logMessage("\(key): \(value)")
        }
    }
    
    private func logMessage(_ text: String) {
        if #available(iOS 14.0, *) {
            logger.log(text)
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
 
    public init(subsystem: String = "SwiftMesh", category: String = "Mesh") {
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
