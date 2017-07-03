//
//  ZHDeviceActionViewController.h
//  iMCOBandRealTekSDK_iOS
//
//  Created by aimoke on 2017/5/24.
//  Copyright © 2017年 zhuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iMCO_RTSDK/iMCO_RTSDK.h>


@interface ZHDeviceActionViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) ZHRealTekDevice *device;
@property (weak, nonatomic) IBOutlet UITableView *showTableView;
@property (nonatomic, strong) NSArray *commands;
@property (nonatomic, strong) NSMutableArray *commandkeys;

@end
