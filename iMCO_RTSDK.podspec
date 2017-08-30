
Pod::Spec.new do |s|
  s.authors      = "iMCO" 
  s.name         = "iMCO_RTSDK"
  s.version      = "2.3"
  s.summary      = "iMCO K9 SDK for iOS"
  
   s.requires_arc = true
   s.homepage     = "https://github.com/zhuozhuo"
   s.platform     = :ios, "8.0"
   s.source       = { :git => "ssh://git@gitlab.kelvinji2009.me:10022/Perry/iMCO_RTSDKDemo.git", :tag => s.version }
   s.framework  = "CoreBluetooth"
   s.vendored_frameworks ='iMCOSDK/iMCO_RTSDK.framework'
   s.license      = {
    :type => 'Copyright',
    :text => <<-LICENSE
      Copyright 2016 iMCO All rights reserved.
      LICENSE
  }
end
