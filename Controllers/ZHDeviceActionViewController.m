//
//  ZHDeviceActionViewController.m
//  iMCOBandRealTekSDK_iOS
//
//  Created by aimoke on 2017/5/24.
//  Copyright © 2017年 zhuo. All rights reserved.
//

#import "ZHDeviceActionViewController.h"
#import "ZHCommandTableViewCell.h"
#import "ZHTitleAndSwitchTableViewCell.h"
#import "ZHFunctionModel.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <iMCOK9SDK/iMCOK9SDK.h>

#define DeviceActionCellIdentifier @"DeviceActionCellIdentifier"
#define DeviceSwitchCellIdentifier @"DeviceSwitchCellIdentifier"

#define TestUserIdentifier @"a_test_user"


#import "ZHChooseFirmwareTableViewController.h"
@interface ZHDeviceActionViewController ()<ZHBandSwitchPropertyProtocol>
@property (nonatomic, strong) ZHRealTekSportItem *currentSportItem;
@property (nonatomic) NSInteger sitTime;
@end

@implementation ZHDeviceActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Actions";
    
    UILabel *headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 60.0)];
    headerLabel.text = @"必须先绑定手环,才能操作命令";
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.backgroundColor = [UIColor colorWithRed:255.0 / 255 green:108.0 / 255 blue:118.0 / 255 alpha:1.0];
    
    self.showTableView.tableHeaderView = headerLabel;
    self.showTableView.tableFooterView = [UIView new];
    [self.showTableView registerNib:[UINib nibWithNibName:@"ZHCommandTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:DeviceActionCellIdentifier];
    [self.showTableView registerNib:[UINib nibWithNibName:@"ZHTitleAndSwitchTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:DeviceSwitchCellIdentifier];
    [self initialData];
    //Commands
    self.commands =@[@"绑定命令",@"设置命令",@"运动数据命令",@"辅助命令",@"固件升级命令", @"测试命令"];
    //keys
    self.commandkeys = [NSMutableArray array];
    [self.commandkeys addObject:[self getBindCommandKeys]];
    [self.commandkeys addObject:[self getSetCommandKeys]];
    [self.commandkeys addObject:[self getSportCommandKeys]];
    [self.commandkeys addObject:[self getAssistCommandKeys]];
    [self.commandkeys addObject:[self getOTACommandKeys]];
    [self.commandkeys addObject:[self getTestCommandKeys]];
    
    
    
    [ZHRealTekDataManager shareRealTekDataManager].sportDataUpdateBlock = ^(ZHRealTekDevice *device, NSError *error, id result){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result && !error) {
                NSArray *sportsArray = result;
                
                NSString *detail = nil;
                if (sportsArray.count == 1) {
                    _currentSportItem = sportsArray.firstObject;
                    detail = [NSString stringWithFormat:@"Step:%ld--Calory:%ld--Distance:%ld",(long)_currentSportItem.stepCount,(long)_currentSportItem.calories,(long)_currentSportItem.distance];
                }else{
                    detail = [NSString stringWithFormat:@"Receive Sport Count:%ld",(unsigned long)sportsArray.count];
                }
                [SVProgressHUD showInfoWithStatus:detail];
            }
            
        });
    };
    
    [ZHRealTekDataManager shareRealTekDataManager].sleepDataUpdateBlock = ^(ZHRealTekDevice *device, NSError *error, id result){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result && !error) {
                NSArray *sleepItems = result;
                NSString *detail = [NSString stringWithFormat:@"Sleep Items Counts:%ld",(long)sleepItems.count];
                [SVProgressHUD showInfoWithStatus:detail];
            }
            
        });
        
    };
    
    [ZHRealTekDataManager shareRealTekDataManager].heartRateDataUpdateBlock = ^(ZHRealTekDevice *device, NSError *error, id result){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error && result) {
                NSArray *array = result;
                NSInteger num = array.count;
                NSString *info = [NSString stringWithFormat:@"Receive heart rate numbers %ld",(long)num];
                if (array.count == 1) {
                    ZHRealTekHRItem *item = array.firstObject;
                    NSString *time = item.time;
                    info = [NSString stringWithFormat:@"Receive heart rate: %ld-time:%@",(long)item.heartRate,time];
                }
                [SVProgressHUD showInfoWithStatus:info];
            }
        });
        
    };
    
    [ZHRealTekDataManager shareRealTekDataManager].stopMeasuringHRBlock = ^(ZHRealTekDevice *device, NSError *error, id result){
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *info = [NSString stringWithFormat:@"Receive The device stops measuring the heart rate callbacks"];
            [SVProgressHUD showInfoWithStatus:info];
            
        });
    };
    
    
    [ZHRealTekDataManager shareRealTekDataManager].powerUpdateBlock = ^(ZHRealTekDevice *device, NSError *error, id result){
        if (!error) {
            NSNumber *power = result;
            int32_t powerNum = power.intValue;
            NSString *info = [NSString stringWithFormat:@"Power have changed:%d",powerNum];
            [SVProgressHUD showInfoWithStatus:info];
        }
    };
    
    [ZHRealTekDataManager shareRealTekDataManager].cameraModeUpdateBlock = ^(ZHRealTekDevice *device, NSError *error){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                static NSInteger num = 0;
                num ++;
                NSString *info = [NSString stringWithFormat:@"Receive Camera mode update numers %ld",(long)num];
                [SVProgressHUD showInfoWithStatus:info];
            }
        });
    };
    
    
    
    
    [ZHRealTekDataManager shareRealTekDataManager].bloodPressureDataUpdateBlock = ^(ZHRealTekDevice *device, NSError *error, id result){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error && result) {
                NSArray *array = result;
                NSInteger num = array.count;
                NSString *info = [NSString stringWithFormat:@"Receive Blood Pressure numbers %ld",(long)num];
                if (array.count == 1) {
                    ZHRealTekBPItem *item = array.firstObject;
                    NSString *time = item.time;
                    info = [NSString stringWithFormat:@"Receive Blood Pressure Data time:%@--HR: %ld--LowBP:%ld--HighBP:%ld",time,(long)item.heartRate,(long)item.lowPressure,(long)item.highPressure];
                }
                [SVProgressHUD showInfoWithStatus:info];
            }
        });
        
    };
    
    
    
    [ZHRealTekDataManager shareRealTekDataManager].stopMeasuringBloodPressureBlock = ^(ZHRealTekDevice *device, NSError *error, id result){
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *info = [NSString stringWithFormat:@"Receive The device stops measuring Blood Pressure callbacks"];
            [SVProgressHUD showInfoWithStatus:info];
            
        });
    };
    
    
    // Do any additional setup after loading the view from its nib.
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    /*ZHRealTekDataManager *manager = [ZHRealTekDataManager shareRealTekDataManager];
     if (manager.connectedDevice) {
     [manager cancelPeripheralConnection:manager.connectedDevice onFinished:^(ZHRealTekDevice *device, NSError *error){
     if (error) {
     dispatch_async(dispatch_get_main_queue(), ^{
     [SVProgressHUD showErrorWithStatus:error.localizedDescription];
     });
     }
     }];
     }*/
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Initial Data
-(void)initialData
{
    self.sitTime = 30;
}

#pragma mark - Get Command Keys

-(NSArray *)getBindCommandKeys
{
    ZHFunctionModel *login = [[ZHFunctionModel alloc]initWithTitle:NSLocalizedString(@"登录", @"Login") cellMode:ZHOnlyTitle functionMode:ZHLogin];
    ZHFunctionModel *bind = [[ZHFunctionModel alloc]initWithTitle:NSLocalizedString(@"绑定用户", @"Bind User") cellMode:ZHOnlyTitle functionMode:ZHBind];
    ZHFunctionModel *cancelBind = [[ZHFunctionModel alloc]initWithTitle:NSLocalizedString(@"解除绑定", @"Cancel Bind") cellMode:ZHOnlyTitle functionMode:ZHCancelBind];
    ZHFunctionModel *cancelConnect = [[ZHFunctionModel alloc]initWithTitle:NSLocalizedString(@"断开连接", @"Cancel Connect") cellMode:ZHOnlyTitle functionMode:ZHCancelConnect];
    
    return @[login,bind,cancelBind,cancelConnect];
}

