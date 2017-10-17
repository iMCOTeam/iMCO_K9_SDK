//
//  ZHDeviceListTableViewController.m
//  iMCOBandRealTekSDK_iOS
//
//  Created by aimoke on 2017/5/24.
//  Copyright © 2017年 zhuo. All rights reserved.
//

#import "ZHDeviceListTableViewController.h"
#import "ZHDeviceModel.h"
#import "ZHDeviceTableViewCell.h"
#import "ZHDeviceActionViewController.h"
#import <iMCOK9SDK/iMCOK9SDK.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface ZHDeviceListTableViewController (){
    
    NSMutableArray *isNewFirmwareDevices; // 已经是最新固件不需要升级
    NSMutableArray *updateFaildDevices; // 升级失败的设备
    ZHRealTekDevice *updatingDevice;//正在升级中的设备
}
@property(nonatomic)  BOOL isUpdating; // 是否正在升级中

@end

@implementation ZHDeviceListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Devices";
    self.tableView.tableFooterView = [UIView new];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(clickRightItem:)];
    _isUpdating = NO;
    isNewFirmwareDevices = [NSMutableArray array];
    updateFaildDevices = [NSMutableArray array];
    self.autoUpdateBool = NO;
    self.specialName = nil;
    self.minRssi = -1;
    self.devices = [NSMutableArray array];
    self.realTekManager = [ZHRealTekDataManager shareRealTekDataManager];
    self.realTekManager.autoDloadFWData = YES;
    typeof(self) __weak  weakSelf = self;
    
    self.realTekManager.disConnectionBlock = ^(ZHRealTekDevice *device, NSError *error){
        dispatch_async(dispatch_get_main_queue(), ^{
            _isUpdating = NO;
            [weakSelf.devices removeAllObjects];
            [weakSelf.tableView reloadData];
            if (![weakSelf.navigationController.topViewController isKindOfClass:[weakSelf class]]) {
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
            }
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }
            
        });
    };
    
    self.realTekManager.blueToothStateUpdateBlock = ^(CBManagerState state){
        if (state != CBManagerStatePoweredOn) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.devices removeAllObjects];
                [weakSelf.tableView reloadData];
            });
        }
        if (state == CBManagerStatePoweredOff){
            [SVProgressHUD showInfoWithStatus:@"Bluetooth is off"];
            _isUpdating = NO;
        }else if (state == CBManagerStatePoweredOn) {
            if (!weakSelf.realTekManager.isScanning) {
                [weakSelf startScan];
            }
        }
    };
    
    
    self.realTekManager.functionsHaveUpdated = ^(ZHRealTekDevice *device, NSError *error){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }else{
                NSString *info = @"The device contains ";
                if (device.hasStepFunc) {
                    info = [info stringByAppendingString:@"Step,"];
                }
                if (device.hasHRMFunc) {
                    info = [info stringByAppendingString:@"Heart,"];
                }
                if (device.hasSleepFunc) {
                    info = [info stringByAppendingString:@"Sleep,"];
                }
                if (device.hasBloodPressureFunc) {
                    info = [info stringByAppendingString:@"Blood pressure,"];
                }
                if (device.hasOrientationSwitchFunc) {
                    info = [info stringByAppendingString:@"Orientation Switch,"];
                }
                info = [info stringByAppendingString:@"functions"];
                if (!weakSelf.isUpdating) {
                    [SVProgressHUD showInfoWithStatus:info];
                }
            }
            
        });
        
    };
    
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopScan];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self startScan];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Interaction
-(void)clickRightItem:(id)sender
{
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"更多选项", @"More options") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", @"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        
    }];
    UIAlertAction *deviceFilterAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"设备名称过滤", @"Device name filtering") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self deviceFilterAction];
        [alertView dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *rssiFilterAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"信号强度过滤", @"Signal strength filtration") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self rssiFilterAction];
        [alertView dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *removeFilterAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"清除过滤", @"Removal filter") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
        self.specialName = nil;
        self.minRssi = -1;
        [alertView dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIAlertAction *autoUpdateAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"开始搜索自动升级", @"Start Search Auto Upgrade") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
        [self startAutoUpdateAction];
        [alertView dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *stopUpdateAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"停止自动升级", @"Stop Auto Upgrade") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
        
        [alertView dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alertView addAction:cancelAction];
    [alertView addAction:deviceFilterAction];
    [alertView addAction:rssiFilterAction];
    [alertView addAction:removeFilterAction];
    [alertView addAction:autoUpdateAction];
    [alertView addAction:stopUpdateAction];
    [self presentViewController:alertView animated:YES completion:nil];
}


