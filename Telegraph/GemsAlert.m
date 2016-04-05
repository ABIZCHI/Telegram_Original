//
//  GemsAlert.m
//  GetGems
//
//  Created by alon muroch on 7/19/15.
//
//

#import "GemsAlert.h"
#import "GemsTransactionsCommons.h"

#import "GemsInviteRewardAlert.h"
#import "GemsInviterRewardView.h"

#import "GemsPassphraseRemainderView.h"
#import "GemsPassphraseReminderAlert.h"

#import "GemsLoggedToFacebookView.h"
#import "GemsLoggedToFacebookAlert.h"

#import "GemsAirdropView.h"
#import "GemsAirdropAlert.h"

#import "GemsKeyboardAlert.h"
#import "GemsKeyboardAlertView.h"

@implementation GemsAlert

- (instancetype)initWithDic:(NSDictionary*)dic
{
    self = [super init];
    if(self) {
        _rawData = dic;
        
        _alertId = dic[@"alertId"];
        
        if([[dic allKeys] containsObject:@"type"])
            _type = [GemsAlert gemsAlertTypeFromString:dic[@"type"]];
        else
            _type = UnkownGemsAlert;
        
        if([[dic allKeys] containsObject:@"wasRead"])
            _wasRead = [dic[@"wasRead"] boolValue];
        else
            _wasRead = NO;
    }
    return self;
}

+ (instancetype)gemsAlertFromDictionary:(NSDictionary *)dic
{
    GemsAlertType type = [GemsAlert gemsAlertTypeFromString:dic[@"type"]];
    switch (type) {
        case GemsAlertInviteReward:
        {
            GemsInviteRewardAlert *ret = [[GemsInviteRewardAlert alloc] initWithDic:dic];
            return ret;
        }
            break;
        case GemsAlertPassphraseReminder:
        {
            GemsPassphraseReminderAlert *ret = [[GemsPassphraseReminderAlert alloc] initWithDic:dic];
            return ret;
        }
            break;
        case GemsAlertFacebookLogin:
        {
            GemsLoggedToFacebookAlert *ret = [[GemsLoggedToFacebookAlert alloc] initWithDic:dic];
            return ret;
        }
            break;
        case GemsAlertAirdrop:
        {
            GemsAirdropAlert *ret = [[GemsAirdropAlert alloc] initWithDic:dic];
            return ret;
        }
            break;
        case GemsKeyboardPromotionAlert:
        {
            GemsKeyboardAlert *ret = [[GemsKeyboardAlert alloc] initWithDic:dic];
            return ret;
        }
            break;
        default:
        {
            return nil;
        }
        break;
    }
}

#pragma mark - view
- (GemsAlertViewBase *)alertView
{
    switch (_type) {
        case GemsAlertInviteReward:
        {
            GemsInviterRewardView *v = [GemsInviterRewardView new];
            v.alertObject = [self copy];
            return v;
        }
            break;
        case GemsAlertPassphraseReminder:
        {
            GemsPassphraseRemainderView *v = [GemsPassphraseRemainderView new];
            v.alertObject = [self copy];
            return v;
        }
            break;
        case GemsAlertFacebookLogin:
        {
            GemsLoggedToFacebookView *v = [GemsLoggedToFacebookView new];
            v.alertObject = [self copy];
            return v;
        }
            break;
        case GemsAlertAirdrop:
        {
            GemsAirdropView *v = [GemsAirdropView new];
            v.alertObject = [self copy];
            return v;
        }
            break;
        case GemsKeyboardPromotionAlert:
        {
            GemsKeyboardAlertView *v = [GemsKeyboardAlertView new];
            v.alertObject = [self copy];
            return v;
        }
            break;
        default:
            return [[GemsAlertViewBase alloc] init];
            break;
    }
}

#pragma mark - utils

+ (GemsAlertType)gemsAlertTypeFromString:(NSString*)str
{
    if([str isEqualToString:GemsTransactionInviteBonusStr])
    {
        return GemsAlertInviteReward;
    }
    
    if([str isEqualToString:@"PASSPHRASE_REMINDER"])
    {
        return GemsAlertPassphraseReminder;
    }
    
    if([str isEqualToString:GemsTransactionFacebookLikeStr])
    {
        return GemsAlertFacebookLogin;
    }
    
    if([str isEqualToString:GemsTransactionAirdropStr])
    {
        return GemsAlertAirdrop;
    }
    
    if([str isEqualToString:@"KEYBOARD_PROMOTION"])
    {
        return GemsKeyboardPromotionAlert;
    }
    
    return UnkownGemsAlert;
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:self.rawData];
    dic[@"wasRead"] = [NSString stringWithFormat:@"%d", _wasRead];
    dic[@"alertId"] = _alertId;
    [aCoder encodeObject:dic forKey:@"rawData"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSDictionary *raw = [aDecoder decodeObjectForKey:@"rawData"];
    return [GemsAlert gemsAlertFromDictionary:raw];
}

#pragma mark - NSCopying
-(id)copyWithZone:(NSZone *)__unused zone
{
    return [GemsAlert gemsAlertFromDictionary:_rawData];
}

@end
