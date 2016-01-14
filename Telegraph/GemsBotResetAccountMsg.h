//
//  GemsBotResetAccountMsg.h
//  GetGems
//
//  Created by alon muroch on 5/25/15.
//
//

#import "GemsBotMessageBase.h"

@interface GemsBotResetAccountMsg : GemsBotMessageBase
{
    NSString *_pinHash;
    NSString *_pubKey;
}

@property(nonatomic, strong) NSString *encryptedPayload;

- (instancetype)initWithPinHash:(NSString*)pinHash andPubKey:(NSString*)pubKey;

@end
