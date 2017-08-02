//
//  ZHTitleAndSwitchTableViewCell.h
//  iMCOBandRealTekSDK_iOS
//
//  Created by aimoke on 2017/7/17.
//  Copyright © 2017年 zhuo. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ZHBandSwitchPropertyProtocol <NSObject>
- (void)handleSWitchActionWithCell:(UITableViewCell *)cell;
@end

@interface ZHTitleAndSwitchTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UISwitch *switchView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, assign) id<ZHBandSwitchPropertyProtocol> delegate;
- (IBAction)switchValueHaveChanged:(id)sender;

@end