-(NSArray *)getSetCommandKeys
{
    ZHFunctionModel *synTime = [[ZHFunctionModel alloc]initWithTitle:NSLocalizedString(@"同步时间", @"SynTime") cellMode:ZHOnlyTitle functionMode:ZHSynTime];
    ZHFunctionModel *setAlarm = [[ZHFunctionModel alloc]initWithTitle:NSLocalizedString(@"设置闹钟", @"SetAlarms") cellMode:ZHOnlyTitle functionMode:ZHSynAlarm];
    ZHFunctionModel *getAlarms = [[ZHFunctionModel alloc]initWithTitle:NSLocalizedString(@"获取闹钟列表", @"GetAlarms") cellMode:ZHOnlyTitle functionMode:ZHGetAlarms];
    ZHFunctionModel *setStepTarget = [[ZHFunctionModel alloc]initWithTitle:NSLocalizedString(@"计步目标设定", @"Set Step Target") cellMode:ZHOnlyTitle functionMode:ZHSetStepTarget];
    ZHFunctionModel *setUserProfile = [[ZHFunctionModel alloc]initWithTitle:NSLocalizedString(@"用户信息设置", @"Syn User Profile") cellMode:ZHOnlyTitle functionMode:ZHSynUserProfile];
    ZHFunctionModel *sittingRemider = [[ZHFunctionModel alloc]initWithTitle:NSLocalizedString(@"久坐提醒", @"Long Sit Remider") cellMode:ZHTitleAndSwitch functionMode:ZHSetSittingReminder];
    ZHFunctionModel *getSittingRemider = [[ZHFunctionModel alloc]initWithTitle:NSLocalizedString(@"获取久坐提醒", @"Get Long Sit Remider") cellMode:ZHOnlyTitle functionMode:ZHGetSittingReminder];
    ZHFunctionModel *synPhoneSystem = [[ZHFunctionModel alloc]initWithTitle:NSLocalizedString(@"手机操作系统设置", @"Set Mobile System") cellMode:ZHOnlyTitle functionMode:ZHSetMobileSystem];
    ZHFunctionModel *enterPhotoMode = [[ZHFunctionModel alloc]initWithTitle:NSLocalizedString(@"进入拍照模式", @"Enter Camera Mode") cellMode:ZHOnlyTitle functionMode:ZHEnterPhotoMode];
    ZHFunctionModel *exitPhotoMode = [[ZHFunctionModel alloc]initWithTitle:NSLocalizedString(@"退出拍照模式", @"Exit Photo Mode") cellMode:ZHOnlyTitle functionMode:ZHExitPhotoMode];
    ZHFunctionModel *RHLightScreen = [[ZHFunctionModel alloc]initWithTitle:NSLocalizedString(@"抬手亮屏", @"Raise Hand Light Screen") cellMode:ZHTitleAndSwitch functionMode:ZHSetRaiseHandLight];
    ZHFunctionModel *getRHLightScreenSetting = [[ZHFunctionModel alloc]initWithTitle:NSLocalizedString(@"获取抬手亮屏状态", @"Get Raise Hand Light Screen Status") cellMode:ZHOnlyTitle functionMode:ZHGetRaiseHandLightSet];
    ZHFunctionModel *qqReminder = [[ZHFunctionModel alloc]initWithTitle:NSLocalizedString(@"QQ提醒", @"QQ Reminder") cellMode:ZHTitleAndSwitch functionMode:ZHQQReminder];
    ZHFunctionModel *wechatReminder = [[ZHFunctionModel alloc]initWithTitle:NSLocalizedString(@"微信提醒", @"Wechat Reminder") cellMode:ZHTitleAndSwitch functionMode:ZHWeChatReminder];
    ZHFunctionModel *smsReminder = [[ZHFunctionModel alloc]initWithTitle:NSLocalizedString(@"短信提醒", @"SMS Reminder") cellMode:ZHTitleAndSwitch functionMode:ZHSMSReminder];
    ZHFunctionModel *lineReminder = [[ZHFunctionModel alloc]initWithTitle:NSLocalizedString(@"Line提醒", @"Line Reminder") cellMode:ZHTitleAndSwitch functionMode:ZHLineReminder];
    ZHFunctionModel *incomingReminder = [[ZHFunctionModel alloc]initWithTitle:NSLocalizedString(@"来电提醒", @"inComing Reminder") cellMode:ZHTitleAndSwitch functionMode:ZHIncomingReminder];
    ZHFunctionModel *setScreenDirection = [[ZHFunctionModel alloc]initWithTitle:NSLocalizedString(@"横竖屏设置", @"Screen setup") cellMode:ZHTitleAndSwitch functionMode:ZHSetScreenOrientation];
    ZHFunctionModel *getScreenDirection = [[ZHFunctionModel alloc]initWithTitle:NSLocalizedString(@"获取横竖屏设置", @"Get screen Setup") cellMode:ZHOnlyTitle functionMode:ZHGetScreenOrientation];
    return @[synTime,setAlarm,getAlarms,setStepTarget,setUserProfile,sittingRemider,getSittingRemider,synPhoneSystem,enterPhotoMode,exitPhotoMode,RHLightScreen,getRHLightScreenSetting,qqReminder,wechatReminder,smsReminder,lineReminder,incomingReminder,setScreenDirection,getScreenDirection];
    
    
}



-(NSArray *)getSportCommandKeys
{
    ZHFunctionModel *hisData = [[ZHFunctionModel alloc]initWithTitle:NSLocalizedString(@"同步历史数据", @"Syn History data") cellMode:ZHOnlyTitle functionMode:ZHGetHistoryData];
    ZHFunctionModel *realTimeData = [[ZHFunctionModel alloc]initWithTitle:NSLocalizedString(@"开启实时数据同步", @"Open RealTime data synchronies") cellMode:ZHTitleAndSwitch functionMode:ZHGetRealTimeData];
    ZHFunctionModel *getOnceHeartRate = [[ZHFunctionModel alloc]initWithTitle:NSLocalizedString(@"请求一次心率数据", @"Get Once Heart Rate Data") cellMode:ZHOnlyTitle functionMode:ZHOnceHR];
    ZHFunctionModel *getContinuousHR = [[ZHFunctionModel alloc]initWithTitle:NSLocalizedString(@"心率数据连续测量", @"Get Continuous Heart Rate Data") cellMode:ZHTitleAndSwitch functionMode:ZHContinuousHR];
    ZHFunctionModel *getContinuousHRSitting = [[ZHFunctionModel alloc]initWithTitle:NSLocalizedString(@"获取连续心率设置是否开启", @"Get Continuous Heart Rate Setting") cellMode:ZHOnlyTitle functionMode:ZHGetContinuousHRSetting];
    ZHFunctionModel *synlastSportData = [[ZHFunctionModel alloc]initWithTitle:NSLocalizedString(@"同步最近15分钟的运动数据", @"Synchronize recent 15-minute movement data") cellMode:ZHOnlyTitle functionMode:ZHSycLastSportData];
    ZHFunctionModel *synTodaySportData = [[ZHFunctionModel alloc]initWithTitle:NSLocalizedString(@"同步今天所有运动数据", @"Synchronize all movement data today") cellMode:ZHOnlyTitle functionMode:ZHSycTodayAllSportData];
    ZHFunctionModel *bloodPressure = [[ZHFunctionModel alloc]initWithTitle:NSLocalizedString(@"血压测量", @"Measuring blood pressure") cellMode:ZHTitleAndSwitch functionMode:ZHBloodPressure];
    return @[hisData,realTimeData,getOnceHeartRate,getContinuousHR,getContinuousHRSitting,synlastSportData,synTodaySportData,bloodPressure];
    
}

