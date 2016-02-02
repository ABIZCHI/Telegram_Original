//
//  GemsBotAuthenticationMsg.m
//  GetGems
//
//  Created by alon muroch on 8/18/15.
//
//

#import "GemsBotAuthenticationMsg.h"

// GemsCore
#import <GemsCore/CryptoUtils.h>

@interface GemsBotAuthenticationMsg()
{
    NSString *_deviceAuth, *_phoneNumber, *_ver, *_jwtToken;
}

@end

@implementation GemsBotAuthenticationMsg

- (instancetype)initWithDeviceAuth:(NSString*)deviceAuth phoneNumber:(NSString*)phoneNumber ver:(NSString*)ver
{
    self = [super init];
    if(self) {
        _deviceAuth = deviceAuth;
        _phoneNumber = phoneNumber;
        _ver = ver;
    }
    return self;
}

- (NSString*)generateText
{
    return [NSString stringWithFormat:@".authenticateMe %@ %@ %@ %@", _deviceAuth, _phoneNumber, @"ios", _ver];
}

+ (id)processMesasge:(NSString*)msg
{
    GemsBotMessageBase *base = [super processMesasge:msg];
    if(base)
        return base;

    NSArray *compenents = [msg componentsSeparatedByString:@" "];
    if(compenents.count != 2) return nil;
    if(![[compenents objectAtIndex:0] isEqualToString:@".response"]) return nil;
    
    GemsBotAuthenticationMsg *ret = [GemsBotAuthenticationMsg new];
    
    NSDictionary *payload = [compenents[1] base58ToDictionary];
    
    ret.jwtToken = payload[@"jwtToken"];
    ret.gemsId = payload[@"gemsUserId"];
    ret.wasRegistering = [payload[@"newUser"] boolValue];
    
    return ret;
}

- (BOOL)isValid
{
    return self.jwtToken && self.gemsId;
}

@end
