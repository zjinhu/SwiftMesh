![](Image/logo.png)

[![Version](https://img.shields.io/cocoapods/v/SwiftMesh.svg?style=flat)](http://cocoapods.org/pods/SwiftMesh)
[![SPM](https://img.shields.io/badge/SPM-supported-DE5C43.svg?style=flat)](https://swift.org/package-manager/)
![Xcode 11.0+](https://img.shields.io/badge/Xcode-11.0%2B-blue.svg)
![iOS 13.0+](https://img.shields.io/badge/iOS-13.0%2B-blue.svg)
![Swift 5.0+](https://img.shields.io/badge/Swift-5.0%2B-orange.svg)



SwiftMesh is a secondary encapsulation based on Alamofire and Codable, uses Combine and Swift Concurrency, supports SwiftUI and UIKit, removes closure callbacks, is more concise, faster, and more convenient to use.


The design patterns involved are: adapter, singleton, etc.

## Usage

#### Swift+UIKit：

```swift
import UIKit
import Combine
import SwiftMesh
class ViewController: UIViewController {
    var request = RequestModel()
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        request.getAppliances()
        
        request.$cityResult
            .receive(on: RunLoop.main)
            .sink { (model) in
                print("请求数据Model \(String(describing: model))")
         }.store(in: &cancellables)
        
        request.$yesterday
            .receive(on: RunLoop.main)
            .sink { (model) in
                print("请求数据Model \(String(describing: model))")
         }.store(in: &cancellables)
    }
 
}


```

#### SwiftUI：

```swift
struct SwiftUIView: View {
    @StateObject var request = RequestModel()
    
    var body: some View {
        
        VStack{
            Text("Hello, World!")
            Text(request.cityResult?.message ?? "")
            Text(request.yesterday?.notice ?? "")
        }.onAppear{
            request.getAppliances()
        }
    }
    
}
```



## Example


### Mesh：singleton

* Set default parameters     —setDefaultParameters

  ```swift
      // MARK: 设置默认参数
      /// 设置默认参数
      /// - Parameter parameters: 默认参数
     func setDefaultParameters(_ parameters: [String: Any]?) -> Self
  ```

* Set default header     —setGlobalHeaders

  ```swift
      // MARK: 设置全局 headers
      /// 设置全局 headers
      /// - Parameter headers:全局 headers
      func setGlobalHeaders(_ headers: HTTPHeaders?)  -> Self
  ```

### Config：adapter

The configuration file of the network request is used to set the request timeout, request method, parameters, header, API address, upload form, etc., and the response returned after the request is completed.

```swift
///设置日志输出级别
    func logStatus(_ log: LogLevel) -> Self 
    /// 超时配置
    func timeout(_ timeout: TimeInterval) -> Self
    ///请求失败重试策略
    func interceptor(_ interceptor: RequestInterceptor?) -> Self
    /// 请求方式
    func requestMethod(_ requestMethod: HTTPMethod) -> Self 
    /// 添加请求头
    func addHeads(_ addHeads: HTTPHeaders?) -> Self 
    /// 请求编码
    func requestEncoding(_ requestEncoding: ParameterEncoding) -> Self 
    /// 请求地址
    func url(_ url: String?) -> Self
    ///参数  表单上传也用
    func parameters(_ parameters: [String: Any]?) -> Self 
    //下载类型
    func downloadType(_ downloadType: DownloadType) -> Self 
    //设置文件下载地址覆盖方式等等
    func destination(_ destination: @escaping DownloadRequest.Destination) -> Self
    ///已经下载的部分,下载续传用,从请求结果中获取
    func resumeData(_ resumeData: Data?) -> Self
    //上传类型
    func uploadType(_ uploadType: UploadType) -> Self 
    ///上传文件地址
    func fileURL(_ fileURL: URL?) -> Self
    ///上传文件地址
    func fileData(_ fileData: Data?) -> Self 
    ///上传文件InputStream
    func stream(_ stream: InputStream?) -> Self
    ///表单数据
    func uploadDatas(_ uploadDatas: [MultipleUpload]) -> Self 
    /// 表单数组快速添加表单
    /// - Parameters:
    ///   - name: 表单 name 必须
    ///   - fileName: 文件名
    ///   - fileData: 文件 Data
    ///   - fileURL:  文件地址
    ///   - mimeType: 数据类型
    func addformData(name: String,
                     fileName: String? = nil,
                     fileData: Data? = nil,
                     fileURL: URL? = nil,
                     mimeType: String? = nil)  -> Self
```

### Request：parse request
Please create it yourself based on your usage. Use ObservableObject to facilitate the mixed development of SwiftUI and UIKit, combined with Combine. Use case reference Request class:
```swift
class RequestModel: ObservableObject {
     @MainActor @Published var yesterday: Forecast?

     @MainActor @Published var cityResult: CityResult?
    
     func getAppliances() {
         Task {
             do {

                 // Only parse the required part of the path
                let data  =
            try await Mesh.shared
                .requestMethod(.get)
                .url("http://t.weather.itboy.net/api/weather/city/101030100")
                .request(of: Forecast.self, modelKeyPath: "data.yesterday")

                await MainActor.run {
                    self.yesterday = data
                }
 
             } catch let error {
                 print(error. localizedDescription)
             }
         }
        
     }
}
```



## Install

### Cocoapods

1. Add `pod 'SwiftMesh'` to Podfile

2. Execute `pod install or pod update`

3. Import `import SwiftMesh`

### Swift Package Manager

Starting from Xcode 11, the Swift Package Manager is integrated, which is very convenient to use. SwiftMesh also supports integration via the Swift Package Manager.

Select `File > Swift Packages > Add Pacakage Dependency` in Xcode's menu bar, and enter in the search bar

`https://github.com/jackiehu/SwiftMesh`, you can complete the integration and rely on Alamofire by default.

### Manual integration

SwiftMesh also supports manual integration, just drag the SwiftMesh folder in the Sources folder into the project that needs to be integrated



## More tools to speed up APP development

[![ReadMe Card](https://github-readme-stats.vercel.app/api/pin/?username=jackiehu&repo=SwiftBrick&theme=radical&locale=cn)](https://github.com/jackiehu/SwiftBrick)

[![ReadMe Card](https://github-readme-stats.vercel.app/api/pin/?username=jackiehu&repo=SwiftMediator&theme=radical&locale=cn)](https://github.com/jackiehu/SwiftMediator)

[![ReadMe Card](https://github-readme-stats.vercel.app/api/pin/?username=jackiehu&repo=SwiftLog&theme=radical&locale=cn)](https://github.com/jackiehu/SwiftLog)

[![ReadMe Card](https://github-readme-stats.vercel.app/api/pin/?username=jackiehu&repo=SwiftNotification&theme=radical&locale=cn)](https://github.com/jackiehu/SwiftNotification)