-(NSArray *)getAssistCommandKeys
{
    ZHFunctionModel *findBand = [[ZHFunctionModel alloc]initWithTitle:NSLocalizedString(@"查找我的手环", @"Find My Band") cellMode:ZHOnlyTitle functionMode:ZHFindBand];
    ZHFunctionModel *modifyDeviceName = [[ZHFunctionModel alloc]initWithTitle:NSLocalizedString(@"修改设备名称", @"Modify Device Name") cellMode:ZHOnlyTitle functionMode:ZHSetBandName];
    ZHFunctionModel *getBandDeviceName = [[ZHFunctionModel alloc]initWithTitle:NSLocalizedString(@"获取设备名称", @"Get Device Name") cellMode:ZHOnlyTitle functionMode:ZHGetBandName];
    ZHFunctionModel *getBattery = [[ZHFunctionModel alloc]initWithTitle:NSLocalizedString(@"获取电量等级", @"Get Battery") cellMode:ZHOnlyTitle functionMode:ZHGetBattery];
    ZHFunctionModel *getAppVersion = [[ZHFunctionModel alloc]initWithTitle:NSLocalizedString(@"获取固件App版本", @"Get Firmware App Version") cellMode:ZHOnlyTitle functionMode:ZHGetAppVersion];
    ZHFunctionModel *getPatchVersion = [[ZHFunctionModel alloc]initWithTitle:NSLocalizedString(@"获取固件Patch版本", @"Get Firmware Patch Version") cellMode:ZHOnlyTitle functionMode:ZHGetPatchVersion];
    ZHFunctionModel *getMacAddress = [[ZHFunctionModel alloc]initWithTitle:NSLocalizedString(@"获取固件Mac地址", @"Get Firmware Mac Address") cellMode:ZHOnlyTitle functionMode:ZHGetMacAddress];
    ZHFunctionModel *getSDKVersion = [[ZHFunctionModel alloc]initWithTitle:NSLocalizedString(@"获取SDK版本", @"Get SDK Version") cellMode:ZHOnlyTitle functionMode:ZHGetSDKVersion];
    return @[findBand,modifyDeviceName,getBandDeviceName,getBattery,getAppVersion,getPatchVersion,getMacAddress,getSDKVersion];
}


-(NSArray *)getOTACommandKeys
{
    ZHFunctionModel *checkOTAUpdate = [[ZHFunctionModel alloc]initWithTitle:NSLocalizedString(@"检测固件是否有更新", @"Check for firmware updates") cellMode:ZHOnlyTitle functionMode:ZHCheckOTAVersion];
    ZHFunctionModel *updateFirmWare = [[ZHFunctionModel alloc]initWithTitle:NSLocalizedString(@"开始固件升级", @"Begin Update Firmware") cellMode:ZHOnlyTitle functionMode:ZHUpdateOTA];
    return @[checkOTAUpdate,updateFirmWare];
}


-(NSArray *)getTestCommandKeys
{
    ZHFunctionModel *testUpdateOTA = [[ZHFunctionModel alloc]initWithTitle:NSLocalizedString(@"选择固件进行升级", @"Choose OTA Update") cellMode:ZHOnlyTitle functionMode:ZHTestUpdateOTA];
    ZHFunctionModel *multiBleCommands = [[ZHFunctionModel alloc]initWithTitle:NSLocalizedString(@"同时发送多个命令", @"同时发送多个命令") cellMode:ZHOnlyTitle functionMode:ZHTestMultiCmd];
    ZHFunctionModel *testUserModel = [[ZHFunctionModel alloc]initWithTitle:NSLocalizedString(@"测试用户", @"测试用户") cellMode:ZHOnlyTitle functionMode:ZHTestUser];
    ZHFunctionModel *testLog = [[ZHFunctionModel alloc]initWithTitle:NSLocalizedString(@"Log文件", @"Log文件") cellMode:ZHOnlyTitle functionMode:ZHTestLog];
    ZHFunctionModel *testMultiReminder = [[ZHFunctionModel alloc]initWithTitle:NSLocalizedString(@"连续发送所有通知开关", @"Send all reminder status") cellMode:ZHTitleAndSwitch functionMode: ZHTestMultiReminder];
    ZHFunctionModel *testCMultiReminder = [[ZHFunctionModel alloc]initWithTitle:NSLocalizedString(@"依次发送所有通知开关", @"Send all reminder status") cellMode:ZHTitleAndSwitch functionMode: ZHTestMultiReminder];
    return @[testUpdateOTA,multiBleCommands,testUserModel,testLog,testMultiReminder,testCMultiReminder];
}


#pragma mark － TableView datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.commands.count;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.commandkeys.count > section) {
        NSArray *keys = [self.commandkeys objectAtIndex:section];
        return keys.count;
        
    }else
        return 0;
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *command = [self.commands objectAtIndex:section];
    return command;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 70.0;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *keys = [self.commandkeys objectAtIndex:indexPath.section];
    ZHFunctionModel *functionModel = [keys objectAtIndex:indexPath.row];
    if (functionModel.cellMode == ZHOnlyTitle) {
        ZHCommandTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DeviceActionCellIdentifier forIndexPath:indexPath];
        cell.textLabel.text = functionModel.title;
        cell.detailTextLabel.text = nil;
        return cell;
    }else{
        ZHTitleAndSwitchTableViewCell *switchCell = [tableView dequeueReusableCellWithIdentifier:DeviceSwitchCellIdentifier forIndexPath:indexPath];
        switchCell.delegate = self;
        switchCell.titleLabel.text = functionModel.title;
        return switchCell;
    }
    
    
}


#pragma mark - TableView delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *keys = [self.commandkeys objectAtIndex:indexPath.section];
    ZHFunctionModel *functionModel = [keys objectAtIndex:indexPath.row];
    if (functionModel.cellMode == ZHTitleAndSwitch) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell setSelected:NO animated:NO];
    }
    if (indexPath.section == 0) {
        [self sendBindCommandWithIndexPath:indexPath];
    }else if (indexPath.section == 1) {
        [self sendSetCommandWithIndexPath:indexPath];
    }else if(indexPath.section == 2){
        [self sendSportCmmandWithIndexPath:indexPath];
    }else if (indexPath.section == 3){
        [self sendAssistCommandWithIndexPath:indexPath];
    }else if (indexPath.section == 4){
        [self sendFirmwareCommandWithIndexPath:indexPath];
    }else if (indexPath.section == 5){
        [self sendTestCommandWithIndexPath:indexPath];
    }
}



-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}



#pragma mark - Send Command
//Bind Command
-(void)sendBindCommandWithIndexPath:(NSIndexPath *)indexPath
{
    NSArray *keys = [self.commandkeys objectAtIndex:indexPath.section];
    ZHFunctionModel *functionModel = [keys objectAtIndex:indexPath.row];
    
    switch (functionModel.functionMode) {
        case ZHLogin:{
            [self loginWithIdentifier:TestUserIdentifier];
        }
            break;
        case ZHBind:{ //Bind device
            [self bindDeviceWithIdentifier:TestUserIdentifier];
            
        }
            break;
            
        case ZHCancelBind:{//Unbind device
            [self unBind];
        }
            break;
            
        case ZHCancelConnect:{// Cancel connect
            [self cancelConnect];
        }
            break;
        default:
            break;
    }
}


//Set Command
-(void)sendSetCommandWithIndexPath:(NSIndexPath *)indexPath
{
    NSArray *keys = [self.commandkeys objectAtIndex:indexPath.section];
    ZHFunctionModel *functionModel = [keys objectAtIndex:indexPath.row];
    switch (functionModel.functionMode) {
        case ZHSynTime:{ //Syn Time
            [self synTime];
        }
            break;
            
        case ZHSynAlarm:{ // Set Alarms
            [self setAlarms];
        }
            break;
            
        case ZHGetAlarms:{// get Alarms
            [self getAlarms];
        }
            break;
            
        case ZHSetStepTarget:{// Set Step Target
            [self setStepTarget];
        }
            break;
        case ZHSynUserProfile:{// set user profile
            [self setUserProfile];
        }
            break;
        case ZHSetlost:{// Loss Alert set
            [self setLossLevel];
        }
            break;
            
        case ZHGetSittingReminder:{// Get Long Sit Remind Data
            [self getLongSitRemind];
        }
            break;
        case ZHSetMobileSystem:{// Set OS
            [self setOS];
        }
            break;
        case ZHEnterPhotoMode:{ //  enter camera mode
            [self enterCameraMode];
        }
            break;
        case ZHExitPhotoMode:{ // quit camera mode
            [self quitCameraMode];
        }
            break;
            
        case ZHGetRaiseHandLightSet:{ // Get Turn Wrist Light
            [self getTurnWristLight];
        }
            break;
        case ZHSetSittingReminder:{
            [self setLongSit:[self.showTableView cellForRowAtIndexPath:indexPath]];
        }
            break;
        case ZHGetScreenOrientation:{
            [self getScreenOrientation];
        }
            break;
        default:
            break;
    }
}