-(void)deviceFilterAction
{
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Band Name", @"Band Name") message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertView addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = @"Name";
        
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", @"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", @"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
        UITextField *nameTextField = [alertView.textFields firstObject];
        NSString *name = nameTextField.text;
        self.specialName = name;
        [self.devices removeAllObjects];
        [self.tableView reloadData];
    }];
    [alertView addAction:cancelAction];
    [alertView addAction:okAction];
    [self presentViewController:alertView animated:YES completion:nil];
    
}



-(void)rssiFilterAction
{
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Min RSSI", @"Min RSSI") message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertView addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = @"RSSI";
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", @"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", @"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
        UITextField *nameTextField = [alertView.textFields firstObject];
        NSString *name = nameTextField.text;
        self.minRssi = labs(name.integerValue);
        [self.devices removeAllObjects];
        [self.tableView reloadData];
    }];
    [alertView addAction:cancelAction];
    [alertView addAction:okAction];
    [self presentViewController:alertView animated:YES completion:nil];
    
}


#pragma mark - Scan
-(void)startScan
{
    if (self.devices.count > 0) {
        [self.devices removeAllObjects];
        [self.tableView reloadData];
    }
    [SVProgressHUD showWithStatus:@"Scaning..."];
    [self.realTekManager scanDevice:^(ZHRealTekDevice *device, NSDictionary *advertisementData){
        NSInteger rssi = labs(device.rssi);
        if (device) {
            if (self.minRssi>=0) {
                if (rssi > self.minRssi) {
                    return ;
                }
            }
            if (self.specialName) {
                if (![device.name.lowercaseString containsString:self.specialName.lowercaseString]) {
                    return;
                }
            }
            [self updateDevice:device];
            NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
            ZHDeviceModel *model = [[ZHDeviceModel alloc]init];
            model.deviceName = localName?localName:device.name;
            model.rssi = device.rssi;
            model.identifier = device.identifier;
            BOOL containBool = [self containDevice:model];
            if (!containBool) {
                [self.devices addObject:model];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!_isUpdating) {//这里为了防止升级是刷新界面导致进度条闪现
                    [SVProgressHUD dismiss];
                }
                [self.tableView reloadData];
                
            });
        }else{
            [SVProgressHUD dismiss];
        }
        
    }];
}


-(void)stopScan
{
    [self.realTekManager stopScan];
}


#pragma mark - Private Methods
-(BOOL)containDevice:(ZHDeviceModel *)device
{
    __block BOOL containBool = NO;
    [self.devices enumerateObjectsUsingBlock:^(ZHDeviceModel *model,NSUInteger index, BOOL *stop){
        if ([model.identifier isEqualToString:device.identifier]) {
            model.rssi = device.rssi;
            model.deviceName = device.deviceName;
            containBool = YES;
            *stop = YES;
        }
    }];
    
    return containBool;
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.devices.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZHDeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"deviceListCellIDentifier" forIndexPath:indexPath];
    ZHDeviceModel *model = [self.devices objectAtIndex:indexPath.row];
    cell.textLabel.text = model.deviceName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld",(long)model.rssi];
    // Configure the cell...
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZHDeviceModel *model = [self.devices objectAtIndex:indexPath.row];
    
    ZHRealTekDevice *device = [[ZHRealTekDevice alloc]init];
    device.identifier = model.identifier;
    [SVProgressHUD showWithStatus:@"Connecting..."];
    [self.realTekManager connectPeripheral:device options:nil onFinished:^(ZHRealTekDevice *peripheral, NSError *error){
        [self stopScan];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            ZHDeviceActionViewController *actionVC = [[ZHDeviceActionViewController alloc]initWithNibName:@"ZHDeviceActionViewController" bundle:[NSBundle mainBundle]];
            actionVC.device = device;
            [self.navigationController pushViewController:actionVC animated:YES];
        });
    }];
    
}


