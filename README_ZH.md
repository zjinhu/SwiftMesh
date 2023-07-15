![](Image/logo.png)

[![Version](https://img.shields.io/cocoapods/v/SwiftMesh.svg?style=flat)](http://cocoapods.org/pods/SwiftMesh)
[![SPM](https://img.shields.io/badge/SPM-supported-DE5C43.svg?style=flat)](https://swift.org/package-manager/)
![Xcode 11.0+](https://img.shields.io/badge/Xcode-11.0%2B-blue.svg)
![iOS 13.0+](https://img.shields.io/badge/iOS-13.0%2B-blue.svg)
![Swift 5.0+](https://img.shields.io/badge/Swift-5.0%2B-orange.svg)



SwiftMesh是基于Alamofire和Codable的二次封装,使用Combine和Swift Concurrency,支持SwiftUI以及UIKit,去掉了闭包回调,更加简洁快速,使用更加方便。


涉及到的设计模式有：适配器，单例等等

## 用法

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



## 介绍


### Mesh：单例

* 设置默认参数     —setDefaultParameters

  ```swift
      // MARK: 设置默认参数
      /// 设置默认参数
      /// - Parameter parameters: 默认参数
      public func setDefaultParameters(_ parameters: [String: Any]?) 
  ```

* 默认header     —setGlobalHeaders

  ```swift
      // MARK: 设置全局 headers
      /// 设置全局 headers
      /// - Parameter headers:全局 headers
      public func setGlobalHeaders(_ headers: HTTPHeaders?) {
          globalHeaders = headers
      }
  ```

### Config：适配器

网络请求的配置文件，用于设置请求超时时间、请求方式，参数，header，API地址，上传用的表单等等，以及请求完成回调回来的response都在里边。

```swift
/// 网络请求配置
public class MeshConfig {
    //MARK: 请求相关配置
    /// 超时配置
    public var timeout : TimeInterval = 15.0
    /// 添加请求头
    public var addHeads : HTTPHeaders?
    /// 请求方式
    public var requestMethod : HTTPMethod = .get
    /// 请求编码
    public var requestEncoding: ParameterEncoding = URLEncoding.default  //PropertyListEncoding.xml//JSONEncoding.default
    //MARK: 请求地址以及参数
    /// 请求地址
    public var URLString : String?
    ///参数  表单上传也可以用
    public var parameters : [String: Any]?
    
```

### Request：解析请求
请结合自己的使用情况自行创建。使用ObservableObject,方便SwiftUI和UIKit混合开发使用,结合Combine。用例参考Request类：
```swift
class RequestModel: ObservableObject {
    @MainActor @Published var yesterday: Forecast?

    @MainActor @Published var cityResult: CityResult?
    
    func getAppliances() {
        Task{
            do {
                //全部解析
                //let data = try await Mesh.shared.request(of: CityResult.self, configClosure: { config in
                //config.URLString = "http://t.weather.itboy.net/api/weather/city/101030100"
                // })
                
                
                //只解析需要的部分路径
                let data = try await Mesh.shared.request(of: Forecast.self,
                                                         modelKeyPath: "data.yesterday",
                                                         configClosure: { config in
                    config.URLString = "http://t.weather.itboy.net/api/weather/city/101030100"
                })
                
                await MainActor.run {
                    self.yesterday = data
                }
                
            } catch let error {
                print(error.localizedDescription)
            }
        }
        
    }
}
```



## 安装

### Cocoapods

1.在 Podfile 中添加 `pod ‘SwiftMesh’`  

不需要Codable解析的可以直接`pod ‘SwiftMesh/Mesh’`

2.执行 `pod install 或 pod update`

3.导入 `import SwiftMesh`

### Swift Package Manager

从 Xcode 11 开始，集成了 Swift Package Manager，使用起来非常方便。SwiftMesh 也支持通过 Swift Package Manager 集成。

在 Xcode 的菜单栏中选择 `File > Swift Packages > Add Pacakage Dependency`，然后在搜索栏输入

`https://github.com/jackiehu/SwiftMesh`，即可完成集成，默认依赖Alamofire。

### 手动集成

SwiftMesh 也支持手动集成，只需把Sources文件夹中的SwiftMesh文件夹拖进需要集成的项目即可



## 更多砖块工具加速APP开发

[![ReadMe Card](https://github-readme-stats.vercel.app/api/pin/?username=jackiehu&repo=SwiftBrick&theme=radical&locale=cn)](https://github.com/jackiehu/SwiftBrick)

[![ReadMe Card](https://github-readme-stats.vercel.app/api/pin/?username=jackiehu&repo=SwiftMediator&theme=radical&locale=cn)](https://github.com/jackiehu/SwiftMediator)

[![ReadMe Card](https://github-readme-stats.vercel.app/api/pin/?username=jackiehu&repo=SwiftShow&theme=radical&locale=cn)](https://github.com/jackiehu/SwiftShow)

[![ReadMe Card](https://github-readme-stats.vercel.app/api/pin/?username=jackiehu&repo=SwiftLog&theme=radical&locale=cn)](https://github.com/jackiehu/SwiftLog)

[![ReadMe Card](https://github-readme-stats.vercel.app/api/pin/?username=jackiehu&repo=SwiftyForm&theme=radical&locale=cn)](https://github.com/jackiehu/SwiftyForm)

[![ReadMe Card](https://github-readme-stats.vercel.app/api/pin/?username=jackiehu&repo=SwiftEmptyData&theme=radical&locale=cn)](https://github.com/jackiehu/SwiftEmptyData)

[![ReadMe Card](https://github-readme-stats.vercel.app/api/pin/?username=jackiehu&repo=SwiftPageView&theme=radical&locale=cn)](https://github.com/jackiehu/SwiftPageView)

[![ReadMe Card](https://github-readme-stats.vercel.app/api/pin/?username=jackiehu&repo=JHTabBarController&theme=radical&locale=cn)](https://github.com/jackiehu/JHTabBarController)

[![ReadMe Card](https://github-readme-stats.vercel.app/api/pin/?username=jackiehu&repo=SwiftNotification&theme=radical&locale=cn)](https://github.com/jackiehu/SwiftNotification)

[![ReadMe Card](https://github-readme-stats.vercel.app/api/pin/?username=jackiehu&repo=SwiftNetSwitch&theme=radical&locale=cn)](https://github.com/jackiehu/SwiftNetSwitch)

[![ReadMe Card](https://github-readme-stats.vercel.app/api/pin/?username=jackiehu&repo=SwiftButton&theme=radical&locale=cn)](https://github.com/jackiehu/SwiftButton)

[![ReadMe Card](https://github-readme-stats.vercel.app/api/pin/?username=jackiehu&repo=SwiftDatePicker&theme=radical&locale=cn)](https://github.com/jackiehu/SwiftDatePicker)