//Sport Command
-(void)sendSportCmmandWithIndexPath:(NSIndexPath *)indexPath
{
    NSArray *keys = [self.commandkeys objectAtIndex:indexPath.section];
    ZHFunctionModel *functionModel = [keys objectAtIndex:indexPath.row];
    
    switch (functionModel.functionMode) {
        case ZHGetHistoryData:{ // get his data
            [self getHisData];
        }
            break;
        case ZHOnceHR:{ // enable to obtain a heart rate data
            [self getOneceHeartRate];
        }
            break;
            
        case ZHGetContinuousHRSetting:{ // Gets whether to open continuous measurement of heart rate function.
            [self getContinuousHeartRateSetting];
        }
            break;
        case ZHSycLastSportData: //Synchronize movement data in the last 15 minutes
        {
            [self sycLastSportData];
        }
            break;
        case ZHSycTodayAllSportData: //Synchronize all movement data today
        {
            [self sycTodayTotalSportData];
        }
            break;
        default:
            break;
    }
}



#pragma mark assist Command
-(void)sendAssistCommandWithIndexPath:(NSIndexPath *)indexPath
{
    NSArray *keys = [self.commandkeys objectAtIndex:indexPath.section];
    ZHFunctionModel *functionModel = [keys objectAtIndex:indexPath.row];
    switch (functionModel.functionMode) {
        case ZHFindBand:{// find me
            [self findDevice];
        }
            break;
        case ZHSetBandName: { // modify device name
            [self modifyName];
        }
            break;
        case ZHGetBandName:{// get device name
            [self getdeviceName];
        }
            break;
        case ZHGetBattery:{ // get battery level
            [self getBatteryLevel];
        }
            break;
        case ZHGetAppVersion:{ // get FirmWare app version
            [self getFirmWareAppVersion];
        }
            break;
        case ZHGetPatchVersion:{ // get FirmWare patch version
            [self getFirmWarePatchVersion];
        }
            break;
        case ZHGetMacAddress:{ // get FirmWare MacAdress
            [self getFirmWareMacAdress];
        }
            break;
        case ZHGetSDKVersion:{ // get SDK Version
            [self getSDKVersion];
        }
            break;
            
        default:
            break;
    }
}


#pragma mark - OTA Command
-(void)sendFirmwareCommandWithIndexPath:(NSIndexPath *)indexPath
{
    NSArray *keys = [self.commandkeys objectAtIndex:indexPath.section];
    ZHFunctionModel *functionModel = [keys objectAtIndex:indexPath.row];
    
    switch (functionModel.functionMode) {
        case ZHCheckOTAVersion:{ // Check to see if the firmware needs to be updated.
            [self checkFirmWareUpdate];
        }
            break;
        case ZHUpdateOTA:{ // Begin firmWare Update
            [self beginUpdateFirmWare];
        }
            break;
            
            
            
        default:
            break;
    }
}

#pragma mark Test Command
-(void)sendTestCommandWithIndexPath:(NSIndexPath *)indexPath
{
    NSArray *keys = [self.commandkeys objectAtIndex:indexPath.section];
    ZHFunctionModel *functionModel = [keys objectAtIndex:indexPath.row];
    switch (functionModel.functionMode) {
        case ZHEnterOTAMode:{ // Test Enter OTA Mode
            [self enterOTAMode];
        }
            break;
        case ZHTestUpdateOTA:{ // Test Use Special Firmware Update.
            [self gotoTestUpdateOTA];
        }
            break;
        case ZHTestMultiCmd:{ // Test Multiple commands
            [self sendMultipleCommands];
        }
            break;
        case ZHTestUser:{
            [self handlerTestUser];
        }
            break;
        case ZHTestLog:{
            [self handlerLogFile];
        }
            break;
        default:
            break;
    }
}


#pragma mark - Functions

#pragma mark - Login Bind disconnect function
-(void)loginWithIdentifier:(NSString *)identifier
{
    [SVProgressHUD show];
    [[ZHRealTekDataManager shareRealTekDataManager]loginDeviceWithIdentifier:identifier onFinished:^(ZHRealTekDevice *device, NSError *error,id result){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                
            }else{
                ZH_RealTek_Login_Status status = [result intValue];
                switch (status) {
                    case RealTek_Login_Success:
                    {
                        
                        [SVProgressHUD showSuccessWithStatus:@"Login success indicates that it is already bound"];
                    }
                        break;
                    case RealTek_Login_TimeOut:
                        [SVProgressHUD showErrorWithStatus:@"The user ID is inconsistent and the login fails"];
                        break;
                        
                    default:
                        break;
                }
                
            }
        });
        
    }];
    
}


-(void)bindDeviceWithIdentifier:(NSString *)identifier
{
    [SVProgressHUD show];
    
    [[ZHRealTekDataManager shareRealTekDataManager]bindDeviceWithIdentifier:identifier onFinished:^(ZHRealTekDevice *device, NSError *error,id result){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                
            }else{
                ZH_RealTek_Bind_Status status = [result intValue];
                switch (status) {
                    case RealTek_Bind_Success:{
                        
                        [SVProgressHUD showSuccessWithStatus:@"Bind Success"];
                    }
                        break;
                    case RealTek_Bind_Faild:
                        [SVProgressHUD showErrorWithStatus:@"Operation Timeout failed"];
                        break;
                        
                    default:
                        break;
                }
                
            }
        });
        
    }];
    
}


-(void)unBind
{
    [SVProgressHUD show];
    [[ZHRealTekDataManager shareRealTekDataManager]unBindDeviceonFinished:^(ZHRealTekDevice *device, NSError *error, id result){
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            });
            
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showSuccessWithStatus:nil];
            });
            
            [[ZHRealTekDataManager shareRealTekDataManager]cancelPeripheralConnection:device onFinished:^(ZHRealTekDevice *tDevice, NSError *tError){
                if (error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                    });
                    
                }
            }];
            
        }
    }];
    
}



-(void)cancelConnect
{
    [SVProgressHUD show];
    ZHRealTekDataManager *manager = [ZHRealTekDataManager shareRealTekDataManager];
    ZHRealTekDevice *connectDevice = manager.connectedDevice;
    [[ZHRealTekDataManager shareRealTekDataManager]cancelPeripheralConnection:connectDevice onFinished:^(ZHRealTekDevice *device, NSError *error){
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                [self.navigationController popViewControllerAnimated:YES];
            });
            
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            });
        }
    }];
    
}

#pragma mark - Assist Function
-(void)findDevice
{
    [SVProgressHUD show];
    [[ZHRealTekDataManager shareRealTekDataManager]findMyBandDeviceonFinished:^(ZHRealTekDevice *device, NSError *error, id result){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }else{
                [SVProgressHUD showSuccessWithStatus:@"Send find device Command Success"];
            }
            
        });
    }];
}

-(void)modifyName
{
    
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Band Name", @"Band Name") message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertView addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = @"Name";
        
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", @"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", @"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [SVProgressHUD show];
        UITextField *nameTextField = [alertView.textFields firstObject];
        NSString *name = nameTextField.text;
        if (name && name.length > 0) {
            [[ZHRealTekDataManager shareRealTekDataManager]modifyDeviceName:name onFinished:^(ZHRealTekDevice *device, NSError *error, id result){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error) {
                        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                    }else{
                        [SVProgressHUD showSuccessWithStatus:@"Modify device name success"];
                    }
                });
            }];
            
        }
        
    }];
    [alertView addAction:cancelAction];
    [alertView addAction:okAction];
    [self presentViewController:alertView animated:YES completion:nil];
    
}



