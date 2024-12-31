//
//  Log.swift
//  SwiftMesh
//
//  Created by iOS on 2023/6/13.
//

import Foundation
import Alamofire
import os

extension MeshLog {
    
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
                
                self.logDivider("Alamofire Error", level: .error)
                
                self.logMessage("[Error] \(httpMethod) '\(requestURL.absoluteString)' [\(String(format: "%.04f", elapsedTime)) s]:", level: .error)
                self.logMessage("\(error)", level: .error)
                
                self.logDivider("Alamofire END", level: .error)
                
            } else {
                guard let response = task.response as? HTTPURLResponse else { return }
                let cURL = dataRequest.cURLDescription()
                
                self.logDivider("Alamofire Log", level: .debug)
                //                self.logMessage("\(httpMethod) '\(requestURL.absoluteString)'", level: .debug)
                self.logMessage("\(cURL)", level: .debug)
                
                self.logDivider("State", level: .debug)
                
                self.logMessage("\(String(response.statusCode)) [\(String(format: "%.04f", elapsedTime)) s]:", level: .debug)
                //                self.logDivider("Header", level: .debug)
                //                self.logHeaders(headers: response.allHeaderFields, level: .debug)
                guard let data = dataRequest.data else { return }
                
                self.logDivider("Response", level: .debug)
                
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

        if type == .print {
            switch level {
            case .error:
                print("⭕️\(text)")
            default:
                print("🌐\(text)")
            }
        }else{
            switch level {
            case .error:
                error(text)
            default:
                debug(text)
            }
        }
    }
    
}

public enum LogType{
    case print
    case log
}

class MeshLog {
    static let shared = MeshLog()
    
    private let logger: Logger
    
    public var type: LogType = .log
    
    public init(subsystem: String = "Mesh", category: String = "Mesh") {
        self.logger = Logger(subsystem: subsystem, category: category)
    }
    
}

fileprivate extension MeshLog {
    
    func debug(_ message: String){
        logger.log("🌐\(message, privacy: .public)")
    }
    
    func error(_ message: String){
        logger.log("⭕️\(message, privacy: .public)")
    }
}
