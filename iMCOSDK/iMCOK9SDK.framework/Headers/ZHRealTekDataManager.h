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
#define iMCOServerInterfaceVersion 2
extern NSString *const ZH_RealTek_HisSportsKey; // Historical sport Data key.
extern NSString *const ZH_RealTek_HisSleepsKey; // Historical sleep Data key.
extern NSString *const ZH_RealTek_CalibrationKey; //calibration sport Data key.

@interface ZHRealTekDataManager : NSObject


/**
 Connected device.
 */
@property (nonatomic, strong) ZHRealTekDevice *connectedDevice;


/**
 Disconnect block.
 */
@property (nonatomic, copy) ZHRealTekDisConnectionBlock disConnectionBlock;

/**
 The current state of the manager updated block.
 */
@property (nonatomic, copy) ZHRealTekBlueToothStateDidUpdatedBlock blueToothStateUpdateBlock;


/**
 The list of features for the device has been updated.You can review the functionality of the device after the device list is updated.
 */
@property (nonatomic, copy) ZHRealTekFunctionsHaveUpdated functionsHaveUpdated;


/**
 sport data updated callback. (Return value refer to: ZHRealTekSportItem)
 */
@property (nonatomic, copy) ZHRealTekSportDataUpdateBlock sportDataUpdateBlock;


/**
  sleep data updated callback.(Return value refer to: ZH_RealTek_SleepItem)
 */
@property (nonatomic, copy) ZHRealTekSportDataUpdateBlock sleepDataUpdateBlock;


/**
 Heart rate data updated callback.  (result is array,item refer to: ZHRealTekHRItem)
 */
@property (nonatomic, copy) ZHRealTekSportDataUpdateBlock heartRateDataUpdateBlock;


/**
 The device stops measuring the heart rate callbacks.
 @discussion finished result is nil.
 */
@property (nonatomic, copy) ZHRealTekSportDataUpdateBlock stopMeasuringHRBlock;



/**
 Blood pressure measurement data update callback. (result is array,item refer to:ZHRealTekBPItem)
 */
@property (nonatomic, copy) ZHRealTekSportDataUpdateBlock bloodPressureDataUpdateBlock;


/**
 Stop measuring blood pressure callbacks.
 */
@property (nonatomic, copy) ZHRealTekSportDataUpdateBlock stopMeasuringBloodPressureBlock;

/**
 Power change callback.
 */
@property (nonatomic, copy) ZHRealTekPowerUpdateBlock powerUpdateBlock;


/**
 When you enter the photo mode, the receiving device takes a photo status.
 */
@property (nonatomic, copy) ZHRealTekCameraUpdateBlock cameraModeUpdateBlock;


/**
 Whether the motion data is being synchronized.
 */
@property (nonatomic) BOOL isSyningSportData;


/**
 Judgment is bound.
 */
@property (nonatomic) BOOL isBound;


/**
 Whether or not the central is currently scanning.
 */
@property (nonatomic) BOOL isScanning;


/**
 The current state of the manager.
 */
@property (nonatomic, assign) CBManagerState blueToothState;


/**
 Used when accessing the background when the firmware is upgraded.
 */
@property (nonatomic, strong) NSString *AppKey;


/**
 Used when accessing the background when the firmware is upgraded.
 */
@property (nonatomic, strong) NSString *AppSecret;

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

 @param update callback
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
 @param finished finish callback
 *  @seealso            CBConnectPeripheralOptionNotifyOnConnectionKey
 *  @seealso            CBConnectPeripheralOptionNotifyOnDisconnectionKey
 *  @seealso            CBConnectPeripheralOptionNotifyOnNotificationKey
 */
-(void)connectPeripheral:(ZHRealTekDevice *)device options:(NSDictionary *)options onFinished:(ZHRealTekConnectionBlock) finished;


/**
 Cancel connection with device

 @param device device
 @param disconnected disconnected callback
 */
-(void)cancelPeripheralConnection:(ZHRealTekDevice *)device onFinished:(ZHRealTekConnectionBlock) disconnected;



/**
 Syn time

 @param finished finish callback
 */