-(void)getdeviceName
{
    [SVProgressHUD show];
    [[ZHRealTekDataManager shareRealTekDataManager]getDeviceNameonFinished:^(ZHRealTekDevice *device, NSError *error, id result){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }else{
                NSString *info = [NSString stringWithFormat:@"Get device name success,name:%@",result];
                [SVProgressHUD showSuccessWithStatus:info];
            }
        });
    }];
}


-(void)getBatteryLevel
{
    [SVProgressHUD show];
    [[ZHRealTekDataManager shareRealTekDataManager]getBatteryLevelonFinished:^(ZHRealTekDevice *device, NSError *error, id result){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }else{
                int level = [result intValue];
                NSString *info = [NSString stringWithFormat:@"Get Battery Level success %d",level];
                [SVProgressHUD showSuccessWithStatus:info];
            }
        });
    }];
    
}



-(void)synTime
{
    [SVProgressHUD show];
    [[ZHRealTekDataManager shareRealTekDataManager]synTimeonFinished:^(ZHRealTekDevice *device, NSError *error,id result){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }else{
                [SVProgressHUD showSuccessWithStatus:@"Syn time success"];
            }
        });
        
    }];
    
}

#pragma mark - Set function
-(void)setAlarms
{
    [SVProgressHUD show];
    NSArray *alarms = [self getTestAlarms];
    [[ZHRealTekDataManager shareRealTekDataManager]synAlarms:alarms onFinished:^(ZHRealTekDevice *device, NSError *error, id result){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }else{
                [SVProgressHUD showSuccessWithStatus:@"Syn alarm success"];
            }
        });
        
    }];
    
}


-(void)getAlarms
{
    [SVProgressHUD show];
    [[ZHRealTekDataManager shareRealTekDataManager]getBandAlarmsonFinished:^(ZHRealTekDevice *device, NSError *error, id result){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }else{
                if (result) {
                    NSArray *alarms = result;
                    NSString *info = [NSString stringWithFormat:@"Get alarms success:%ld",(long)alarms.count];
                    [SVProgressHUD showSuccessWithStatus:info];
                }else{
                    [SVProgressHUD showErrorWithStatus:@"get alarms faild"];
                }
            }
        });
        
    }];
    
}


-(void)setStepTarget
{
    
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Step Target", @"Step Target") message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertView addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = @"Steps";
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", @"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", @"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        UITextField *nameTextField = [alertView.textFields firstObject];
        NSString *name = nameTextField.text;
        if (name && name.length > 0) {
            [SVProgressHUD show];
            uint32_t stepTarget = [name intValue];
            [[ZHRealTekDataManager shareRealTekDataManager]setStepTarget:stepTarget onFinished:^(ZHRealTekDevice *device, NSError *error, id result){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error) {
                        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                    }else{
                        [SVProgressHUD showSuccessWithStatus:@"Set StepTarget Success"];
                    }
                    
                });
                
            }];
            
        }
        
    }];
    [alertView addAction:cancelAction];
    [alertView addAction:okAction];
    [self presentViewController:alertView animated:YES completion:nil];
    
}

-(void)setUserProfile
{
    ZH_RealTek_Gender gender = 1;
    uint8_t age = 20;
    float height = 170;
    float weight = 50;
    [SVProgressHUD show];
    [[ZHRealTekDataManager shareRealTekDataManager]setUserProfileWithGender:gender withAge:age withHeight:height withWeight:weight onFinished:^(ZHRealTekDevice *device, NSError *error, id result){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }else{
                [SVProgressHUD showSuccessWithStatus:@"Set UserProfile Success"];
            }
        });
    }];
}


-(void)setLossLevel
{
    ZH_RealTek_AlertLevel alertLevel = ZH_RealTek_AlertLevel_High;
    [SVProgressHUD show];
    [[ZHRealTekDataManager shareRealTekDataManager]setLossAlertLevel:alertLevel onFinished:^(ZHRealTekDevice *device, NSError *error, id result){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }else{
                [SVProgressHUD showSuccessWithStatus:@"Set Loss Alert Success"];
            }
        });
    }];
    
}


-(void)setLongSit:(UITableViewCell *)cell
{
    ZHTitleAndSwitchTableViewCell *switchCell = (ZHTitleAndSwitchTableViewCell *)cell;
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Set Time", @"Set Time") message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertView addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = @"time";
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", @"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", @"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        UITextField *nameTextField = [alertView.textFields firstObject];
        NSString *time = nameTextField.text;
        if (time && time.length > 0) {
            self.sitTime = time.integerValue;
            ZHRealTekLongSit *sit = [[ZHRealTekLongSit alloc]init];
            sit.enable = switchCell.switchView.on;
            sit.sitTime = self.sitTime;
            [SVProgressHUD show];
            [[ZHRealTekDataManager shareRealTekDataManager]setLongSitRemind:sit onFinished:^(ZHRealTekDevice *device, NSError *error, id result){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error) {
                        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                    }else{
                        [SVProgressHUD showSuccessWithStatus:@"Set Long Sit Success"];
                    }
                });
                
            }];
            
            
        }
        
    }];
    [alertView addAction:cancelAction];
    [alertView addAction:okAction];
    [self presentViewController:alertView animated:YES completion:nil];
}

-(void)getScreenOrientation
{
    BOOL haveScreenFunction = [ZHRealTekDataManager shareRealTekDataManager].connectedDevice.hasOrientationSwitchFunc;
    if (!haveScreenFunction) {
        [self showHaveNotFunctionReminder];
        return;
    }
    [SVProgressHUD show];
    [[ZHRealTekDataManager shareRealTekDataManager]getDisplayOrientation:^(ZHRealTekDevice *device, NSError *error, id result){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }else{
                NSNumber *number = result;
                int8_t orientation = number.intValue;
                NSString *info = [NSString stringWithFormat:@"Screen Orientation is "];
                if (orientation == ZH_Orientation_Landscape) {
                    info = [info stringByAppendingString:@"Landscape"];
                }else if (orientation == ZH_Orientation_Portrait){
                    info = [info stringByAppendingString:@"Portrait"];
                }else{
                    info = [info stringByAppendingString:@"Unknown"];
                }
                [SVProgressHUD showInfoWithStatus:info];
            }
        });
        
    }];
}


-(void)setLongSitRemind:(BOOL)onEable
{
    
    ZHRealTekLongSit *sit = [[ZHRealTekLongSit alloc]init];
    sit.enable = onEable;
    sit.sitTime = self.sitTime;
    [SVProgressHUD show];
    [[ZHRealTekDataManager shareRealTekDataManager]setLongSitRemind:sit onFinished:^(ZHRealTekDevice *device, NSError *error, id result){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }else{
                [SVProgressHUD showSuccessWithStatus:@"Set Long Sit Success"];
            }
        });
        
    }];
    
}

-(void)getLongSitRemind
{
    [SVProgressHUD show];
    [[ZHRealTekDataManager shareRealTekDataManager]getLongSitRemindonFinished:^(ZHRealTekDevice *device, NSError *error, id result){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }else{
                if (result) {
                    BOOL onEnable = [result boolValue];
                    NSString *info = @"Long Sit is On";
                    if (!onEnable) {
                        info = @"Long Sit is Off";
                    }
                    [SVProgressHUD showSuccessWithStatus:info];
                }else{
                    [SVProgressHUD showErrorWithStatus:@"Get Long Sit Failed"];
                }
                
            }
        });
        
    }];
}

-(void)setOS
{
    ZH_RealTek_OS os = ZH_RealTek_OS_iOS;
    [SVProgressHUD show];
    [[ZHRealTekDataManager shareRealTekDataManager]setMoblieOS:os onFinished:^(ZHRealTekDevice *device, NSError *error, id result){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }else{
                [SVProgressHUD showSuccessWithStatus:@"Set OS Success"];
            }
        });
        
    }];
    
}

-(void)enterCameraMode
{
    [SVProgressHUD show];
    [[ZHRealTekDataManager shareRealTekDataManager]setCameraMode:YES onFinished:^(ZHRealTekDevice *device, NSError *error, id result){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }else{
                [SVProgressHUD showSuccessWithStatus:@"Enter Camera mode"];
            }
        });
    }];
}