#pragma mark - Auto Update Methods
-(void)startAutoUpdateAction
{
    [updateFaildDevices removeAllObjects];
    self.autoUpdateBool = YES;
}


-(void)stopAutoUpdateAction
{
    self.autoUpdateBool = NO;
    _isUpdating = NO;
}

-(void)updateDevice:(ZHRealTekDevice *)deviceModel
{
    typeof(self) __weak  weakSelf = self;
    BOOL isValid = [self isValidDevice:deviceModel];
    if (self.autoUpdateBool && !_isUpdating && isValid) {
        _isUpdating = YES;
        
        [self connectPeripheral:deviceModel options:nil onFinished:^(ZHRealTekDevice *device, NSError *error){
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error) {
                    [weakSelf checkAndUpdateFunction:device];
                }else{
                    _isUpdating = NO;
                    if (device) {
                        [updateFaildDevices addObject:device];
                    }
                    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                }
            });
        }];
    }
}

-(void)connectPeripheral:(ZHRealTekDevice *)device options:(NSDictionary *)options onFinished:(ZHRealTekConnectionBlock)finished
{
    
    NSString *objectId = @"AutoUpdateObject";
    //typeof(self) __weak weakSelf = self;
    [SVProgressHUD showWithStatus:@"Start Auto Connecting"];
    ZHRealTekDataManager *manager = [ZHRealTekDataManager shareRealTekDataManager];
    [manager connectPeripheral:device options:options onFinished:^(ZHRealTekDevice *reDevice ,NSError *error){
        if (error) {
            if (finished) {
                finished(reDevice,error);
            }
        }else{
            // code to be executed on the main queue after delay
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showWithStatus:@"Start Auto Bind"];
            });
            
            [manager loginDeviceWithIdentifier:objectId onFinished:^(ZHRealTekDevice *loginDevice, NSError *loginError,id result){
                if (loginError) {
                    [manager cancelPeripheralConnection:device onFinished:nil];
                    if (finished) {
                        finished(loginDevice,loginError);
                    }
                }else{
                    ZH_RealTek_Login_Status status = [result intValue];
                    if (status == RealTek_Login_Success) {
                        if (finished) {
                            finished(loginDevice,nil);
                        }
                    }else{
                        [manager bindDeviceWithIdentifier:objectId onFinished:^(ZHRealTekDevice *bindDevice, NSError *bindError, id result){
                            if (error) {
                                [manager cancelPeripheralConnection:bindDevice onFinished:nil];
                                if (finished) {
                                    finished(bindDevice,bindError);
                                }
                            }else{
                                ZH_RealTek_Bind_Status status = [result intValue];
                                if (status == RealTek_Bind_Success) {
                                    if (finished) {
                                        finished(bindDevice,nil);
                                    }
                                }else{
                                    [manager cancelPeripheralConnection:bindDevice onFinished:nil];
                                    if (finished) {
                                        NSError *bindError = [self getBindFaildError];
                                        finished(bindDevice,bindError);
                                    }
                                    
                                }
                            }
                        }];
                    }
                }
            }];
        }
    }];
}


-(BOOL)isValidDevice:(ZHRealTekDevice *)device
{
    __block BOOL containBool = NO;
    [isNewFirmwareDevices enumerateObjectsUsingBlock:^(ZHRealTekDevice *model,NSUInteger index, BOOL *stop){
        if ([model.identifier isEqualToString:device.identifier]) {
            model.rssi = device.rssi;
            containBool = YES;
            *stop = YES;
        }
    }];
    
    [updateFaildDevices enumerateObjectsUsingBlock:^(ZHRealTekDevice *model,NSUInteger index, BOOL *stop){
        if ([model.identifier isEqualToString:device.identifier]) {
            model.rssi = device.rssi;
            containBool = YES;
            *stop = YES;
        }
    }];
    
    return !containBool;
}

