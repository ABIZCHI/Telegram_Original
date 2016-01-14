//
//  GemsBotRegisterMsg.h
//  GetGems
//
//  Created by alon muroch on 5/20/15.
//
//

#import "GemsBotMessageBase.h"

@interface GemsBotRegisterMsg : GemsBotMessageBase
{
    NSString *_pubKey;
}

- (instancetype)initWithPubKey:(NSString*)pubKey;

@property(nonatomic, strong) NSString *challenge;

@end
