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
    NSTimer *timer;
}

@end

@implementation ZHDeviceListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Devices";
    self.tableView.tableFooterView = [UIView new];
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
                [weakSelf stopScan];
                [weakSelf.devices removeAllObjects];
                [weakSelf.tableView reloadData];
            });
        }/*else{
            if (weakSelf.devices.count == 0) {
                [weakSelf startScan];
            }
        }*/
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


#pragma mark - Scan
-(void)startScan
{
    
    if (self.devices.count > 0) {
        [self.devices removeAllObjects];
        [self.tableView reloadData];
    }
    
    [SVProgressHUD showWithStatus:@"Scaning..."];
    [self.realTekManager scanDevice:^(ZHRealTekDevice *device, NSDictionary *advertisementData){
        if (device) {
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
