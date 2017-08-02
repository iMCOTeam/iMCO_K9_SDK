//
//  ZHTitleAndSwitchTableViewCell.m
//  iMCOBandRealTekSDK_iOS
//
//  Created by aimoke on 2017/7/17.
//  Copyright © 2017年 zhuo. All rights reserved.
//

#import "ZHTitleAndSwitchTableViewCell.h"

@implementation ZHTitleAndSwitchTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.switchView.on = NO;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)switchValueHaveChanged:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(handleSWitchActionWithCell:)]) {
        [self.delegate handleSWitchActionWithCell:self];
    }
}
@end
