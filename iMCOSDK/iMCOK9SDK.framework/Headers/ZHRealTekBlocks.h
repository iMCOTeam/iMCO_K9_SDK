//
//  ZHRealTekBlocks.h
//  iMCOBandRealTekSDK_iOS
//
//  Created by aimoke on 2017/5/25.
//  Copyright © 2017年 zhuo. All rights reserved.
//

#import "ZHRealTekModels.h"

typedef void (^ZHRealTekDeviceUpdateBlock)(ZHRealTekDevice *device, NSDictionary *advertisementData);
typedef void (^ZHRealTekConnectionBlock)(ZHRealTekDevice *device, NSError*error);
typedef void (^ZHRealTekDisConnectionBlock)(ZHRealTekDevice *device, NSError*error);
typedef void (^ZHRealTekSendCommandBlock)(ZHRealTekDevice *device, NSError*error,id result);
typedef void (^ZHRealTekSportDataUpdateBlock)(ZHRealTekDevice *device, NSError*error,id result);
typedef void (^ZHRealTekCameraUpdateBlock)(ZHRealTekDevice *device, NSError *error);
typedef void (^ZHRealTekUpdateFirmwareProgressBlock)(ZHRealTekDevice *device, NSError *error, ZH_RealTek_FirmWare_Update_Status status,float progress);
typedef void (^ZHRealTekBlueToothStateDidUpdatedBlock)(CBManagerState state);
typedef void (^ZHRealTekHaveFindWriteCharacteristic)(ZHRealTekDevice *device, CBCharacteristic *writeCharacteristic);
