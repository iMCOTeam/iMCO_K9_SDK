//
//  ZHRealTekDataManager.h
//  iMCOBandRealTekSDK_iOS
//
//  Created by aimoke on 2017/5/24.
//  Copyright © 2017年 zhuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZHRealTekModels.h"
#import "ZHRealTekBlocks.h"


#pragma mark Define Notification
#define ZHRealTekReceiveTodayStepDataNotification @"ZHRealTekReceiveTodayStepDataNotification"
#define ZHRealTekReceiveHisStepDataNotification @"ZHRealTekReceiveHisStepDataNotification"
#define ZHRealTekReceiveHisSleepDataNotification @"ZHRealTekReceiveHisSleepDataNotification"
#define iMCOServerHost @"https://fota.aimoketechnology.com"

extern NSString *const ZH_RealTek_HisSportsKey; // Historical sport Data key.
extern NSString *const ZH_RealTek_HisSleepsKey; // Historical sleep Data key.


@interface ZHRealTekDataManager : NSObject

@property (nonatomic, strong) ZHRealTekDevice *connectedDevice;//Connected device.
@property (nonatomic, copy) ZHRealTekDisConnectionBlock disConnectionBlock;// disconnect block.
@property (nonatomic, copy) ZHRealTekSportDataUpdateBlock sportDataUpdateBlock;// sport data updated call back.
@property (nonatomic, copy) ZHRealTekCameraUpdateBlock cameraModeUpdateBlock; // When you enter the photo mode, the receiving device takes a photo status.

@property (nonatomic, copy) ZHRealTekSportDataUpdateBlock heartRateDataUpdateBlock; // Heart rate data updated call back. result is array.
@property (nonatomic, copy) ZHRealTekSportDataUpdateBlock stopMeasuringHRBlock; //The device stops measuring the heart rate callbacks.
@property (nonatomic, copy) ZHRealTekBlueToothStateDidUpdatedBlock blueToothStateUpdateBlock; ////The current state of the manager updated block.
@property (nonatomic) BOOL isSyningSportData;// Whether the motion data is being synchronized.
@property (nonatomic) BOOL isBound;//judgment is bound.
@property (nonatomic) BOOL isScanning;//Whether or not the central is currently scanning.
@property(nonatomic, assign) CBManagerState blueToothState; //The current state of the manager.


/**
 The ZHRealTekDataManager Singleton.

 @return ZHRealTekDataManager instance.
 */
+(instancetype)shareRealTekDataManager;


/**
 Get SDK Version

 @return SDK Version
 */
-(NSString *)iMCOSDKVersion;

/**
 Scan devices

 @param update call back
 @discussion The advertisement data can be accessed through the keys listed in Advertisement Data Retrieval Keys.
 *  @seealso            CBAdvertisementDataLocalNameKey
 *  @seealso            CBAdvertisementDataManufacturerDataKey
 *  @seealso            CBAdvertisementDataServiceDataKey...
 */
-(void)scanDevice:(ZHRealTekDeviceUpdateBlock)update;


/**
 stop scan device
 */
-(void)stopScan;

#pragma mark Establishing or Canceling Connection


/**
 Connect device

 @param device device
 @param options options
 @param finished finish call back
 *  @seealso            CBConnectPeripheralOptionNotifyOnConnectionKey
 *  @seealso            CBConnectPeripheralOptionNotifyOnDisconnectionKey
 *  @seealso            CBConnectPeripheralOptionNotifyOnNotificationKey
 */
-(void)connectPeripheral:(ZHRealTekDevice *)device options:(NSDictionary *)options onFinished:(ZHRealTekConnectionBlock) finished;


/**
 Cancel connection with device

 @param device device
 @param disconnected disconnected call back
 */
-(void)cancelPeripheralConnection:(ZHRealTekDevice *)device onFinished:(ZHRealTekConnectionBlock) disconnected;



/**
 Syn time

 @param finished finish call back
 */
-(void)synTimeonFinished:(ZHRealTekSendCommandBlock)finished;



/**
 Bind band device

 @param identifier the identifier with user
 @param finished call back
 @discussion finished result is Int Number.
 @discussion identifier length can not more than 32 byte.
 * @seealso ZH_RealTek_Bind_Status
 */
-(void)bindDeviceWithIdentifier:(NSString *)identifier onFinished:(ZHRealTekSendCommandBlock)finished;



/**
 unbind device

 @param finished call back
 @discussion finished result is nil.
 */
-(void)unBindDeviceonFinished:(ZHRealTekSendCommandBlock)finished;

