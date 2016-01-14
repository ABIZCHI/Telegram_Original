//
//  GemsAirdropAlert.m
//  GetGems
//
//  Created by alon muroch on 11/2/15.
//
//

#import "GemsAirdropAlert.h"
#import "GemsTransactionsCommons.h"

@implementation GemsAirdropAlert

+ (instancetype)new
{
    GemsAirdropAlert *alert = [[GemsAirdropAlert alloc] initWithDic:@{@"alertId" : [[NSUUID UUID] UUIDString], @"type" : GemsTransactionAirdropStr}];
    return alert;
}

- (instancetype)initWithDic:(NSDictionary*)dic
{
    self = [super initWithDic:dic];
    if(self) {
        self.type = GemsAlertAirdrop;
    }
    return self;
}

@end
