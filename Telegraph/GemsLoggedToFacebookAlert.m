//
//  GemsLoggedToFacebookAlert.m
//  GetGems
//
//  Created by alon muroch on 7/23/15.
//
//

#import "GemsLoggedToFacebookAlert.h"

@implementation GemsLoggedToFacebookAlert

- (instancetype)initWithDic:(NSDictionary*)dic
{
    self = [super initWithDic:dic];
    if(self) {
        self.type = GemsAlertFacebookLogin;
    }
    return self;
}

@end