/**
 login band device

 @param identifier the identifier with user
 @param finished finished call back
 @discussion  finished result is Int Number.
 * @seealso ZH_RealTek_Login_Status
 */
-(void)loginDeviceWithIdentifier:(NSString *)identifier onFinished:(ZHRealTekSendCommandBlock)finished;



/**
 Find my band device
 @param finished finished call back
 @discussion finished result is nil.
 */
-(void)findMyBandDeviceonFinished:(ZHRealTekSendCommandBlock)finished;;



/**
 modify device name

 @param name the device name
 @param finished call back
 @discussion finished result is nil.
 */
-(void)modifyDeviceName:(NSString *)name onFinished:(ZHRealTekSendCommandBlock)finished;



/**
 get device name

 @param finished finish call back
 @discussion finished result is NSString.
 */
-(void)getDeviceNameonFinished:(ZHRealTekSendCommandBlock)finished;

/**
 syn alarms to device

 @param alarms alarms
 @param finished call back
 @discussion alarms members is ZHRealTekAlarm distance. 
 @discussion finished result is nil.
 */
-(void)synAlarms:(NSArray *)alarms onFinished:(ZHRealTekSendCommandBlock)finished;


/**
 get alarms from device

 @param finished call back
 @discussion finished result is ZHRealTekAlarm distance.
 @discussion finished result is nil.
 */
-(void)getBandAlarmsonFinished:(ZHRealTekSendCommandBlock)finished;



/**
 set step target

 @param step the step
 @param finished call back
 @discussion finished result is nil.
 */
-(void)setStepTarget:(uint32_t)step onFinished:(ZHRealTekSendCommandBlock)finished;


/**
 set user profile

 @param gender gender @see ZH_RealTek_Gender
 @param age user age (0~127)
 @param height user height (unit: cm, 0.0~256)
 @param weight user weight (unit: kg, 0.0~512)
 @param finished call back
 @discussion finished result is nil.
 */
-(void)setUserProfileWithGender:(ZH_RealTek_Gender)gender withAge:(uint8_t)age withHeight:(float)height withWeight:(float)weight onFinished:(ZHRealTekSendCommandBlock)finished;



/**
 ser loss alert level

 @param level alert level
 @param finished finish call back
 @discussion finished result is nil.
 */
-(void)setLossAlertLevel:(ZH_RealTek_AlertLevel)level onFinished:(ZHRealTekSendCommandBlock)finished;



/**
 sit long sit remind

 @param sit long sit object
 @param finished call back
 @discussion finished result is nil.
 @see ZHRealTekLongSit
 */
-(void)setLongSitRemind:(ZHRealTekLongSit *)sit onFinished:(ZHRealTekSendCommandBlock)finished;


/**
 get long sit Enable

 @param finished call back
 @discussion finished result is bool number.
 */
-(void)getLongSitRemindonFinished:(ZHRealTekSendCommandBlock)finished;


/**
 set moblie os

 @param os moblie os
 @param finished call back
 @discussion finished result is nil.
 */
-(void)setMoblieOS:(ZH_RealTek_OS)os onFinished:(ZHRealTekSendCommandBlock)finished;




/**
 Get Battery Level

 @param finished call back
 @discussion finished result is int number.
 */
-(void)getBatteryLevelonFinished:(ZHRealTekSendCommandBlock)finished;


/**
 Set Camera mode.

 @param enable Enter or quit camera mode.
 @param finished call back
 @discussion finished result is int nil.
 @discussion You must exit the photo mode when you are not using the photo mode.
 */
-(void)setCameraMode:(BOOL)enable onFinished:(ZHRealTekSendCommandBlock)finished;


/**
 Enable Turn Wrist Light .

 @param enable on/off
 @param finished finish call back.
 @discussion finished result is int nil.
 */
-(void)setTurnWristLightEnabled:(BOOL)enable onFinished:(ZHRealTekSendCommandBlock)finished;



/**
 Get Turn Wrist Light Enable.
 
 @param finished call abck.
 @discussion finished result is bool number.
 */
-(void)getTurnWristLightEnabledOnFinished:(ZHRealTekSendCommandBlock)finished;


#pragma mark - Notification
/**
 Enable Call Notification
 
 @param enable on/off
 @param finished call back.
 @discussion finished result is int nil.
 */
-(void)setEnableCallNotificationEnabled:(BOOL)enable onFinished:(ZHRealTekSendCommandBlock)finished;


/**
 Enable SMS Notification
 
 @param enable on/off
 @param finished call back.
 @discussion finished result is int nil.
 */