-(void)quitCameraMode
{
    [SVProgressHUD show];
    [[ZHRealTekDataManager shareRealTekDataManager]setCameraMode:NO onFinished:^(ZHRealTekDevice *device, NSError *error, id result){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }else{
                [SVProgressHUD showSuccessWithStatus:@"Quit Camera mode"];
            }
        });
    }];
    
}


-(void)turnWirstLight:(BOOL)onEable
{
    [SVProgressHUD show];
    BOOL enable = onEable;
    [[ZHRealTekDataManager shareRealTekDataManager]setTurnWristLightEnabled:enable onFinished:^(ZHRealTekDevice *device, NSError *error, id result){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }else{
                [SVProgressHUD showSuccessWithStatus:@"Set Turn Wrist Light Success"];
            }
        });
        
    }];
}

-(void)getTurnWristLight
{
    [SVProgressHUD show];
    [[ZHRealTekDataManager shareRealTekDataManager]getTurnWristLightEnabledOnFinished:^(ZHRealTekDevice *device, NSError *error, id result){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }else{
                BOOL enable = [result boolValue];
                NSString *onOrOff = enable ? @"On":@"Off";
                [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"Turn Wrist is %@",onOrOff]];
            }
        });
    }];
}

-(void)setQQNotification:(BOOL)onEable
{
    [SVProgressHUD show];
    BOOL enable = onEable;
    [[ZHRealTekDataManager shareRealTekDataManager] setEnableQQNotificationEnabled:enable onFinished:^(ZHRealTekDevice *device, NSError *error, id result){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }else{
                [SVProgressHUD showSuccessWithStatus:@"Set QQ Notification Success"];
            }
        });
        
    }];
}

-(void)setWechatNotification:(BOOL)onEable
{
    [SVProgressHUD show];
    BOOL enable = onEable;
    [[ZHRealTekDataManager shareRealTekDataManager] setEnableWechatNotificationEnabled:enable onFinished:^(ZHRealTekDevice *device, NSError *error, id result){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }else{
                [SVProgressHUD showSuccessWithStatus:@"Set Wechat Notification Success"];
            }
        });
        
    }];
    
}

-(void)setSMSNotification:(BOOL)onEable
{
    [SVProgressHUD show];
    BOOL enable = onEable;
    [[ZHRealTekDataManager shareRealTekDataManager] setEnableSMSNotificationEnabled:enable onFinished:^(ZHRealTekDevice *device, NSError *error, id result){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }else{
                [SVProgressHUD showSuccessWithStatus:@"Set SMS Notification Success"];
            }
        });
        
    }];
    
}

-(void)setLineNotification:(BOOL)onEable
{
    [SVProgressHUD show];
    BOOL enable = onEable;
    [[ZHRealTekDataManager shareRealTekDataManager] setEnableLineNotificationEnabled:enable onFinished:^(ZHRealTekDevice *device, NSError *error, id result){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }else{
                [SVProgressHUD showSuccessWithStatus:@"Set Line Notification Success"];
            }
        });
        
    }];
    
}


-(void)setCallNotification:(BOOL)onEable
{
    [SVProgressHUD show];
    BOOL enable = onEable;
    [[ZHRealTekDataManager shareRealTekDataManager]setEnableCallNotificationEnabled:enable onFinished:^(ZHRealTekDevice *device, NSError *error, id result){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }else{
                [SVProgressHUD showSuccessWithStatus:@"Set Call Notification Success"];
            }
        });
    }];
}

-(void)getHisData
{
    [SVProgressHUD show];
    [[ZHRealTekDataManager shareRealTekDataManager]synHisDataOnFinished:^(ZHRealTekDevice *device, NSError *error, id result)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             if (error) {
                 [SVProgressHUD showErrorWithStatus:error.localizedDescription];
             }else{
                 if (result) {
                     NSDictionary *dic = result;
                     NSArray *sports = [dic objectForKey:ZH_RealTek_HisSportsKey];
                     NSArray *sleeps = [dic objectForKey:ZH_RealTek_HisSleepsKey];
                     NSString *temInfo = nil;
                     if ([dic.allKeys containsObject:ZH_RealTek_CalibrationKey])
                     {
                         ZHRealTekSportCalibrationItem *item = [result objectForKey:ZH_RealTek_CalibrationKey];
                         temInfo = [NSString stringWithFormat:@"Calibration totalSteps:%ld--totalCalory:%ld--totalDistance:%ld",(long)item.totalSteps,(long)item.totalCalory,(long)item.totalDistance];
                         
                     }
                     
                     NSString *info = [NSString stringWithFormat:@"Get His Data Success,sports count:%ld,sleeps count:%ld",(long)sports.count,(long)sleeps.count];
                     if (temInfo) {
                         info = [info stringByAppendingString:temInfo];
                     }
                     [SVProgressHUD showSuccessWithStatus:info];
                 }else{
                     [SVProgressHUD showSuccessWithStatus:@"Get His Data failed"];
                 }
                 
             }
         });
         
     }];
}


-(void)sycLastSportData
{
    uint16_t steps = 200;
    uint8_t activeTime = 9;
    uint32_t calory = 500;
    uint16_t distance = 400;
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitHour|NSCalendarUnitMinute;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    NSInteger hour = [dateComponent hour];
    NSInteger minute = dateComponent.minute;
    NSInteger offset = hour*4 + minute/15;
    ZH_RealTek_Sport_Mode mode = ZH_RealTek_Walk;
    [SVProgressHUD show];
    [[ZHRealTekDataManager shareRealTekDataManager]synRecentSportDataWithStep:steps activeTime:activeTime calory:calory distance:distance offset:offset mode:mode OnFinished:^(ZHRealTekDevice *device, NSError *error, id result){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }else{
                [SVProgressHUD showSuccessWithStatus:@"Syc Last sport data Success"];
            }
        });
        
    }];
}

-(void)sycTodayTotalSportData
{
    uint32_t totalSteps = 1000,totalCalory = 2000,totalDistance = 3000;
    [SVProgressHUD show];
    [[ZHRealTekDataManager shareRealTekDataManager]synTodayTotalSportDataWithStep:totalSteps distance:totalDistance calory:totalCalory OnFinished:^(ZHRealTekDevice *device, NSError *error, id result){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }else{
                [SVProgressHUD showSuccessWithStatus:@"Syc today total sport data Success"];
            }
        });
        
    }];
}

-(void)getRealTimeStepData:(BOOL)onEable
{
    BOOL onOff = onEable;
    [SVProgressHUD show];
    [[ZHRealTekDataManager shareRealTekDataManager]setRealTimeSynSportData:onOff onFinished:^(ZHRealTekDevice *device, NSError *error, id result){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }else{
                [SVProgressHUD showSuccessWithStatus:@"Set realtime step data Success"];
            }
        });
        
    }];
}


-(void)getOneceHeartRate
{
    [SVProgressHUD show];
    BOOL enable = YES;
    [[ZHRealTekDataManager shareRealTekDataManager]setRealTimeSynSportData:YES onFinished:^(ZHRealTekDevice *de, NSError *er , id res){
        if (!er) {
            [[ZHRealTekDataManager shareRealTekDataManager]setHRReadOneTimeEnable:enable onFinished:^(ZHRealTekDevice *device, NSError *error, id result){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error) {
                        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                    }else{
                        [SVProgressHUD showSuccessWithStatus:@"Enable Read oneTime heart rate success"];
                    }
                });
                
            }];
            
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showErrorWithStatus:er.localizedDescription];
            });
        }
    }];
}


-(void)getContinuousHeartRate:(BOOL)onEable
{
    [SVProgressHUD show];
    BOOL enable = onEable;
    uint8_t minute = 1;
    [[ZHRealTekDataManager shareRealTekDataManager]setRealTimeSynSportData:YES onFinished:^(ZHRealTekDevice *de, NSError *er , id res){
        if (!er) {
            [[ZHRealTekDataManager shareRealTekDataManager]setHRReadContinuous:enable Interval:minute onFinished:^(ZHRealTekDevice *device, NSError *error, id result){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error) {
                        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                    }else{
                        [SVProgressHUD showSuccessWithStatus:@"Enable Read Continuous hear rate success"];
                    }
                });
                
            }];
            
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showErrorWithStatus:er.localizedDescription];
            });
        }
    }];
    
}


