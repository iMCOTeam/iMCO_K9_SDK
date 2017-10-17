//
//  ZHDeviceListTableViewController.h
//  iMCOBandRealTekSDK_iOS
//
//  Created by aimoke on 2017/5/24.
//  Copyright © 2017年 zhuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iMCOK9SDK/iMCOK9SDK.h>



@interface ZHDeviceListTableViewController : UITableViewController
@property(nonatomic, strong) NSMutableArray *devices;
@property(nonatomic, strong) ZHRealTekDataManager *realTekManager;
@property(nonatomic, strong) NSString *specialName;//用来过滤设备名称
@property(nonatomic) NSInteger minRssi;//用来过滤信号强度
@property(nonatomic) BOOL autoUpdateBool; // 标识是否自动升级
@end
