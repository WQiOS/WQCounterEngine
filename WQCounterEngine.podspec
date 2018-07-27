
Pod::Spec.new do |s|

s.name         = "WQCounterEngine"
s.version      = "0.0.2"
s.summary      = "一款数字/金额增减动效组件"
s.description  = <<-DESC
                WQCounterEngine is good!
                 DESC
s.homepage     = "https://github.com/WQiOS/WQCounterEngine"
s.license      = "MIT"
s.author             = { "王强" => "1570375769@qq.com" }
s.platform     = :ios, "8.0" #平台及支持的最低版本
s.requires_arc = true # 是否启用ARC
s.source       = { :git => "https://github.com/WQiOS/WQCounterEngine.git", :tag => "#{s.version}" }
s.source_files  = "WQCounterEngine/*.{h,m}"
s.ios.framework  = 'UIKit'

end
