
Pod::Spec.new do |s|
  s.authors      = "iMCO" 
  s.name         = "iMCO_K9_SDK"
  s.version      = "3.3"
  s.summary      = "iMCO K9 SDK for iOS"
  
   s.requires_arc = true
   s.homepage     = "http://www.imcotechnology.com"
   s.platform     = :ios, "8.0"
   s.source       = { :git => "https://github.com/iMCOTeam/iMCO_K9_SDK.git", :tag => s.version }
   s.framework  = 'CoreBluetooth','UIKit'
   s.vendored_frameworks = 'iMCOSDK/iMCOK9SDK.framework'
   s.license      = {
    :type => 'Copyright',
    :text => <<-LICENSE
      Copyright 2016 iMCO All rights reserved.
      LICENSE
  }
end
