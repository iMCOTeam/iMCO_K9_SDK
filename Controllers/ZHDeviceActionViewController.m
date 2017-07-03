//
//  ZHDeviceActionViewController.m
//  iMCOBandRealTekSDK_iOS
//
//  Created by aimoke on 2017/5/24.
//  Copyright © 2017年 zhuo. All rights reserved.
//

#import "ZHDeviceActionViewController.h"
#import "ZHCommandTableViewCell.h"
#import <iMCO_RTSDK/iMCO_RTSDK.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <KVNProgress/KVNProgress.h>

#define DeviceActionCellIdentifier @"DeviceActionCellIdentifier"

#define TestUserIdentifier @"a_test_user"

@interface ZHDeviceActionViewController ()
@property (nonatomic, strong) ZHRealTekSportItem *currentSportItem;
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
    
    
    //Commands
    self.commands =@[@"绑定命令",@"设置命令",@"运动数据命令",@"辅助命令",@"固件升级命令", @"测试命令"];
    
    //keys
    self.commandkeys = [NSMutableArray array];
    [self.commandkeys addObject:[self getBindCommandKeys]];
    [self.commandkeys addObject:[self getSetCommandKeys]];
    [self.commandkeys addObject:[self getSportCommandKeys]];
    [self.commandkeys addObject:[self getAssistCommandKeys]];
    [self.commandkeys addObject:[self getOTACommandKeys]];
    //[self.commandkeys addObject:[self getTestCommandKeys]];
    
    

    [ZHRealTekDataManager shareRealTekDataManager].sportDataUpdateBlock = ^(ZHRealTekDevice *device, NSError *error, id result){
        dispatch_async(dispatch_get_main_queue(), ^{
            self.currentSportItem = result;
            [self.showTableView reloadData];

        });
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
    
    [ZHRealTekDataManager shareRealTekDataManager].heartRateDataUpdateBlock = ^(ZHRealTekDevice *device, NSError *error, id result){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error && result) {
                NSArray *array = result;
                NSInteger num = array.count;
                NSString *info = [NSString stringWithFormat:@"Receive heart rate numers %ld",(long)num];
                if (array.count == 1) {
                    ZHRealTekHRItem *item = array.firstObject;
                    NSString *time = item.time;
                    info = [NSString stringWithFormat:@"Receive heart rate: %ld-time:%@",(long)item.heartRate,time];
                }
                [SVProgressHUD showInfoWithStatus:info];
            }
        });

    };

    // Do any additional setup after loading the view from its nib.
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    ZHRealTekDataManager *manager = [ZHRealTekDataManager shareRealTekDataManager];
    if (manager.connectedDevice) {
        [manager cancelPeripheralConnection:manager.connectedDevice onFinished:^(ZHRealTekDevice *device, NSError *error){
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                });
            }
        }];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Get Command Keys

-(NSArray *)getBindCommandKeys
{
    return @[@"登录",@"绑定用户",@"解除绑定",@"断开连接"];
}

-(NSArray *)getSetCommandKeys
{
    return @[@"时间设置",@"闹钟设置",@"获取闹钟列表请求",@"计步目标设定",@"用户Profile设置",@"防丢设置",@"久坐提醒",@"获取久坐提醒",@"手机操作系统设置",@"进入拍照模式",@"退出拍照模式",@"开启抬手亮屏",@"获取抬手亮屏开关",@"开启QQ提醒",@"开启微信提醒",@"开启短信提醒",@"开启Line提醒"];
}

-(NSArray *)getSportCommandKeys
{
    return @[@"请求历史数据",@"请求实时计步数据",@"请求一次心率数据",@"请求连续的心率数据",@"获取连续心率设置是否开启",@"当天数据同步",@"最近数据同步"];
}

-(NSArray *)getAssistCommandKeys
{
    return @[@"找到我的手环",@"修改设备名称",@"获取设备名称",@"获取电量等级",@"获取固件App版本",@"获取固件Patch版本",@"获取固件Mac地址"];
}

-(NSArray *)getOTACommandKeys
{
    return @[@"检测固件是否有更新",@"开始固件升级"];
}

-(NSArray *)getTestCommandKeys
{
    return @[@"马达震动",@"获取升级固件信息"];
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
    NSString *keyString = [keys objectAtIndex:indexPath.row];
    ZHCommandTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DeviceActionCellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = keyString;
    cell.detailTextLabel.text = nil;
    if (indexPath.section == 2 && indexPath.row == 1) {
        if (self.currentSportItem) {
            NSString *detail = [NSString stringWithFormat:@"Time:%@-StepCount:%ld-Calories:%ld-Distance:%ld",self.currentSportItem.date,(long)self.currentSportItem.stepCount,(long)self.currentSportItem.calories,(long)self.currentSportItem.distance];
            cell.detailTextLabel.text = detail;

        }
        
    }
    return cell;
}