-(void)synTimeonFinished:(ZHRealTekSendCommandBlock)finished;



/**
 Bind band device

 @param identifier the identifier with user
 @param finished callback
 @discussion finished result is Int Number.
 @discussion identifier length can not more than 32 byte.
 * @seealso ZH_RealTek_Bind_Status
 */
-(void)bindDeviceWithIdentifier:(NSString *)identifier onFinished:(ZHRealTekSendCommandBlock)finished;



/**
 unbind device

 @param finished callback
 @discussion finished result is nil.
 */
-(void)unBindDeviceonFinished:(ZHRealTekSendCommandBlock)finished;

/**
 login band device

 @param identifier the identifier with user
 @param finished finished callback
 @discussion  finished result is Int Number.
 * @seealso ZH_RealTek_Login_Status
 */
-(void)loginDeviceWithIdentifier:(NSString *)identifier onFinished:(ZHRealTekSendCommandBlock)finished;



/**
 Find my band device
 @param finished finished callback
 @discussion finished result is nil.
 */
-(void)findMyBandDeviceonFinished:(ZHRealTekSendCommandBlock)finished;;



/**
 modify device name

 @param name the device name
 @param finished callback
 @discussion finished result is nil.
 */
-(void)modifyDeviceName:(NSString *)name onFinished:(ZHRealTekSendCommandBlock)finished;



/**
 get device name

 @param finished finish callback
 @discussion finished result is NSString.
 */
-(void)getDeviceNameonFinished:(ZHRealTekSendCommandBlock)finished;

/**
 syn alarms to device

 @param alarms alarms
 @param finished callback
 @discussion alarms members is ZHRealTekAlarm distance. 
 @discussion finished result is nil.
 */
-(void)synAlarms:(NSArray *)alarms onFinished:(ZHRealTekSendCommandBlock)finished;


/**
 get alarms from device

 @param finished callback
 @discussion finished result is ZHRealTekAlarm distance.
 @discussion finished result is nil.
 */
-(void)getBandAlarmsonFinished:(ZHRealTekSendCommandBlock)finished;



/**
 set step target

 @param step the step
 @param finished callback
 @discussion finished result is nil.
 */
-(void)setStepTarget:(uint32_t)step onFinished:(ZHRealTekSendCommandBlock)finished;


/**
 set user profile

 @param gender gender @see ZH_RealTek_Gender
 @param age user age (0~127)
 @param height user height (unit: cm, 0.0~256)
 @param weight user weight (unit: kg, 0.0~512)
 @param finished callback
 @discussion finished result is nil.
 */
-(void)setUserProfileWithGender:(ZH_RealTek_Gender)gender withAge:(uint8_t)age withHeight:(float)height withWeight:(float)weight onFinished:(ZHRealTekSendCommandBlock)finished;



/**
 ser loss alert level

 @param level alert level
 @param finished finish callback
 @discussion finished result is nil.
 */
-(void)setLossAlertLevel:(ZH_RealTek_AlertLevel)level onFinished:(ZHRealTekSendCommandBlock)finished;



/**
 sit long sit remind

 @param sit long sit object
 @param finished callback
 @discussion finished result is nil.
 @see ZHRealTekLongSit
 */
-(void)setLongSitRemind:(ZHRealTekLongSit *)sit onFinished:(ZHRealTekSendCommandBlock)finished;


/**
 get long sit Enable

 @param finished callback
 @discussion finished result is bool number.
 */
-(void)getLongSitRemindonFinished:(ZHRealTekSendCommandBlock)finished;


/**
 set moblie os

 @param os moblie os
 @param finished callback
 @discussion finished result is nil.
 */
-(void)setMoblieOS:(ZH_RealTek_OS)os onFinished:(ZHRealTekSendCommandBlock)finished;




/**
 Get Battery Level

 @param finished callback
 @discussion finished result is int number.
 */
-(void)getBatteryLevelonFinished:(ZHRealTekSendCommandBlock)finished;


