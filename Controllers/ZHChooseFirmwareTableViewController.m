//
//  ZHChooseFirmwareTableViewController.m
//  iMCOBandRealTekSDK_iOS
//
//  Created by aimoke on 2017/7/18.
//  Copyright © 2017年 zhuo. All rights reserved.
//

#import "ZHChooseFirmwareTableViewController.h"
#import <iMCO_RTSDK/iMCO_RTSDK.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface ZHChooseFirmwareTableViewController ()

@end

@implementation ZHChooseFirmwareTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Choose Firmware to Update";
    self.tableView.tableFooterView = [UIView new];
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor grayColor];
    [self.refreshControl addTarget:self action:@selector(loadNetData) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    [self loadNetData];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Load Data
-(void)loadNetData
{
    if (!self.refreshControl.refreshing) {
        [self.refreshControl beginRefreshing];
    }
    ZHRealTekDataManager *manager = [ZHRealTekDataManager shareRealTekDataManager];
    __block NSString *serial = nil;
    [manager getMacAddressonFinished:^(ZHRealTekDevice *device, NSError *error, id result){
        if (error || !result) {
            [self.refreshControl endRefreshing];
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }else{
            serial = result;
            [self loadAllFirmWareData];
        }
    }];
}



-(void)loadAllFirmWareData
{
    [[ZHRealTekDataManager shareRealTekDataManager]checkAllOTADataOnFinished:^(NSError *error, NSData *data){
        
        [self.tableView.refreshControl endRefreshing];
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }else{
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:nil];
            if (dic) {
                NSInteger code = [[dic objectForKey:@"code"]integerValue];
                if (code == 0) {
                    self.items = [dic objectForKey:@"payload"];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                    });
                    
                }else{
                    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Error Code:%ld",(long)code]];
                }
                
            }else{
                [SVProgressHUD showInfoWithStatus:@"固件列表为空"];
            }
        }
        
    }];
    
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.items?1:0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.items?self.items.count:0;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChooseFirmwareCellIdentifier"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ChooseFirmwareCellIdentifier"];
    }
    NSDictionary *dic = [self.items objectAtIndex:indexPath.row];
    NSString *fwType = [dic objectForKey:@"fwType"];
    NSString *version = [dic objectForKey:@"version"];
    cell.textLabel.text = [NSString stringWithFormat:@"firmwareType:%@",fwType];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"version:%@",version];
    
    // Configure the cell...
    
    return cell;
}




#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = [self.items objectAtIndex:indexPath.row];
    NSString *resourceURL = [dic objectForKey:@"resourceUrl"];
    NSString *md5 = [dic objectForKey:@"md5sum"];
    NSString *version = [dic objectForKey:@"version"];
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"升级固件", @"Update Firmware") message:version preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", @"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", @"OK") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
        
        [[ZHRealTekDataManager shareRealTekDataManager]updateFirmware:resourceURL withMD5:md5 onFinished:^(ZHRealTekDevice *device, NSError *error,ZH_RealTek_FirmWare_Update_Status status, float progress){
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
        
    }];
    [alertView addAction:cancelAction];
    [alertView addAction:okAction];
    [self presentViewController:alertView animated:YES completion:nil];
    
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
