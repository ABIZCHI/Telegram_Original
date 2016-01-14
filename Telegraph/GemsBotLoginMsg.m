//
//  GemsBotLoginMsg.m
//  GetGems
//
//  Created by alon muroch on 5/25/15.
//
//

#import "GemsBotLoginMsg.h"

@implementation GemsBotLoginMsg

- (instancetype)initWithPubKey:(NSString*)pubKey
{
    self = [super init];
    if(self) {
        _pubKey = pubKey;
    }
    return self;
}

- (NSString*)generateText
{
    return [NSString stringWithFormat:@".loginRequest %@", _pubKey];
}

+ (id)processMesasge:(NSString*)msg
{
    GemsBotMessageBase *base = [super processMesasge:msg];
    if(base)
        return base;
    
    NSArray *compenents = [msg componentsSeparatedByString:@" "];
    if(compenents.count != 3) return nil;
    if(![[compenents objectAtIndex:0] isEqualToString:@".loginReply"]) return nil;
    
    GemsBotLoginMsg *ret = [[GemsBotLoginMsg alloc] init];
    ret.serverPubKey = [compenents objectAtIndex:2];
    ret.encryptedPayload = [compenents objectAtIndex:1];
    
    return ret;
}

@end
