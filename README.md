# About iMCO_K9_SDK 

`iMCO_K9_SDK` is designed to help iMCO Smart band and mobile commnunication framework.Without iMCO permission can not be disclosed to third parties in any way.



## Usage
1.  [CocoaPods](https://cocoapods.org/) (*recommended*)

   ​     	`pod 'iMCO_K9_SDK'`

2. Add the `iMCOK9SDK.framework` to the project

   ​     Embedding `iMCOK9SDK.framework` In your project. [Reference](https://developer.apple.com/library/content/technotes/tn2435/_index.html#//apple_ref/doc/uid/DTS40017543-CH1-EMBED_SECTION)

# Get Started

```objective-c
#import <iMCOK9SDK/iMCOK9SDK.h> //import all the things.
```

* Demo Project
  * There's a sweet demo project: `iMCO_RTSDKDemo.xcworkspace`.
    * Run `pod install` first.
* All data models are defined in the `ZHRealTekModels` class.
  * `ZHRealTekDevice` 
  * `ZHRealTekAlarm`
  * `ZHRealTekLongSit`
  * `ZHRealTekSportItem`
  * `ZHRealTekSleepItem`
  * `ZHRealTekHRItem`


* All interface calls are defined in the `ZHRealTekDataManager` class. Use `Singleton pattern`.

* All interface calls are called with block-mode callbacks. All blocks are defined in the `ZHRealTekBlocks` class.

* Check out the [documentation](http://cocoadocs.org/docsets/iMCO_K9_SDK/) for a comprehensive look at all of the APIs available in `iMCO_K9_SDK`

  ​

  ​

  ​




