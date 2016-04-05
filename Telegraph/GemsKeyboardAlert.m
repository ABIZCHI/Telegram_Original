//
//  GemsKeyboardAlert.m
//  GetGems
//
//  Created by alon muroch on 03/03/2016.
//
//

#import "GemsKeyboardAlert.h"

@implementation GemsKeyboardAlert

+ (instancetype)new
{
    GemsKeyboardAlert *alert = [[GemsKeyboardAlert alloc] initWithDic:@{@"alertId" : [[NSUUID UUID] UUIDString]
                                                                        , @"type" : @"KEYBOARD_PROMOTION"}];
    return alert;
}

- (instancetype)initWithDic:(NSDictionary*)dic
{
    self = [super initWithDic:dic];
    if(self) {
        self.type = GemsKeyboardPromotionAlert;
    }
    return self;
}

@end