-(void)setScreenOrientation:(BOOL)enable
{
    BOOL haveScreenFunction = [ZHRealTekDataManager shareRealTekDataManager].connectedDevice.hasOrientationSwitchFunc;
    if (!haveScreenFunction) {
        [self showHaveNotFunctionReminder];
        return;
    }
    ZH_RealTek_ScreenOrientation orientation = ZH_Orientation_Landscape;
    if (!enable) {
        orientation = ZH_Orientation_Portrait;
    }
    [SVProgressHUD show];
    [[ZHRealTekDataManager shareRealTekDataManager]SetDisplayOrientation:orientation OnFinished:^(ZHRealTekDevice *device, NSError *error, id result){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }else{
                [SVProgressHUD showSuccessWithStatus:nil];
            }
        });
    }];
}


-(void)setMultiReminder:(BOOL)enable
{
    
    [[ZHRealTekDataManager shareRealTekDataManager]setEnableQQNotificationEnabled:enable onFinished:^(ZHRealTekDevice *device, NSError *error, id result){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }else{
                [SVProgressHUD showSuccessWithStatus:@"Enable QQ Notification Success"];
            }
        });
    }];
    
    [[ZHRealTekDataManager shareRealTekDataManager]setEnableWechatNotificationEnabled:enable onFinished:^(ZHRealTekDevice *device, NSError *error, id result){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }else{
                [SVProgressHUD showSuccessWithStatus:@"Enable Wechat Notification Success"];
            }
        });
    }];
    
    [[ZHRealTekDataManager shareRealTekDataManager]setEnableSMSNotificationEnabled:enable onFinished:^(ZHRealTekDevice *device, NSError *error, id result){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }else{
                [SVProgressHUD showSuccessWithStatus:@"Enable SMS Notification Success"];
            }
        });
    }];
    
    [[ZHRealTekDataManager shareRealTekDataManager]setEnableCallNotificationEnabled:enable onFinished:^(ZHRealTekDevice *device, NSError *error, id result){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }else{
                [SVProgressHUD showSuccessWithStatus:@"Enable InCall Notification Success"];
            }
        });
    }];
}

-(void)sendCMultiReminder:(BOOL)enable
{
    [[ZHRealTekDataManager shareRealTekDataManager]setEnableQQNotificationEnabled:enable onFinished:^(ZHRealTekDevice *device, NSError *error, id result){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }else{
                [SVProgressHUD showSuccessWithStatus:@"Enable QQ Notification Success"];
            }
        });
        
        [[ZHRealTekDataManager shareRealTekDataManager]setEnableWechatNotificationEnabled:enable onFinished:^(ZHRealTekDevice *device, NSError *error, id result){
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                }else{
                    [SVProgressHUD showSuccessWithStatus:@"Enable Wechat Notification Success"];
                }
            });
            [[ZHRealTekDataManager shareRealTekDataManager]setEnableSMSNotificationEnabled:enable onFinished:^(ZHRealTekDevice *device, NSError *error, id result){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error) {
                        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                    }else{
                        [SVProgressHUD showSuccessWithStatus:@"Enable SMS Notification Success"];
                    }
                });
                [[ZHRealTekDataManager shareRealTekDataManager]setEnableCallNotificationEnabled:enable onFinished:^(ZHRealTekDevice *device, NSError *error, id result){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (error) {
                            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                        }else{
                            [SVProgressHUD showSuccessWithStatus:@"Enable All Notification Success"];
                        }
                    });
                }];
            }];
        }];
    }];
}


-(void)setBloodPressueEnable:(BOOL)enable
{
    if (![ZHRealTekDataManager shareRealTekDataManager].connectedDevice.hasBloodPressureFunc) {
        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"无血压功能!", @"No blood pressure!")];
        return;
    }
    [SVProgressHUD show];
    [[ZHRealTekDataManager shareRealTekDataManager]setBloodPressueEnable:enable onFinished:^(ZHRealTekDevice *device, NSError *error, id result){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }else{
                [SVProgressHUD showSuccessWithStatus:nil];
            }
        });
    }];
}

-(void)getContinuousHeartRateSetting
{
    [SVProgressHUD show];
    [[ZHRealTekDataManager shareRealTekDataManager]getHRReadContinuousSettingOnFinished:^(ZHRealTekDevice *device, NSError *error, id result){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }else{
                BOOL enable = [result boolValue];
                NSString *info = @"continuous measurement of heart rate is on";
                if (!enable) {
                    info = @"continuous measurement of heart rate is off";
                }
                [SVProgressHUD showSuccessWithStatus:info];
            }
        });
        
    }];
}



#pragma mark - OTA
-(void)getFirmWareAppVersion
{
    [SVProgressHUD show];
    [[ZHRealTekDataManager shareRealTekDataManager]getOTAApplicationVersiononFinished:^(ZHRealTekDevice *device, NSError *error, id result){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }else{
                if (result) {
                    int appversion = [result intValue];
                    NSString *info = [NSString stringWithFormat:@"Get OTA App Version Success %d",appversion];
                    [SVProgressHUD showSuccessWithStatus:info];
                }else{
                    NSString *info = [NSString stringWithFormat:@"Get OTA App Version faild"];
                    [SVProgressHUD showSuccessWithStatus:info];
                }
                
            }
        });
    }];
}

-(void)getFirmWarePatchVersion
{
    [SVProgressHUD show];
    [[ZHRealTekDataManager shareRealTekDataManager]getOTAPatchVersiononFinished:^(ZHRealTekDevice *device, NSError *error, id result){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }else{
                if (result) {
                    int patchversion = [result intValue];
                    NSString *info = [NSString stringWithFormat:@"Get OTA Patch Version Success %d",patchversion];
                    [SVProgressHUD showSuccessWithStatus:info];
                }else{
                    NSString *info = [NSString stringWithFormat:@"Get OTA Patch Version faild"];
                    [SVProgressHUD showSuccessWithStatus:info];
                }
                
            }
        });
    }];
    
}

-(void)getFirmWareMacAdress
{
    [SVProgressHUD show];
    [[ZHRealTekDataManager shareRealTekDataManager]getMacAddressonFinished:^(ZHRealTekDevice *device, NSError *error, id result){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }else{
                if (result) {
                    NSString *macAddress = result;
                    NSString *info = [NSString stringWithFormat:@"Get Mac Address Success %@",macAddress];
                    [SVProgressHUD showSuccessWithStatus:info];
                }else{
                    NSString *info = [NSString stringWithFormat:@"Get Mac Address faild"];
                    [SVProgressHUD showSuccessWithStatus:info];
                }
                
            }
        });
    }];
}

-(void)getSDKVersion
{
    NSString *version = [[ZHRealTekDataManager shareRealTekDataManager]iMCOSDKVersion];
    [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"SDK Verion:%@",version]];
}

-(void)checkFirmWareUpdate
{
    //[SVProgressHUD showInfoWithStatus:@"The feature is temporarily not implemented."];
    [SVProgressHUD show];
    NSString *userId = @"TestUser";
    [[ZHRealTekDataManager shareRealTekDataManager]checkFirmWareHaveNewVersionWithUserId:userId onFinished:^(ZHRealTekDevice *device, NSError *error, id result){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }else{
                NSInteger code = [result integerValue];
                if (code == ZH_Realtek_FirmWare_HaveNewVersion) {
                    [SVProgressHUD showInfoWithStatus:@"FirmWare Have New Version"];
                }else{
                    [SVProgressHUD showInfoWithStatus:@"FirmWare is New Version"];
                }
            }
        });
        
    }];
}