#pragma mark - TableView delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    switch (indexPath.row) {
        case 0:{
            [self loginWithIdentifier:TestUserIdentifier];
        }
            break;
        case 1:{ //Bind device
            [self bindDeviceWithIdentifier:TestUserIdentifier];
            
        }
            break;
            
        case 2:{//Unbind device
            [self unBind];
        }
            break;
        
        case 3:{// Cancel connect
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
    switch (indexPath.row) {
        case 0:{ //Syn Time
            [self synTime];
        }
            break;
            
        case 1:{ // Set Alarms
            [self setAlarms];
        }
            break;
            
        case 2:{// get Alarms
            [self getAlarms];
        }
            break;
            
        case 3:{// Set Step Target
            [self setStepTarget];
        }
            break;
        case 4:{// set user profile
            [self setUserProfile];
        }
            break;
        case 5:{// Loss Alert set
            [self setLossLevel];
        }
            break;
        case 6:{// Long Sit Remind
            [self setLongSitRemind];
        }
            break;
        case 7:{// Get Long Sit Remind Data
            [self getLongSitRemind];
        }
            break;
        case 8:{// Set OS
            [self setOS];
        }
            break;
        case 9:{ //  enter camera mode
            [self enterCameraMode];
        }
            break;
        case 10:{ // quit camera mode
            [self quitCameraMode];
        }
            break;
        case 11:{ // Set Turn Wrist Light
            [self turnWirstLight];
        }
            break;
        case 12:{ // Get Turn Wrist Light
            [self getTurnWristLight];
        }
            break;
        case 13:{ // Set QQ Notification
            [self setQQNotification];
        }
            break;
        case 14:{ // Set Wechat Notification
            [self setWechatNotification];
        }
            break;
        case 15:{ // Set SMS Notification
            [self setSMSNotification];
        }
            break;
        case 16:{ // Set Line Notification
            [self setLineNotification];
        }
            break;
       
        default:
            break;
    }
}



//Sport Command
-(void)sendSportCmmandWithIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:{ // get his data
            [self getHisData];
        }
            break;
        case 1:{// get realtime step data
            [self getRealTimeStepData:indexPath];
        }
            break;
        case 2:{ // enable to obtain a heart rate data
            [self getOneceHeartRate];
        }
            break;
        case 3:{ // Request the continuous heart rate data.
            [self getContinuousHeartRate];
        }
            break;
        case 4:{ // Gets whether to open continuous measurement of heart rate function.
            [self getContinuousHeartRateSetting];
        }
            break;
        case 5:{ // Syn Today Data
            [self synTodayData];
        }
            break;
        case 6:{ // Syn Recent Data
            [self synRecentData];
        }
            break;
        default:
            break;
    }
}



#pragma mark assist Command
-(void)sendAssistCommandWithIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:{// find me
            [self findDevice];
        }
            break;
        case 1: { // modify device name
            [self modifyName];
        }
            break;
        case 2:{// get device name
            [self getdeviceName];
        }
            break;
        case 3:{ // get battery level
            [self getBatteryLevel];
        }
            break;
        case 4:{ // get FirmWare app version
            [self getFirmWareAppVersion];
        }
            break;
        case 5:{ // get FirmWare patch version
            [self getFirmWarePatchVersion];
        }
            break;
        case 6:{ // get FirmWare MacAdress
            [self getFirmWareMacAdress];
        }
            break;
        default:
            break;
    }
}


#pragma mark - OTA Command
-(void)sendFirmwareCommandWithIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:{ // Check to see if the firmware needs to be updated.
            [self checkFirmWareUpdate];
        }
            break;
        case 1:{ // Begin firmWare Update
            [self beginUpdateFirmWare];
        }
            break;
        case 2:{ // Test Enter OTA Mode
            [self enterOTAMode];
        }
            break;
            
            
        default:
            break;
    }
}

#pragma mark Test Command
-(void)sendTestCommandWithIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:{//震动
            [[ZHRealTekDataManager shareRealTekDataManager]sendShakeCommandonFinished:^(ZHRealTekDevice *device, NSError *error, id result){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error) {
                        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                    }else{
                        [SVProgressHUD showInfoWithStatus:@"Shake Cmd send success"];
                    }
                });
               
            }];
        }
            break;
        case 1:{// 获取固件信息
            return;
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
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [SVProgressHUD showSuccessWithStatus:@"Unbind success"];
            }
        });
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
    NSString *name = @"Zhuo";
    [SVProgressHUD show];
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
    [SVProgressHUD show];
    uint32_t stepTarget = 10000;
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

