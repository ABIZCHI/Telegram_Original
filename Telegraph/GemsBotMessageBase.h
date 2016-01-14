//
//  GemsBotPayloadBase.h
//  GetGems
//
//  Created by alon muroch on 5/20/15.
//
//

#import <Foundation/Foundation.h>
#import "TGPreparedTextMessage.h"
#import "TGPreparedTextMessage.h"

@interface GemsBotMessageBase : NSObject

- (TGPreparedTextMessage*)msg;

+ (id)processMesasge:(NSString*)msg;
- (BOOL)isValid;
- (TGPreparedTextMessage*)msg;
- (NSString*)generateText;

@property(nonatomic, strong) NSString *serverPubKey;

@end
