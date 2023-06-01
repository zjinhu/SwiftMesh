
Pod::Spec.new do |s|
  s.name             = 'SwiftMesh'
  s.version          = '2.1.5'
  s.summary          = '网络请求组件.'
 
  s.description      = <<-DESC
							工具.
                       DESC

  s.homepage         = 'https://github.com/jackiehu/' 
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'HU' => '814030966@qq.com' }
  s.source           = { :git => 'https://github.com/jackiehu/SwiftMesh.git', :tag => s.version.to_s }

  s.ios.deployment_target = "13.0"
  s.swift_versions     = ['5.5','5.4','5.3','5.2','5.1','5.0']
  s.requires_arc = true

  s.frameworks   =  "Foundation" #支持的框架
  s.dependency 'Alamofire' 
  s.source_files = 'Sources/SwiftMesh/Mesh/**/*' 
 
end
