//
//  ZHDeviceModel.h
//  iMCOBandRealTekSDK_iOS
//
//  Created by aimoke on 2017/5/24.
//  Copyright © 2017年 zhuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZHDeviceModel : NSObject
@property (nonatomic, strong) NSString *deviceName;
@property (nonatomic) NSInteger rssi; 
@property (nonatomic) NSString *identifier;

@end