-(void)setUserProfile
{
    ZH_RealTek_Gender gender = 1;
    uint8_t age = 18;
    float height = 170;
    float weight = 40;
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



-(void)setLongSitRemind
{
    ZHRealTekLongSit *sit = [[ZHRealTekLongSit alloc]init];
    sit.onEnable = YES;
    sit.sitTime = 10;
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


-(void)turnWirstLight
{
    [SVProgressHUD show];
    BOOL enable = YES;
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

-(void)setQQNotification
{
    [SVProgressHUD show];
    BOOL enable = YES;
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

-(void)setWechatNotification
{
    [SVProgressHUD show];
    BOOL enable = YES;
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

-(void)setSMSNotification
{
    [SVProgressHUD show];
    BOOL enable = YES;
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

-(void)setLineNotification
{
    [SVProgressHUD show];
    BOOL enable = YES;
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
                    NSArray *sports = [result objectForKey:ZH_RealTek_HisSportsKey];
                    NSArray *sleeps = [result objectForKey:ZH_RealTek_HisSleepsKey];
                    NSString *info = [NSString stringWithFormat:@"Get His Data Success,sports count:%ld,sleeps count:%ld",(long)sports.count,(long)sleeps.count];
                    [SVProgressHUD showSuccessWithStatus:info];
                }else{
                     [SVProgressHUD showSuccessWithStatus:@"Get His Data failed"];
                }
                
            }
        });

    }];
}


-(void)synTodayData
{
    [SVProgressHUD show];
    [[ZHRealTekDataManager shareRealTekDataManager]synTodayDataOnFinished:^(ZHRealTekDevice *device, NSError *error, id result)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             if (error) {
                 [SVProgressHUD showErrorWithStatus:error.localizedDescription];
             }else{
                 if (result) {
                     NSArray *sports = [result objectForKey:ZH_RealTek_HisSportsKey];
                     NSArray *sleeps = [result objectForKey:ZH_RealTek_HisSleepsKey];
                     NSString *info = [NSString stringWithFormat:@"Get Today Data Success,sports count:%ld,sleeps count:%ld",(long)sports.count,(long)sleeps.count];
                     [SVProgressHUD showSuccessWithStatus:info];
                 }else{
                     [SVProgressHUD showSuccessWithStatus:@"Get Today Data failed"];
                 }
                 
             }
         });
         
     }];

}


-(void)synRecentData
{
    [SVProgressHUD show];
    [[ZHRealTekDataManager shareRealTekDataManager]synRecentDataOnFinished:^(ZHRealTekDevice *device, NSError *error, id result)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             if (error) {
                 [SVProgressHUD showErrorWithStatus:error.localizedDescription];
             }else{
                 if (result) {
                     NSArray *sports = [result objectForKey:ZH_RealTek_HisSportsKey];
                     NSArray *sleeps = [result objectForKey:ZH_RealTek_HisSleepsKey];
                     NSString *info = [NSString stringWithFormat:@"Get Recent Data Success,sports count:%ld,sleeps count:%ld",(long)sports.count,(long)sleeps.count];
                     [SVProgressHUD showSuccessWithStatus:info];
                 }else{
                     [SVProgressHUD showSuccessWithStatus:@"Get Recent Data failed"];
                 }
                 
             }
         });
         
     }];

}

-(void)getRealTimeStepData:(NSIndexPath *)indexPath
{
    BOOL onOff = YES;
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


-(void)getContinuousHeartRate
{
    [SVProgressHUD show];
    BOOL enable = YES;
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

-(void)checkFirmWareUpdate
{
    [SVProgressHUD showInfoWithStatus:@"The feature is temporarily not implemented."];
}

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

-(void)beginUpdateFirmWare
{
    [[ZHRealTekDataManager shareRealTekDataManager]updateFirmwareonFinished:^(ZHRealTekDevice *device, NSError *error,ZH_RealTek_FirmWare_Update_Status status, float progress){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == RealTek_FirmWare_Update_Failed) {
                if (error) {
                    [KVNProgress showErrorWithStatus:error.localizedDescription];
                }else{
                    [KVNProgress showErrorWithStatus:@"Update Failed"];
                }
            }else if(status == RealTek_FirmWare_Updateing) {
                [KVNProgress showProgress:progress status:@"Transfer data Progress"];
            }else if (status == RealTek_FirmWare_Update_Finished){
                [KVNProgress showWithStatus:@"Data transfer complete"];
            }else if (status == RealTek_FirmWare_Update_Restart){
                [KVNProgress showWithStatus:@"Wait for the reboot"];
            }else if (status == RealTek_FirmWare_Update_Success){
                [KVNProgress showSuccessWithStatus:@"Update Success"];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
