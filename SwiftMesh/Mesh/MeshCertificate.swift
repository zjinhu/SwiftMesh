//
//  MeshCertificate.swift
//  SwiftMesh
//
//  Created by iOS on 2019/12/31.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit
import Alamofire
open class MeshCertificate {
    
    /// 信任服务端证书
    public class func trustServerCertificate(){
        SessionManager.default.delegate.sessionDidReceiveChallenge = { (session: URLSession, challenge: URLAuthenticationChallenge) in
            return MeshCertificate.trustServer(challenge: challenge)
        }
    }
    /// 验证 Https 证书
    /// - Parameters:
    ///   - name: 证书名称
    ///   - psw: 证书密码
    ///   - type: 证书类型 cer der p12 等等
    public class func cheakMeshCertificate(name: String?, psw: String? = nil, type: String) {
        SessionManager.default.delegate.sessionDidReceiveChallenge = { (session: URLSession, challenge: URLAuthenticationChallenge) in
            let method = challenge.protectionSpace.authenticationMethod
            if method == NSURLAuthenticationMethodServerTrust {
                //验证服务器，直接信任或者验证证书二选一，推荐验证证书，更安全
                return MeshCertificate.trustServerWithCer(name: name, type: type,challenge: challenge)
                //                return HTTPSManager.trustServer(challenge: challenge)
            } else if method == NSURLAuthenticationMethodClientCertificate {
                //认证客户端证书
                return MeshCertificate.sendClientCer(name: name, psw: psw, type: type)
            } else {
                //其他情况，不通过验证
                return (.cancelAuthenticationChallenge, nil)
            }
        }
    }
    
    //不做任何验证，直接信任服务器
    class private func trustServer(challenge: URLAuthenticationChallenge) -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        
        let disposition = URLSession.AuthChallengeDisposition.useCredential
        let credential = URLCredential.init(trust: challenge.protectionSpace.serverTrust!)
        return (disposition, credential)
    }
    
    //验证服务器证书
    class private func trustServerWithCer(name: String?, type: String,challenge: URLAuthenticationChallenge) -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        
        var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
        var credential: URLCredential?
        
        //获取服务器发送过来的证书
        let serverTrust:SecTrust = challenge.protectionSpace.serverTrust!
        let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0)!
        let remoteCertificateData = CFBridgingRetain(SecCertificateCopyData(certificate))!
        
        //加载本地CA证书
        let cerPath = Bundle.main.path(forResource: name, ofType: type)!
        let cerUrl = URL(fileURLWithPath:cerPath)
        let localCertificateData = try! Data(contentsOf: cerUrl)
        if (remoteCertificateData.isEqual(localCertificateData) == true) {
            //服务器证书验证通过
            disposition = URLSession.AuthChallengeDisposition.useCredential
            credential = URLCredential(trust: serverTrust)
        } else {
            //服务器证书验证失败
            disposition = URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge
        }
        return (disposition, credential)
    }
    
    //发送客户端证书交由服务器验证
    class private func sendClientCer(name: String?, psw: String? = nil, type: String) -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        
        let disposition = URLSession.AuthChallengeDisposition.useCredential
        var credential: URLCredential?
        
        //获取项目中P12证书文件的路径
        let path: String = Bundle.main.path(forResource: name, ofType: type)!
        let PKCS12Data = NSData(contentsOfFile:path)!
        let key : NSString = kSecImportExportPassphrase as NSString
        let options : NSDictionary = [key : psw as Any] //客户端证书密码
        
        var items: CFArray?
        let error = SecPKCS12Import(PKCS12Data, options, &items)
        
        if error == errSecSuccess {
            
            let itemArr = items! as Array
            let item = itemArr.first!
            
            let identityPointer = item["identity"];
            let secIdentityRef = identityPointer as! SecIdentity
            
            let chainPointer = item["chain"]
            let chainRef = chainPointer as? [Any]
            
            credential = URLCredential.init(identity: secIdentityRef, certificates: chainRef, persistence: URLCredential.Persistence.forSession)
        }
        return (disposition, credential)
    }
}
