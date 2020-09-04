#
#  Be sure to run `pod spec lint XHKit.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

s.name         = "XHScanQRCode"
s.version      = "0.0.3"
s.summary      = "framework"

s.description  = <<-DESC
Initialize the
DESC

s.homepage     = "https://github.com/xh1130485186/XHScanQRCode"

s.license      = { :type => "MIT", :file => "LICENSE" }

s.author             = { "xianghong" => "1130485186@qq.com" }

s.platform     = :ios, "8.0"

s.source       = { :git => "https://github.com/xh1130485186/XHScanQRCode.git", :tag => s.version }

s.resources = "XHScanCode/xh.scan.bundle"


s.requires_arc = true
s.source_files = 'XHScanCode/*.{h,m}'

end

