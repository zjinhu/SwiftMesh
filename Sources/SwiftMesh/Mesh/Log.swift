//
//  Log.swift
//  SwiftMesh
//
//  Created by iOS on 2023/6/13.
//

import Foundation
import Alamofire

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
                    
                    print("[Error] \(httpMethod) '\(requestURL.absoluteString)' [\(String(format: "%.04f", elapsedTime)) s]:")
                    print(error)
                    
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
                    
                    print("\(httpMethod) '\(requestURL.absoluteString)'")
                    
                    print("\n\n\(cURL)")
                    
                    self.logDivider("状态")
                    
                    print("\(String(response.statusCode)) [\(String(format: "%.04f", elapsedTime)) s]:")
                    
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
                    
                    print("\(String(response.statusCode)) [\(String(format: "%.04f", elapsedTime)) s]")
                    
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
        print("\n\n<><><><><>-「\(text)」-<><><><><>\n\n")
    }
    
    private func logHeaders(headers: [AnyHashable : Any]) {
        print("[")
        for (key, value) in headers {
            print("  \(key): \(value)")
        }
        print("]")
    }
}