-(void)checkAndUpdateFunction:(ZHRealTekDevice *)tdevice
{
    typeof(self) __weak  weakSelf = self;
    NSString *userId = @"ScanAutoUpdateFunction";
    [[ZHRealTekDataManager shareRealTekDataManager]checkFirmWareHaveNewVersionWithUserId:userId onFinished:^(ZHRealTekDevice *device, NSError *error, id result){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                NSLog(@"error:%@",error.localizedDescription);
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                _isUpdating = NO;
            }else{
                NSInteger code = [result integerValue];
                if (code == ZH_Realtek_FirmWare_HaveNewVersion) {
                    //[SVProgressHUD showInfoWithStatus:@"FirmWare Have New Version"];
                    [weakSelf startUpdateFirmware:device];
                }else{
                    [SVProgressHUD showInfoWithStatus:@"FirmWare is New Version"];
                    [[ZHRealTekDataManager shareRealTekDataManager]unBindDeviceonFinished:^(ZHRealTekDevice *ttDevice, NSError *error, id result){
                        if (!error) {
                            if (ttDevice) {
                                [isNewFirmwareDevices addObject:device];
                            }
                            
                        }
                    }];
                    _isUpdating = NO;
                }
            }
        });
    }];
}

-(void)startUpdateFirmware:(ZHRealTekDevice *)tdevice
{
    [self performSelector:@selector(autoUpdateTimeOut:) withObject:tdevice afterDelay:10*60];//超时处理
    updatingDevice = tdevice;
    [[ZHRealTekDataManager shareRealTekDataManager]updateFirmwareonFinished:^(ZHRealTekDevice *device, NSError *error,ZH_RealTek_FirmWare_Update_Status status, float progress){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == RealTek_FirmWare_Update_Failed) {
                if (device) {
                    [updateFaildDevices addObject:tdevice];
                }
                
                _isUpdating = NO;
                if(error) {
                    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                }else{
                    [SVProgressHUD showErrorWithStatus:@"Update Failed"];
                }
            }else if (status == RealTek_FirmWare_Loading_OTA){
                [SVProgressHUD showProgress:progress status:@"Load OTA Data Progress"];
            }else if(status == RealTek_FirmWare_Updateing) {
                NSString *string = [NSString stringWithFormat:@"Transfer data Progress with Device %@",device.name];
                [SVProgressHUD showProgress:progress status:string];
            }else if (status == RealTek_FirmWare_Update_Finished){
                [SVProgressHUD showInfoWithStatus:@"Data transfer complete"];
            }else if (status == RealTek_FirmWare_Update_Restart){
                [SVProgressHUD showInfoWithStatus:@"Wait for the reboot"];
            }else if (status == RealTek_FirmWare_Update_Success){
                if (device) {
                    [isNewFirmwareDevices addObject:device];
                }
                
                _isUpdating = NO;
                [SVProgressHUD showSuccessWithStatus:@"Update Success"];
            }
        });
    }];
}


-(void)autoUpdateTimeOut:(ZHRealTekDevice *)device
{
    __block BOOL containBool = NO;
    [isNewFirmwareDevices enumerateObjectsUsingBlock:^(ZHRealTekDevice *model,NSUInteger index, BOOL *stop){
        if ([model.identifier isEqualToString:device.identifier]) {
            model.rssi = device.rssi;
            containBool = YES;
            *stop = YES;
        }
    }];
    
    [updateFaildDevices enumerateObjectsUsingBlock:^(ZHRealTekDevice *model,NSUInteger index, BOOL *stop){
        if ([model.identifier isEqualToString:device.identifier]) {
            model.rssi = device.rssi;
            containBool = YES;
            *stop = YES;
        }
    }];
    if (!containBool) {
        if (device) {
            [updateFaildDevices addObject:device];
        }
        _isUpdating = NO;
    }
}

#pragma mark - Error
-(NSError *)getBindFaildError
{
    NSDictionary *dic = @{NSLocalizedDescriptionKey:@"Bound to fail, please unbundling or try again."};
    NSError *error = [NSError errorWithDomain:@"Bind faild" code:ZHBindErrorCode userInfo:dic];
    return error;
    
}

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

