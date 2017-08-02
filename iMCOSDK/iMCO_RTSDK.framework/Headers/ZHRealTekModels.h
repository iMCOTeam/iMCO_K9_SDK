//
//  ZHRealTekModels.h
//  iMCOBandRealTekSDK_iOS
//
//  Created by aimoke on 2017/5/25.
//  Copyright © 2017年 zhuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#pragma mark Status


typedef NS_ENUM(NSInteger, ZH_RealTek_FirmWare_Update_Status)
{
    RealTek_FirmWare_Loading_OTA = 0, //Download the firmware.
    RealTek_FirmWare_Updateing = 1, //Update the firmware.
    RealTek_FirmWare_Update_Failed = 2, //Update firmware failed.
    RealTek_FirmWare_Update_Finished = 3, //Update firmware finished.
    RealTek_FirmWare_Update_Success = 4, //Update firmware success.
    RealTek_FirmWare_Update_Restart = 5, //Updated the SmartBand to restart.
};


// Error Code
enum ZH_RealTek_Error_Code{
    ZHCharactiristicNotFindCode = 10001,
    ZHDisConnectedErrorCode = 10002,
    ZHBatteryErrorCode  = 10003,
    ZHMacAddressErrorCode = 10004,
    ZHUpdateFirmWareFaild = 10005,
    ZHBindErrorCode = 10006,
    ZHTimeOutErrorCode = 10007,
    ZHFirmWareUrlIsEmptyErrorCode = 10008,
};

// Check OTA FirmWare Code
enum ZH_RealTek_CheckFirmWareUpdate_Code{
    ZH_Realtek_FirmWare_HaveNewVersion = 0,
    ZH_RealTek_FirmWare_isNewVersion = 1,
};

/**
 Login status

 - RealTek_Login_Success: login success
 - RealTek_Login_TimeOut: login time out
 @discussion  You can use logins to determine whether a user is bound.
 */
typedef NS_ENUM(NSInteger,ZH_RealTek_Login_Status)
{
    RealTek_Login_Success = 0, //Login success indicates that it is already bound.
    RealTek_Login_TimeOut = 1, //The user ID is inconsistent and the login fails.
};


/**
 Bind status

 - RealTek_Bind_Success: bind success
 @discussion The same user cannot be bound multiple times.
 */
typedef NS_ENUM(NSInteger, ZH_RealTek_Bind_Status)
{
    RealTek_Bind_Success = 0, //Binding succeeded.
    RealTek_Bind_Faild = 1, //Operation Timeout failed.
};



enum ZH_RealTek_Day
{
    ZH_RealTek_None = 0x00,
    ZH_RealTek_Monday = 0x01,
    ZH_RealTek_Tuesday = 0x02,
    ZH_RealTek_Wednessday = 0x04,
    ZH_RealTek_Thursday = 0x08,
    ZH_RealTek_Friday = 0x10,
    ZH_RealTek_Saturday = 0x20,
    ZH_RealTek_Sunday = 0x40,

};



/**
 Gender

 - ZH_RealTek_Male: Male
 - ZH_RealTek_Female: Female
 */
typedef NS_ENUM(NSInteger, ZH_RealTek_Gender)
{
    ZH_RealTek_Male = 0,
    ZH_RealTek_Female = 1,
};


/**
 Alert Level

 - ZH_RealTek_NoAlertLevel: No Alert
 - ZH_RealTek_AlertLevel_Middle:middle alert level
 - ZH_RealTek_AlertLevel_High: high alert level
 */
typedef NS_ENUM(NSInteger, ZH_RealTek_AlertLevel){
    ZH_RealTek_NoAlertLevel = 0,
    ZH_RealTek_AlertLevel_Middle = 1,
    ZH_RealTek_AlertLevel_High = 2,
};



/**
 Set up the mobile OS

 - ZH_RealTek_OS_iOS: iOS
 - ZH_RealTek_OS_Android: Android
 */
typedef NS_ENUM(NSInteger, ZH_RealTek_OS){
    ZH_RealTek_OS_iOS = 0,
    ZH_RealTek_OS_Android = 1,
};



