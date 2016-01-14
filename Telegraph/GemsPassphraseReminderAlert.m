//
//  GemsPassphraseReminderAlert.m
//  GetGems
//
//  Created by alon muroch on 7/19/15.
//
//

#import "GemsPassphraseReminderAlert.h"

@implementation GemsPassphraseReminderAlert

+ (instancetype)new
{
    GemsPassphraseReminderAlert *alert = [[GemsPassphraseReminderAlert alloc] initWithDic:@{@"alertId" : [[NSUUID UUID] UUIDString], @"type" : @"PASSPHRASE_REMINDER"}];
    return alert;
}

- (instancetype)initWithDic:(NSDictionary*)dic
{
    self = [super initWithDic:dic];
    if(self) {
        self.type = GemsAlertPassphraseReminder;
    }
    return self;
}


@end