/**
 Set Camera mode.

 @param enable Enter or quit camera mode.
 @param finished callback
 @discussion finished result is int nil.
 @discussion You must exit the photo mode when you are not using the photo mode.
 */
-(void)setCameraMode:(BOOL)enable onFinished:(ZHRealTekSendCommandBlock)finished;


/**
 Enable Turn Wrist Light .

 @param enable on/off
 @param finished finish callback.
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
 @param finished callback.
 @discussion finished result is int nil.
 */
-(void)setEnableCallNotificationEnabled:(BOOL)enable onFinished:(ZHRealTekSendCommandBlock)finished;


/**
 Enable SMS Notification
 
 @param enable on/off
 @param finished callback.
 @discussion finished result is int nil.
 */
-(void)setEnableSMSNotificationEnabled:(BOOL)enable onFinished:(ZHRealTekSendCommandBlock)finished;


/**
 Enable QQ Notification
 
 @param enable on/off
 @param finished callback.
 @discussion finished result is int nil.
 */
-(void)setEnableQQNotificationEnabled:(BOOL)enable onFinished:(ZHRealTekSendCommandBlock)finished;


/**
 Enable Wechat Notification
 
 @param enable on/off
 @param finished callback.
 @discussion finished result is int nil.
 */
-(void)setEnableWechatNotificationEnabled:(BOOL)enable onFinished:(ZHRealTekSendCommandBlock)finished;

/**
 Enable Line Notification
 
 @param enable on/off
 @param finished callback.
 @discussion Real-time synchronization data must be turned on to receive real-time data for steps and heart rate sleep.
 @discussion finished result is int nil.
 */
-(void)setEnableLineNotificationEnabled:(BOOL)enable onFinished:(ZHRealTekSendCommandBlock)finished;

#pragma mark - Sports
/**
 Synchronizes historical data, including sports and sleep and other data.
 
 @param finished callback.
 @discussion finished result is Dictionary.
 @discussion dictionary key see ZH_RealTek_HisSportsKey,ZH_RealTek_HisSleepsKey.
 (Value refer to: ZHRealTekSportItem,ZHRealTekSleepItem)
 */
-(void)synHisDataOnFinished:(ZHRealTekSendCommandBlock)finished;



/**
 Synchronizes all total motion data for the day.

 @param totalSteps total steps.
 @param totalDistance total distance. (unit: m)
 @param totalCalory total calories. (uint: cal)
 @param finished callback.
 */
-(void)synTodayTotalSportDataWithStep:(uint32_t)totalSteps distance:(uint32_t)totalDistance calory:(uint32_t)totalCalory OnFinished:(ZHRealTekSendCommandBlock)finished;



/**
 Synchronizes all the total motion data in the last 15 minutes.

 @param steps step.
 @param activeTime activeTime. (unit: minutes）
 @param calory calories. (uint: cal)
 @param distance distance.  (unit: m)
 @param mode sport mode.
 @param finished callback.
 */
-(void)synRecentSportDataWithStep:(uint16_t)steps activeTime:(uint8_t)activeTime calory:(uint32_t)calory distance:(uint16_t)distance offset:(uint16_t)offset mode:(ZH_RealTek_Sport_Mode)mode OnFinished:(ZHRealTekSendCommandBlock)finished;


/**
 Enable get real-time motion data.
 
 @param enable on or off.
 @param finished callback.
 @discussion finished result is nil.
 */
-(void)setRealTimeSynSportData:(BOOL)enable onFinished:(ZHRealTekSendCommandBlock)finished;


#pragma mark - Blood Pressure


/**
 Set blood pressure measurements on and off.

 @param enable on/off
 @param finished callback
 @discussion finished result is nil.
 @discussion Blood pressure data return see bloodPressureDataUpdateBlock.
 */
-(void)setBloodPressueEnable:(BOOL)enable onFinished:(ZHRealTekSendCommandBlock)finished;


#pragma mark Heart Rate Function

/**
 To measure the heart rate.

 @param enable on/off
 @param finished callback.
 @discussion finished result is nil.
 @discussion Heart rate data return see heartRateDataUpdateBlock.
 */
