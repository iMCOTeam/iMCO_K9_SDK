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
#import <iMCO_RTSDK/iMCO_RTSDK.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface ZHDeviceListTableViewController (){
    
    
}

@end

@implementation ZHDeviceListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Devices";
    self.tableView.tableFooterView = [UIView new];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(clickRightItem:)];
    
    self.specialName = nil;
    self.minRssi = -1;
    self.devices = [NSMutableArray array];
    self.realTekManager = [ZHRealTekDataManager shareRealTekDataManager];
    typeof(self) __weak  weakSelf = self;
    self.realTekManager.disConnectionBlock = ^(ZHRealTekDevice *device, NSError *error){
        dispatch_async(dispatch_get_main_queue(), ^{
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
        }else if (state == CBManagerStatePoweredOn) {
            if (!weakSelf.realTekManager.isScanning) {
                [weakSelf startScan];
            }
        }
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
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"设备过滤", @"Equipment filter") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
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
    
    [alertView addAction:cancelAction];
    [alertView addAction:deviceFilterAction];
    [alertView addAction:rssiFilterAction];
    [alertView addAction:removeFilterAction];
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
            ZHDeviceModel *model = [[ZHDeviceModel alloc]init];
            model.deviceName = device.name;
            model.rssi = device.rssi;
            model.identifier = device.identifier;
            BOOL containBool = [self containDevice:model];
            if (!containBool) {
                [self.devices addObject:model];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
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