-(void)setEnableSMSNotificationEnabled:(BOOL)enable onFinished:(ZHRealTekSendCommandBlock)finished;


/**
 Enable QQ Notification
 
 @param enable on/off
 @param finished call back.
 @discussion finished result is int nil.
 */
-(void)setEnableQQNotificationEnabled:(BOOL)enable onFinished:(ZHRealTekSendCommandBlock)finished;


/**
 Enable Wechat Notification
 
 @param enable on/off
 @param finished call back.
 @discussion finished result is int nil.
 */
-(void)setEnableWechatNotificationEnabled:(BOOL)enable onFinished:(ZHRealTekSendCommandBlock)finished;

/**
 Enable Line Notification
 
 @param enable on/off
 @param finished call back.
 @discussion Real-time synchronization data must be turned on to receive real-time data for steps and heart rate sleep.
 @discussion finished result is int nil.
 */
-(void)setEnableLineNotificationEnabled:(BOOL)enable onFinished:(ZHRealTekSendCommandBlock)finished;

#pragma mark - Sports
/**
 Synchronizes historical data, including sports and sleep and other data.
 
 @param finished call back.
 @discussion finished result is Dictionary.
 @discussion dictionary key see ZH_RealTek_HisSportsKey,ZH_RealTek_HisSleepsKey.
 */
-(void)synHisDataOnFinished:(ZHRealTekSendCommandBlock)finished;





/**
 Enable get real-time motion data.
 
 @param enable on or off.
 @param finished call back.
 @discussion finished result is nil.
 */
-(void)setRealTimeSynSportData:(BOOL)enable onFinished:(ZHRealTekSendCommandBlock)finished;





#pragma mark Heart Rate Function

/**
 To measure the heart rate.

 @param enable on/off
 @param finished call back.
 @discussion finished result is nil.
 @discussion Heart rate data return see heartRateDataUpdateBlock.
 */
-(void)setHRReadOneTimeEnable:(BOOL)enable onFinished:(ZHRealTekSendCommandBlock)finished;



/**
 Request the continuous heart rate data.

 @param enable enable
 @param minutes The time interval.
 @param finished call back.
 @discussion finished result is nil.
 @discussion Heart rate data return see heartRateDataUpdateBlock.
 */
-(void)setHRReadContinuous:(BOOL)enable Interval:(uint8_t)minutes onFinished:(ZHRealTekSendCommandBlock)finished;



/**
 Gets whether to open continuous measurement of heart rate function.

 @param finished call back.
 @discussion finished result is Bool number.
 */
-(void)getHRReadContinuousSettingOnFinished:(ZHRealTekSendCommandBlock)finished;




#pragma mark - OTA Function
/**
 Get OTA Application version

 @param finished call back.
 @discussion finished result is int number.
 */
-(void)getOTAApplicationVersiononFinished:(ZHRealTekSendCommandBlock)finished;


/**
 Get OTA Patch version

 @param finished call back.
 @discussion finished result is int number.
 */
-(void)getOTAPatchVersiononFinished:(ZHRealTekSendCommandBlock)finished;


/**
 Get device mac address.

 @param finished call back.
 @discussion finished result is NSString.
 */
-(void)getMacAddressonFinished:(ZHRealTekSendCommandBlock)finished;



/**
 Check the firmware for updates.
 @param userID user ID.(optional)
 @param finished call back.
 @discussion finished result is ZH_RealTek_CheckFirmWareUpdate_Code number.
 */
-(void)checkFirmWareHaveNewVersionWithUserId:(NSString *)userID onFinished:(ZHRealTekSendCommandBlock)finished;


/**
 Start firmware update

 @param progress update progress.
 
 */
-(void)updateFirmwareonFinished:(ZHRealTekUpdateFirmwareProgressBlock)progress;

#pragma mark - Test Command
/**
 Enter OTA mode
 
 @param finished call back
 @discussion finished result is nil.
 @discussion This is an internal flash test OTA upgrade operation, please call carefully.
 */
-(void)enterOTAModeonFinished:(ZHRealTekSendCommandBlock)finished;


/**
 Upgrade the hand ring firmware with a specific firmware.

 @param firmWareUrl firmware URL
 @param progress update Progress
 @param md5 the firmware Data MD5
 @discussion This is to test specific firmware, please use it carefully.
 */
-(void)updateFirmware:(NSString *)firmWareUrl withMD5:(NSString *)md5 onFinished:(ZHRealTekUpdateFirmwareProgressBlock)progress;
@end


