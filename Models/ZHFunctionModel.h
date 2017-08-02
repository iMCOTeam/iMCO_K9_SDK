//
//  ZHFunctionModel.h
//  iMCOBandRealTekSDK_iOS
//
//  Created by aimoke on 2017/7/17.
//  Copyright © 2017年 zhuo. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, ZHFunctionCellMode) {
    ZHOnlyTitle,
    ZHTitleAndSwith,
    
};

typedef NS_ENUM(NSInteger, ZHFunctionMode) {
    ZHLogin,
    ZHBind,
    ZHCancelBind,
    ZHCancelConnect,
    ZHSynTime,
    ZHSynAlarm,
    ZHGetAlarms,
    ZHSetStepTarget,
    ZHSynUserProfile,
    ZHSetlost,
    ZHSetSittingReminder,
    ZHGetSittingReminder,
    ZHSetMobileSystem,
    ZHEnterPhotoMode,
    ZHExitPhotoMode,
    ZHSetRaiseHandLight,
    ZHGetRaiseHandLightSet,
    ZHQQReminder,
    ZHWeChatReminder,
    ZHSMSReminder,
    ZHLineReminder,
    ZHIncomingReminder,
    ZHGetHistoryData,
    ZHGetRealTimeData,
    ZHOnceHR,
    ZHContinuousHR,
    ZHGetContinuousHRSetting,
    ZHFindBand,
    ZHSetBandName,
    ZHGetBandName,
    ZHGetBattery,
    ZHGetAppVersion,
    ZHGetPatchVersion,
    ZHGetMacAddress,
    ZHGetSDKVersion,
    ZHCheckOTAVersion,
    ZHUpdateOTA,
    ZHEnterOTAMode,
    ZHTestUpdateOTA,
    ZHTestMultiCmd,
};

@interface ZHFunctionModel : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic) ZHFunctionCellMode cellMode;
@property (nonatomic) ZHFunctionMode functionMode;
-(instancetype)initWithTitle:(NSString *)title cellMode:(ZHFunctionCellMode)cellMode functionMode:(ZHFunctionMode)functionMode ;
@end
