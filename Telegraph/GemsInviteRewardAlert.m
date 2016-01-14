//
//  GemsInviteRewardAlert.m
//  GetGems
//
//  Created by alon muroch on 7/19/15.
//
//

#import "GemsInviteRewardAlert.h"

@implementation GemsInviteRewardAlert

- (instancetype)initWithDic:(NSDictionary*)dic
{
    self = [super initWithDic:dic];
    if(self) {
        self.type = GemsAlertInviteReward;
        
        if(dic[@"tgid"] == [NSNull null] || dic[@"reward"] == [NSNull null]) return nil;
        
        _tgid = [dic[@"tgid"] intValue]; if (_tgid == 0) return nil;
        _reward = [dic[@"reward"] longLongValue];
    }
    return self;
}

@end
