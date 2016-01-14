//
//  GemsBotRegisterMsg.m
//  GetGems
//
//  Created by alon muroch on 5/20/15.
//
//

#import "GemsBotRegisterMsg.h"

@implementation GemsBotRegisterMsg

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
    return [NSString stringWithFormat:@".registerRequest %@", _pubKey];
}

+ (id)processMesasge:(NSString*)msg
{
    GemsBotMessageBase *base = [super processMesasge:msg];
    if(base)
        return base;
    
    NSArray *compenents = [msg componentsSeparatedByString:@" "];
    if(compenents.count != 3) return nil;
    if(![[compenents objectAtIndex:0] isEqualToString:@".response"]) return nil;
    
    GemsBotRegisterMsg *ret = [[GemsBotRegisterMsg alloc] init];
    ret.serverPubKey = [compenents objectAtIndex:2];
    ret.challenge = [compenents objectAtIndex:1];
    
    return ret;
}

@end
