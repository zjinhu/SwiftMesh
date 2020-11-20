
Pod::Spec.new do |s|
  s.name             = 'SwiftMesh'
  s.version          = '1.5.0'
  s.summary          = '网络请求组件.'
 
  s.description      = <<-DESC
							工具.
                       DESC

  s.homepage         = 'https://github.com/jackiehu/' 
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'HU' => '814030966@qq.com' }
  s.source           = { :git => 'https://github.com/jackiehu/SwiftMesh.git', :tag => s.version.to_s }

  s.ios.deployment_target = "11.0" 
  s.swift_versions     = ['5.0','5.1','5.2']
  s.requires_arc = true

  s.frameworks   =  "Foundation" #支持的框架
  s.dependency 'Alamofire'
  s.subspec 'Mesh' do |ss|
      ss.source_files = 'Sources/SwiftMesh/Mesh/**/*' 
    end

  s.subspec 'Request' do |ss| 
      ss.dependency 'SwiftMesh/Mesh'
      ss.source_files = 'Sources/SwiftMesh/Request/**/*' 
    end
    
  s.default_subspec = 'Request'
end