-(void)setHRReadOneTimeEnable:(BOOL)enable onFinished:(ZHRealTekSendCommandBlock)finished;



/**
 Request the continuous heart rate data.

 @param enable enable
 @param minutes The time interval.
 @param finished callback.
 @discussion finished result is nil.
 @discussion Heart rate data return see heartRateDataUpdateBlock.
 */
-(void)setHRReadContinuous:(BOOL)enable Interval:(uint8_t)minutes onFinished:(ZHRealTekSendCommandBlock)finished;



/**
 Gets whether to open continuous measurement of heart rate function.

 @param finished callback.
 @discussion finished result is Bool number.
 */
-(void)getHRReadContinuousSettingOnFinished:(ZHRealTekSendCommandBlock)finished;



#pragma mark - Orientation
/**
 Sets the screen display direction.

 @param orientation Screen Orientation.
 @param finished callBack.
 */
-(void)SetDisplayOrientation:(ZH_RealTek_ScreenOrientation)orientation OnFinished:(ZHRealTekSendCommandBlock)finished;


/**
 Gets the screen display direction.

 @param finished callback.
 */
-(void)getDisplayOrientation:(ZHRealTekSendCommandBlock)finished;

#pragma mark - OTA Function
/**
 Get OTA Application version

 @param finished callback.
 @discussion finished result is int number.
 */
-(void)getOTAApplicationVersiononFinished:(ZHRealTekSendCommandBlock)finished;


/**
 Get OTA Patch version

 @param finished callback.
 @discussion finished result is int number.
 */
-(void)getOTAPatchVersiononFinished:(ZHRealTekSendCommandBlock)finished;


/**
 Get device mac address.

 @param finished callback.
 @discussion finished result is NSString.
 */
-(void)getMacAddressonFinished:(ZHRealTekSendCommandBlock)finished;



/**
 Check the firmware for updates.
 @param userID user ID.(optional)
 @param finished callback.
 @discussion finished result is ZH_RealTek_CheckFirmWareUpdate_Code number.
 */
-(void)checkFirmWareHaveNewVersionWithUserId:(NSString *)userID onFinished:(ZHRealTekSendCommandBlock)finished;


/**
 Start firmware update

 @param progress update progress.
 
 */
-(void)updateFirmwareonFinished:(ZHRealTekUpdateFirmwareProgressBlock)progress;



#pragma mark - Test Method
/**
 Enter OTA mode
 
 @param finished callback
 @discussion finished result is nil.
 @discussion This is an internal flash test OTA upgrade operation, please call carefully.
 */
-(void)enterOTAModeonFinished:(ZHRealTekSendCommandBlock)finished;



/**
 Obtain all firmware versions for selective test upgrades.

 @param finished callback.
 */
-(void)checkAllOTADataOnFinished:(void (^)(NSError *error, NSData *data))finished;


/**
 Upgrade the hand ring firmware with a specific firmware.
 
 @param firmWareUrl firmware URL
 @param progress update Progress
 @param md5 the firmware Data MD5
 @discussion This is to test specific firmware, please use it carefully.
 */
-(void)updateFirmware:(NSString *)firmWareUrl withMD5:(NSString *)md5 onFinished:(ZHRealTekUpdateFirmwareProgressBlock)progress;


/**
 Check to see if the user is a test group user.

 @param finished callback.
 @discussion If users join test group users will be able to update the beta firmware, please use caution..
 */
-(void)isTestUserOnFinished:(void (^)(NSError *error, BOOL isTestUser))finished;


/**
 Join the test user.

 @param finished callback.
 */
-(void)enableTesterOnFinished:(void (^)(NSError *error, BOOL success))finished;



/**
 Exit the test user.

 @param finished callback
 */
-(void)disableTesterOnFinished:(void (^)(NSError *error, BOOL success))finished;


/**
 Clear all SDK Log.
 */
-(void)clearAllLogFile;


/**
 Clear today SDK Log.
 */
-(void)clearTodayLogFile;


/**
 handle received sleep data.

 @param data data.
 */
-(void)handleReceivedData:(NSData *)data;
@end