-(void)beginUpdateFirmWare
{
    [[ZHRealTekDataManager shareRealTekDataManager]updateFirmwareonFinished:^(ZHRealTekDevice *device, NSError *error,ZH_RealTek_FirmWare_Update_Status status, float progress){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == RealTek_FirmWare_Update_Failed) {
                if (error) {
                    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                }else{
                    [SVProgressHUD showErrorWithStatus:@"Update Failed"];
                }
            }else if (status == RealTek_FirmWare_Loading_OTA){
                [SVProgressHUD showProgress:progress status:@"Load OTA Data Progress"];
            }else if(status == RealTek_FirmWare_Updateing) {
                [SVProgressHUD showProgress:progress status:@"Transfer data Progress"];
            }else if (status == RealTek_FirmWare_Update_Finished){
                [SVProgressHUD showInfoWithStatus:@"Data transfer complete"];
            }else if (status == RealTek_FirmWare_Update_Restart){
                [SVProgressHUD showInfoWithStatus:@"Wait for the reboot"];
            }else if (status == RealTek_FirmWare_Update_Success){
                [SVProgressHUD showSuccessWithStatus:@"Update Success"];
            }
        });
    }];
}

#pragma mark - Get Alarms
-(NSArray *)getTestAlarms
{
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:date];
    NSInteger year = [dateComponent year];
    NSInteger month = [dateComponent month];
    NSInteger day = [dateComponent day];
    NSInteger hour = [dateComponent hour];
    NSInteger minute = [dateComponent minute];
    
    
    ZHRealTekAlarm *alarm1 = [[ZHRealTekAlarm alloc]init];
    alarm1.year =  year;
    alarm1.month = month;
    alarm1.day = day;
    alarm1.hour = hour;
    alarm1.minute = minute + 2;
    alarm1.index = 0;
    alarm1.dayFlags = 0;
    
    ZHRealTekAlarm *alarm2 = [[ZHRealTekAlarm alloc]init];
    alarm2.year =  year;
    alarm2.month = month;
    alarm2.day = day;
    alarm2.hour = hour;
    alarm2.minute = minute + 4;
    alarm2.index = 1;
    alarm2.dayFlags = 0;
    
    ZHRealTekAlarm *alarm3 = [[ZHRealTekAlarm alloc]init];
    alarm3.year =  year;
    alarm3.month = month;
    alarm3.day = day;
    alarm3.hour = hour;
    alarm3.minute = minute + 6;
    alarm3.index = 2;
    alarm3.dayFlags = 0;
    
    return @[alarm1,alarm2,alarm3];
}

#pragma mark - Private method
-(void)showHaveNotFunctionReminder
{
    [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"手环固件不支持该功能,请升级固件或者询问开发商", @"Hand ring firmware does not support this feature, please upgrade firmware or ask the developer")];
}


#pragma mark - Test Commands
-(void)enterOTAMode
{
    [SVProgressHUD show];
    [[ZHRealTekDataManager shareRealTekDataManager]enterOTAModeonFinished:^(ZHRealTekDevice *device, NSError *error, id result){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }else{
                [SVProgressHUD showSuccessWithStatus:@"Enter OTA Mode Success"];
            }
        });
    }];
}

-(void)gotoTestUpdateOTA
{
    ZHChooseFirmwareTableViewController *chooseFirmWare = [[ZHChooseFirmwareTableViewController alloc]initWithNibName:@"ZHChooseFirmwareTableViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:chooseFirmWare animated:YES];
}

-(void)sendMultipleCommands
{
    [self synTime];
    [self setAlarms];
    [self getAlarms];
    //[self setStepTarget];
    [self setUserProfile];
    [self getLongSitRemind];
    //[self setOS];
    [self getTurnWristLight];
    
}


-(void)handlerLogFile
{
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Log File", @"Log File") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", @"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        
    }];
    UIAlertAction *clearAllLogFileAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"清除所有Log文件", @"清除所有Log文件") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [SVProgressHUD show];
        [[ZHRealTekDataManager shareRealTekDataManager]clearAllLogFile];
        [SVProgressHUD showSuccessWithStatus:nil];
    }];
    
    UIAlertAction *clearTodayLogFile = [UIAlertAction actionWithTitle:NSLocalizedString(@"清除当天Log文件", @"清除当天Log文件") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [SVProgressHUD show];
        [[ZHRealTekDataManager shareRealTekDataManager]clearTodayLogFile];
        [SVProgressHUD showSuccessWithStatus:nil];
    }];
    
    [alertView addAction:cancelAction];
    [alertView addAction:clearAllLogFileAction];
    [alertView addAction:clearTodayLogFile];
    [self presentViewController:alertView animated:YES completion:nil];
    
}

-(void)handlerTestUser
{
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Test User", @"Test User") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", @"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        
    }];
    UIAlertAction *isTestUserAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"是否为内测用户", @"是否为内测用户") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [SVProgressHUD show];
        [[ZHRealTekDataManager shareRealTekDataManager]isTestUserOnFinished:^(NSError *error, BOOL isTestUser){
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }else{
                if (isTestUser) {
                    [SVProgressHUD showInfoWithStatus:@"User is test user!"];
                }else{
                    [SVProgressHUD showErrorWithStatus:@"User is not test user!"];
                }
            }
            
        }];
    }];
    
    UIAlertAction *enableAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"加入测试用户", @"加入测试用户") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [SVProgressHUD show];
        [[ZHRealTekDataManager shareRealTekDataManager]enableTesterOnFinished:^(NSError *error, BOOL success){
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }else{
                if (success) {
                    [SVProgressHUD showInfoWithStatus:@"join test user success!"];
                }else{
                    [SVProgressHUD showErrorWithStatus:@"join test user faild!"];
                }
            }
            
        }];
    }];
    UIAlertAction *disAbleAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"退出测试用户", @"退出测试用户") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [SVProgressHUD show];
        [[ZHRealTekDataManager shareRealTekDataManager]disableTesterOnFinished:^(NSError *error, BOOL success){
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }else{
                if (success) {
                    [SVProgressHUD showInfoWithStatus:@"Quit test user success!"];
                }else{
                    [SVProgressHUD showErrorWithStatus:@"Quit test user faild!"];
                }
            }
        }];
        
    }];
    
    [alertView addAction:cancelAction];
    [alertView addAction:enableAction];
    [alertView addAction:disAbleAction];
    [alertView addAction:isTestUserAction];
    [self presentViewController:alertView animated:YES completion:nil];
    
}


#pragma mark ZHBandSwitchPropertyProtocol
-(void)handleSWitchActionWithCell:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [self.showTableView indexPathForCell:cell];
    NSArray *keys = [self.commandkeys objectAtIndex:indexPath.section];
    ZHFunctionModel *functionModel = [keys objectAtIndex:indexPath.row];
    ZHTitleAndSwitchTableViewCell *switchCell = (ZHTitleAndSwitchTableViewCell *)cell;
    BOOL enAble = switchCell.switchView.on;
    switch (functionModel.functionMode) {
        case ZHSetSittingReminder:{// Long Sit Remind
            [self setLongSitRemind:enAble];
        }
            break;
        case ZHSetRaiseHandLight:{ // Set Turn Wrist Light
            [self turnWirstLight:enAble];
        }
            break;
        case ZHQQReminder:{ // Set QQ Notification
            [self setQQNotification:enAble];
        }
            break;
        case ZHWeChatReminder:{ // Set Wechat Notification
            [self setWechatNotification:enAble];
        }
            break;
        case ZHSMSReminder:{ // Set SMS Notification
            [self setSMSNotification:enAble];
        }
            break;
        case ZHLineReminder:{ // Set Line Notification
            [self setLineNotification:enAble];
        }
            break;
        case ZHIncomingReminder:{ // Set Call Notification
            [self setCallNotification:enAble];
        }
            break;
        case ZHGetRealTimeData:{// get realtime step data
            [self getRealTimeStepData:enAble];
        }
            break;
        case ZHContinuousHR:{ // Request the continuous heart rate data.
            [self getContinuousHeartRate:enAble];
        }
            break;
        case ZHSetScreenOrientation:{ // set screen orientation
            [self setScreenOrientation:enAble];
        }
            break;
        case ZHTestMultiReminder:{ // send multi reminder
            [self setMultiReminder:enAble];
        }
            break;
        case ZHTestContinuousReminder:{
            [self sendCMultiReminder:enAble];
        }
            break;
        case ZHBloodPressure:{
            [self setBloodPressueEnable:enAble];
        }
            break;
            
        default:
            break;
    }
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