/**
 Sport mode.

 - ZH_RealTek_Stationary: Stationary
 - ZH_RealTek_Walk: Walk
 - ZH_RealTek_Run: Run
 */
typedef NS_ENUM(NSInteger, ZH_RealTek_Sport_Mode){
    ZH_RealTek_Stationary = 0,
    ZH_RealTek_Walk = 1,
    ZH_RealTek_Run = 2,
};



/**
 Sleep mode

 - ZH_RealTek_Awake: awake
 - ZH_RealTek_DeepSleep: deep sleep
 - ZH_RealTek_LightSleep: light sleep
 */
typedef NS_ENUM(NSInteger, ZH_RealTek_Sleep_Mode) {
    ZH_RealTek_Awake = 0,
    ZH_RealTek_DeepSleep = 1,
    ZH_RealTek_LightSleep = 2,
};



@interface ZHRealTekDevice : NSObject
@property (nonatomic, strong) NSString *name; //Device Name
@property (nonatomic, strong) NSString *identifier; //Device Unique identification
@property (nonatomic, assign) NSInteger rssi; //RSSI

@end



/**
 Alarm model
 @discussion The maximum number of alarms is 8.
 */
@interface ZHRealTekAlarm : NSObject
@property (nonatomic, assign) NSInteger year;
@property (nonatomic, assign) NSInteger month;
@property (nonatomic, assign) NSInteger day;
@property (nonatomic, assign) NSInteger hour;
@property (nonatomic, assign) NSInteger minute;
@property (nonatomic, assign) NSInteger index;//The serial number of the alarm clock. Range(0~7)
@property (nonatomic, assign) NSInteger dayFlags; //see ZH_RealTek_Day.If have more than one day。ZH_RealTek_Monday | ZH_RealTek_Tuesday. default is ZH_RealTek_None

@end



@interface ZHRealTekLongSit : NSObject

@property (nonatomic, assign) BOOL onEnable; // On or off,default is off/NO
@property (nonatomic, assign) NSInteger minStepNum; //In a sedentary time, the number of steps below this threshold is only a reminder. default is 10
@property (nonatomic, assign) NSInteger sitTime; // (Unit minutes) default is 60
@property (nonatomic, assign) NSInteger beginTime;// begin time （0~24） default is 9.
@property (nonatomic, assign) NSInteger endTime; // end time (0~24) default is 18
@property (nonatomic, assign) NSInteger dayFlags; //see ZH_RealTek_Day.If have more than one day。ZH_RealTek_Monday | ZH_RealTek_Tuesday.default is ZH_RealTek_None

@end


@interface ZHRealTekSportItem : NSObject

@property (nonatomic, strong) NSString *date; //The date of sport. （format：yyyy-MM-dd,2015-06-07)
@property (nonatomic, assign) NSInteger dayOffset; //The offset of the day. From 0 o'clock each day, the 15-minute offset plus 1.
@property (nonatomic, assign) ZH_RealTek_Sport_Mode mode;// The sport mode.

/**
 @discussion Represents the current total number of steps when it is a real-time data, and represents the number of steps in the period of time when the data is historical.
 */
@property (nonatomic, assign) NSInteger stepCount; // step count. (unit: step)
@property (nonatomic, assign) NSInteger activeTime; // The activity time.
@property (nonatomic, assign) NSInteger calories; //Calories consumed. (unit: cal）
@property (nonatomic, assign) NSInteger distance; // Movement distance. (unit: m)


@end


@interface ZHRealTekSleepItem : NSObject
@property (nonatomic, strong) NSString *startTime; // The start time. （format：yyyy-MM-dd-HH-mm,2015-06-07-08-03)
@property (nonatomic, strong) NSString *endTime; // The end time. （format：yyyy-MM-dd-HH-mm,2015-06-07-08-04)
@property (nonatomic, assign) ZH_RealTek_Sleep_Mode mode;

@end

@interface ZHRealTekHRItem : NSObject
@property (nonatomic, strong) NSString *time; // The time. （format：yyyy-MM-dd-HH-mm-ss,2015-06-07-08-03-09)
@property (nonatomic, assign) NSInteger heartRate; //Heart Rete.

@end
