//
//  ZHFunctionModel.m
//  iMCOBandRealTekSDK_iOS
//
//  Created by aimoke on 2017/7/17.
//  Copyright © 2017年 zhuo. All rights reserved.
//

#import "ZHFunctionModel.h"

@implementation ZHFunctionModel
-(instancetype)initWithTitle:(NSString *)title cellMode:(ZHFunctionCellMode)cellMode functionMode:(ZHFunctionMode)functionMode
{
    self = [super init];
    if (self) {
        self.title = title;
        self.cellMode = cellMode;
        self.functionMode = functionMode;
    }
    return self;
}


@end
