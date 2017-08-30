# About iMCOK9SDK 

iMCOK9SDK is designed to help iMCO Smart band and mobile commnunication framework.Without iMCO permission can not be disclosed to third parties in any way.



# Get Started

1. Add the `iMCOK9SDK.framework` to the project.
2. Embedding `iMCOK9SDK.framework` In your project. [Reference](https://developer.apple.com/library/content/technotes/tn2435/_index.html#//apple_ref/doc/uid/DTS40017543-CH1-EMBED_SECTION)
3. `import <iMCOK9SDK/iMCOK9SDK.h>` import all the things.


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

  ​

  ​

  ​




