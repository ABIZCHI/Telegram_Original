//
//  GemsBotResetAccountMsg.m
//  GetGems
//
//  Created by alon muroch on 5/25/15.
//
//

#import "GemsBotResetAccountMsg.h"

@implementation GemsBotResetAccountMsg

- (instancetype)initWithPinHash:(NSString*)pinHash andPubKey:(NSString*)pubKey
{
    self = [super init];
    if(self) {
        _pubKey = pubKey;
        _pinHash = pinHash;
    }
    return self;
}

- (NSString*)generateText
{
    return [NSString stringWithFormat:@".resetAccountRequest %@ %@", _pubKey, _pinHash];
}

+ (id)processMesasge:(NSString*)msg
{
    GemsBotMessageBase *base = [super processMesasge:msg];
    if(base)
        return base;
    
    NSArray *compenents = [msg componentsSeparatedByString:@" "];
    if(compenents.count != 3) return nil;
    if(![[compenents objectAtIndex:0] isEqualToString:@".resetAccountReply"]) return nil;
    
    GemsBotResetAccountMsg *ret = [[GemsBotResetAccountMsg alloc] init];
    ret.serverPubKey = [compenents objectAtIndex:2];
    ret.encryptedPayload = [compenents objectAtIndex:1];
    
    return ret;
}

@end
