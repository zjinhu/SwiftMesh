# SwiftMesh
基于Alamofire和Codable的二次封装，更加方便的使用。
## 介绍
### MeshCertificate
针对于Alamofire的证书验证做了一层封装
`trustServerCertificate`信任服务端证书
`cheakMeshCertificate`验证 Https 证书，主要是本地证书和服务端证书对比
### MeshManager
单例。
其中包括：
* 获取网络状态    —isReachableWiFi、isReachableWWAN
* 是否联网      —isReachable
* 设置默认参数     —setDefaultParameters
* 默认header     —setGlobalHeaders
* 是否打印日志     —canLogging
* 取消/清空请求     -cancelRequest/cancelAllRequest
* 上传/下载/普通请求   - - 所有请求都通过配置文件方式传递参数以及请求结果，通过闭包设置配置文件的属性即可，详情参看配置文件注释，用法参照`MeshRequest`。
#### MeshConfig
网络请求的配置文件，用于设置请求超时时间、请求方式，参数，header，API地址，上传用的表单等等，以及请求完成回调回来的response都在里边。
详情请看注释！
### MeshRequest
对Post、Get网络请求的Codable封装，通过设置泛型model回调生成好的Model，方便使用。用例：
```
 MeshRequest<TestModel>.get(“https://api.apiopen.top/getJoke?page=1&count=2&type=video”) { (model) in
            print(model!)
        }
```

##  安装
### cocoapods导入
不需要Codable解析的可以直接`pod ‘SwiftMesh/Mesh’`
默认情况`pod ‘SwiftMesh‘`
依赖Alamofire5.0版本的请pod 1.0版本以上，1.0版本以下为依赖Alamofire4.9.1
### 手动导入
拖入代码即可
