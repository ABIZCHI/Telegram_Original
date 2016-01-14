//
//  GemsBotLoginMsg.h
//  GetGems
//
//  Created by alon muroch on 5/25/15.
//
//

#import "GemsBotMessageBase.h"

@interface GemsBotLoginMsg : GemsBotMessageBase
{
    NSString *_pubKey;
}
- (instancetype)initWithPubKey:(NSString*)pubKey;

@property(nonatomic, strong) NSString *encryptedPayload;

@end
